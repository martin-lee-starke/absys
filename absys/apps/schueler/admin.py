from django.contrib import admin

from . import models


class SchuelerAdmin(admin.ModelAdmin):
    list_display = ('nachname', 'vorname', 'geburtsdatum', 'stufe', 'gruppe')
    list_display_links = ('nachname', 'vorname')
    list_filter = ('stufe', 'gruppe')
    search_fields = ['vorname', 'nachname']


admin.site.register(models.Gruppe)
admin.site.register(models.Schueler, SchuelerAdmin)
admin.site.register(models.Sozialamt)
admin.site.register(models.Stufe)
