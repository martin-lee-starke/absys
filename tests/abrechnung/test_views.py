import os

import pytest
from django.template.loader import get_template, render_to_string

from absys.apps.abrechnung import models
from absys.apps.abrechnung.views import AbrechnungPDFView


@pytest.mark.django_db
class TestAbrechnungPDFViewKonfiguration:

    def test_pdf_template_hat_keine_link_css_tags(self):
        """PDF-Template darf keine <link>-CSS-Tags enthalten.

        Solche Tags würden WeasyPrint dazu veranlassen, CSS-Dateien per HTTP
        vom eigenen Server zu laden, was in Produktion zu Timeouts (~10 min) führt.
        """
        from django.template.loader import get_template
        template = get_template('abrechnung/pdf.html')
        quelltext = template.template.source
        assert '<link rel="stylesheet"' not in quelltext

    def test_get_pdf_stylesheets_enthaelt_nur_pdf_css(self, settings, tmp_path):
        """get_pdf_stylesheets() darf nur pdf.css enthalten, kein Bootstrap."""
        settings.STATIC_ROOT = str(tmp_path)
        view = AbrechnungPDFView()
        stylesheets = view.get_pdf_stylesheets()
        dateinamen = [os.path.basename(p) for p in stylesheets]
        assert dateinamen == ['pdf.css'], \
            "Nur pdf.css erwartet, um WeasyPrint-Rendering zu beschleunigen. Gefunden: {}".format(dateinamen)
        assert 'bootstrap.min.css' not in dateinamen
        assert 'bootstrap-theme.min.css' not in dateinamen

    def test_get_pdf_stylesheets_pfade_unterhalb_static_root(self, settings, tmp_path):
        """Alle CSS-Pfade müssen unter STATIC_ROOT liegen, nicht per HTTP erreichbar sein."""
        settings.STATIC_ROOT = str(tmp_path)
        view = AbrechnungPDFView()
        for pfad in view.get_pdf_stylesheets():
            assert pfad.startswith(str(tmp_path)), \
                "CSS-Pfad liegt nicht unter STATIC_ROOT: {}".format(pfad)


@pytest.mark.django_db
class TestAbrechnungPDFViewQuerieoptimierung:
    """Charakterisierungs- und Verhaltensstests für N+1-Query-Fix (Issue #10)."""

    def test_get_queryset_gibt_rechnungsozialamt_zurueck(self):
        """AbrechnungPDFView.get_queryset() gibt RechnungSozialamt-QuerySet zurück."""
        view = AbrechnungPDFView()
        qs = view.get_queryset()
        assert qs.model == models.RechnungSozialamt

    def test_get_queryset_nutzt_select_related_sozialamt(self):
        """get_queryset() muss select_related('sozialamt') enthalten."""
        view = AbrechnungPDFView()
        qs = view.get_queryset()
        assert isinstance(qs.query.select_related, dict) and 'sozialamt' in qs.query.select_related

    def test_get_queryset_nutzt_prefetch_related_positionen_schueler(self):
        """get_queryset() muss prefetch_related für positionen__schueler enthalten."""
        view = AbrechnungPDFView()
        qs = view.get_queryset()
        assert 'rechnungen_einrichtungen__positionen__schueler' in qs._prefetch_related_lookups

    def test_get_queryset_nutzt_prefetch_related_einrichtung_standort(self):
        """get_queryset() muss prefetch_related für einrichtung__standort enthalten."""
        view = AbrechnungPDFView()
        qs = view.get_queryset()
        assert 'rechnungen_einrichtungen__einrichtung__standort' in qs._prefetch_related_lookups


class TestAbrechnungPDFTemplatesQuerieoptimierung:
    """Stellt sicher, dass Templates keine doppelten Queryset-Auswertungen verursachen."""

    def test_pdf_template_rechnungen_einrichtungen_einmal_abgerufen(self):
        """pdf.html darf rechnungen_einrichtungen.all maximal einmal aufrufen."""
        template = get_template('abrechnung/pdf.html')
        quelltext = template.template.source
        assert quelltext.count('rechnungen_einrichtungen.all') <= 1

    def test_einrichtungsrechnung_template_hat_with_positionen_block(self):
        """_einrichtungsrechnung.html muss positionen per with-Block cachen statt direkt im for-Tag."""
        template = get_template('abrechnung/pdf/_einrichtungsrechnung.html')
        quelltext = template.template.source
        assert '{% with positionen=einrichtungsrechnung.positionen.all %}' in quelltext
        assert 'for einrichtungsposition in positionen' in quelltext

    def test_uebersicht_template_nutzt_gecachte_positionen_variable(self):
        """_einrichtung_uebersicht.html muss positionen-Variable nutzen, nicht positionen.all aufrufen."""
        template = get_template('abrechnung/pdf/_einrichtung_uebersicht.html')
        quelltext = template.template.source
        assert 'positionen.all' not in quelltext
        assert 'for einrichtungsposition in positionen' in quelltext
