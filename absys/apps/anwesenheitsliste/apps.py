from django.apps import AppConfig
from django.utils.translation import gettext_lazy as _


class AnwesenheitslisteConfig(AppConfig):
    """Configuration for anwesenheitsliste app."""

    name = 'absys.apps.anwesenheitsliste'
    verbose_name = _("Anwesenheitsliste")
