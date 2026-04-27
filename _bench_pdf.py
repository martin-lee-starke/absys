import time
from django.db import connection, reset_queries
from django.conf import settings
from django.template.loader import render_to_string
from absys.apps.abrechnung.views import AbrechnungPDFView
import weasyprint

settings.DEBUG = True
pk = 3048
view = AbrechnungPDFView()

# --- Phase 1: DB ---
reset_queries()
t0 = time.time()
rechnung = view.get_queryset().get(pk=pk)
for re in rechnung.rechnungen_einrichtungen.all():
    for pos in re.positionen.all():
        _ = list(pos.detailabrechnung)
t_db = time.time() - t0
n_queries = len(connection.queries)
print('DB:          {:.3f}s | {} Queries'.format(t_db, n_queries), flush=True)

# --- Phase 2: Template ---
reset_queries()
t1 = time.time()
html = render_to_string('abrechnung/pdf.html', {
    'rechnungsozialamt': rechnung,
    'rechnungen_einrichtungen': rechnung.rechnungen_einrichtungen.all(),
    'view': view,
})
t_template = time.time() - t1
print('Template:    {:.3f}s | {} weitere Queries | HTML {}KB'.format(
    t_template, len(connection.queries), len(html) // 1024), flush=True)

# --- Phase 3: WeasyPrint ---
print('WeasyPrint startet...', flush=True)
t2 = time.time()
css = []
for f in view.get_pdf_stylesheets():
    css.append(weasyprint.CSS(filename=f))
rendered = weasyprint.HTML(string=html).render(stylesheets=css)
pages = len(rendered.pages)
pdf_bytes = rendered.write_pdf()
t_weasy = time.time() - t2
print('WeasyPrint:  {:.3f}s | {}KB | {} Seiten'.format(
    t_weasy, len(pdf_bytes) // 1024, pages), flush=True)

print()
print('GESAMT:      {:.3f}s'.format(t_db + t_template + t_weasy), flush=True)
