from django.conf.urls import url

from . import views

urlpatterns = [
    url(
        r'^$',
        views.RechnungSozialamtFormView.as_view(),
        name='abrechnung_rechnungsozialamt_form'
    ),
    url(
        r'^(?P<pk>[\d]+)/pdf/',
        views.AbrechnungPDFView.as_view(),
        name='abrechnung_rechnungsozialamt_pdf'
    ),
    url(
        r'^(?P<pk>[\d]+)/bearbeiten/',
        views.RechnungSozialamtUpdateView.as_view(),
        name='abrechnung_rechnungsozialamt_update'
    ),
    url(
        r'^(?P<pk>[\d]+)/loeschen/',
        views.RechnungSozialamtDeleteView.as_view(),
        name='abrechnung_rechnungsozialamt_delete'
    ),
]
