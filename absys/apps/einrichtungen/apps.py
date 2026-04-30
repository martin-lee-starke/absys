from django.apps import AppConfig
from django.utils.translation import gettext_lazy as _


class EinrichtungenConfig(AppConfig):
    """Configuration for einrichtungen app."""

    name = 'absys.apps.einrichtungen'
    verbose_name = _("Einrichtungen")
