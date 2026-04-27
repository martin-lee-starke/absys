import datetime
import decimal
import time

import pytest
from django.db import connection
from django.template.loader import render_to_string
from django.test.utils import CaptureQueriesContext

from absys.apps.abrechnung import models
from absys.apps.abrechnung.views import AbrechnungPDFView


@pytest.fixture
def grosse_rechnung(db, rechnung_einrichtung_factory, schueler_factory):
    """
    Erstellt eine realistische große Rechnung: 30 Schüler, 59 Tage (Feb+März 2016).

    Ergibt 30 RechnungsPositionEinrichtung und 1770 RechnungsPositionSchueler.
    bulk_create sorgt dafür, dass die Fixture-Erstellung nur wenige Sekunden dauert.
    """
    startdatum = datetime.date(2016, 2, 1)
    enddatum = datetime.date(2016, 3, 31)
    re = rechnung_einrichtung_factory(
        rechnung_sozialamt__startdatum=startdatum,
        rechnung_sozialamt__enddatum=enddatum,
    )
    rs = re.rechnung_sozialamt
    schueler_liste = [schueler_factory() for _ in range(30)]

    from tests.abrechnung.factories import RechnungsPositionEinrichtungFactory
    for schueler in schueler_liste:
        RechnungsPositionEinrichtungFactory(
            schueler=schueler,
            rechnung_einrichtung=re,
            anwesend=50,
            fehltage=9,
            fehltage_gesamt=9,
            zahltage=51,
            summe=decimal.Decimal('4207.50'),
        )

    positionen = []
    datum = startdatum
    while datum <= enddatum:
        for schueler in schueler_liste:
            positionen.append(models.RechnungsPositionSchueler(
                rechnung_sozialamt=rs,
                schueler=schueler,
                einrichtung=re.einrichtung,
                datum=datum,
                abgerechnet=True,
                abwesend=(datum.weekday() >= 5),
                name_schueler=schueler.voller_name,
                name_einrichtung=re.einrichtung.name,
                pflegesatz=decimal.Decimal('82.50'),
            ))
        datum += datetime.timedelta(1)
    models.RechnungsPositionSchueler.objects.bulk_create(positionen)
    return rs


@pytest.mark.django_db
class TestAbrechnungPDFQueryAnzahl:
    """Stellt sicher, dass DB-Queries beim PDF-Render O(1) bleiben und nicht mit der Schülerzahl wachsen."""

    def test_queries_bleiben_konstant_unabhaengig_von_schueleranzahl(self, grosse_rechnung):
        """Queries beim Zugriff auf detailabrechnung für 30 Schüler sind O(1), nicht O(30)."""
        view = AbrechnungPDFView()
        with CaptureQueriesContext(connection) as ctx:
            obj = view.get_queryset().get(pk=grosse_rechnung.pk)
            for re in obj.rechnungen_einrichtungen.all():
                for pos in re.positionen.all():
                    _ = list(pos.detailabrechnung)

        assert len(ctx.captured_queries) <= 15, (
            "Zu viele Queries: {} (erwartet <= 15). "
            "Möglicherweise ist N+1 zurückgekehrt.".format(len(ctx.captured_queries))
        )

    def test_aggregate_properties_ohne_extra_queries_nach_prefetch(self, grosse_rechnung):
        """anwesenheitssumme, abwesenheitssumme und fehltage_anderer_zeitraum feuern nach dem Prefetch keine DB-Queries."""
        view = AbrechnungPDFView()
        obj = view.get_queryset().get(pk=grosse_rechnung.pk)
        # Prefetch warmlaufen lassen
        for re in obj.rechnungen_einrichtungen.all():
            list(re.positionen.all())

        with CaptureQueriesContext(connection) as ctx:
            for re in obj.rechnungen_einrichtungen.all():
                for pos in re.positionen.all():
                    _ = pos.anwesenheitssumme
                    _ = pos.abwesenheitssumme
                    _ = pos.fehltage_anderer_zeitraum

        assert len(ctx.captured_queries) == 0, (
            "Aggregate-Properties feuern immer noch {} Queries nach dem Prefetch.".format(
                len(ctx.captured_queries))
        )


@pytest.mark.django_db
@pytest.mark.slowtest
class TestAbrechnungPDFBenchmark:
    """
    Vollständiger Performance-Benchmark für den PDF-View.

    Misst DB-, Template- und WeasyPrint-Laufzeit mit einem großen, realistischen
    Datensatz (30 Schüler, 59 Tage). Mit 'pytest -m slowtest -s' ausführen.
    """

    def test_pdf_render_benchmark(self, grosse_rechnung, capsys):
        """Misst alle Phasen der PDF-Generierung und gibt Zeiten aus."""
        import weasyprint

        view = AbrechnungPDFView()
        pk = grosse_rechnung.pk

        # --- Phase 1: DB + Prefetch ---
        with CaptureQueriesContext(connection) as ctx_db:
            t0 = time.time()
            rechnung = view.get_queryset().get(pk=pk)
            for re in rechnung.rechnungen_einrichtungen.all():
                for pos in re.positionen.all():
                    _ = list(pos.detailabrechnung)
            t_db = time.time() - t0

        n_einr_pos = sum(re.positionen.count() for re in rechnung.rechnungen_einrichtungen.all())
        n_schueler_pos = rechnung.positionen_schueler.count()

        # --- Phase 2: Template ---
        with CaptureQueriesContext(connection) as ctx_tmpl:
            t1 = time.time()
            html = render_to_string('abrechnung/pdf.html', {
                'rechnungsozialamt': rechnung,
                'rechnungen_einrichtungen': rechnung.rechnungen_einrichtungen.all(),
                'view': view,
            })
            t_template = time.time() - t1

        # --- Phase 3: WeasyPrint ---
        t2 = time.time()
        css = []
        for f in view.get_pdf_stylesheets():
            css.append(weasyprint.CSS(filename=f))
        rendered = weasyprint.HTML(string=html).render(stylesheets=css)
        pages = len(rendered.pages)
        pdf_bytes = rendered.write_pdf()
        t_weasy = time.time() - t2

        with capsys.disabled():
            print("\n--- PDF-Benchmark (grosse_rechnung) ---")
            print("Einrichtungspositionen: {} | Schülerpositionen: {}".format(
                n_einr_pos, n_schueler_pos))
            print("DB:          {:.3f}s | {} Queries".format(
                t_db, len(ctx_db.captured_queries)))
            print("Template:    {:.3f}s | {} Queries | HTML {}KB".format(
                t_template, len(ctx_tmpl.captured_queries), len(html) // 1024))
            print("WeasyPrint:  {:.3f}s | {}KB | {} Seiten".format(
                t_weasy, len(pdf_bytes) // 1024, pages))
            print("GESAMT:      {:.3f}s".format(t_db + t_template + t_weasy))

        assert len(ctx_db.captured_queries) <= 15, \
            "DB-Queries zu hoch: {}".format(len(ctx_db.captured_queries))
        assert len(ctx_tmpl.captured_queries) <= 10, \
            "Template-Queries zu hoch: {}".format(len(ctx_tmpl.captured_queries))
        assert len(pdf_bytes) > 0
        assert pages > 0
