from django.apps import AppConfig
from django.utils.translation import gettext_lazy as _


class AnmeldungConfig(AppConfig):
    """Configuration for anmeldung app."""

    name = 'absys.apps.anmeldung'
    verbose_name = _("Anmeldung")
