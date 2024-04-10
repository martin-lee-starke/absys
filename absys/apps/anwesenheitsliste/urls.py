from django.urls import path, re_path
from . import views
urlpatterns = [
    #Bugfix
    re_path(
        r'^(?P<datum>\d{4}-\d{2}-\d{2})/$',
        views.AnwesenheitslisteFormSetView.as_view(), #funktion die aufgerufen wird (ClassBasedView)
        name='anwesenheitsliste_anwesenheit_anwesenheitsliste' #name
    ),
    re_path(
        r'^$',
        views.AnwesenheitslisteHeuteRedirectView.as_view(),
        name='anwesenheitsliste_anwesenheit_heute'
    )
]
