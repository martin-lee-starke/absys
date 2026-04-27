import os

import pytest
from django.template.loader import render_to_string

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

    def test_get_pdf_stylesheets_enthaelt_alle_drei_css_dateien(self, settings, tmp_path):
        """get_pdf_stylesheets() muss Bootstrap, Bootstrap-Theme und main.css enthalten."""
        settings.STATIC_ROOT = str(tmp_path)
        view = AbrechnungPDFView()
        stylesheets = view.get_pdf_stylesheets()
        dateinamen = [os.path.basename(p) for p in stylesheets]
        assert 'bootstrap.min.css' in dateinamen
        assert 'bootstrap-theme.min.css' in dateinamen
        assert 'main.css' in dateinamen

    def test_get_pdf_stylesheets_pfade_unterhalb_static_root(self, settings, tmp_path):
        """Alle CSS-Pfade müssen unter STATIC_ROOT liegen, nicht per HTTP erreichbar sein."""
        settings.STATIC_ROOT = str(tmp_path)
        view = AbrechnungPDFView()
        for pfad in view.get_pdf_stylesheets():
            assert pfad.startswith(str(tmp_path)), \
                "CSS-Pfad liegt nicht unter STATIC_ROOT: {}".format(pfad)
