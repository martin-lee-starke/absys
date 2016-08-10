# -*- coding: utf-8 -*-
# Generated by Django 1.10 on 2016-08-10 14:02
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion
import django.utils.timezone
import model_utils.fields


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('einrichtungen', '0009_auto_20160719_1923'),
        ('schueler', '0003_auto_20160719_1923'),
    ]

    operations = [
        migrations.CreateModel(
            name='Rechnung',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created', model_utils.fields.AutoCreatedField(default=django.utils.timezone.now, editable=False, verbose_name='created')),
                ('modified', model_utils.fields.AutoLastModifiedField(default=django.utils.timezone.now, editable=False, verbose_name='modified')),
                ('name_schueler', models.CharField(max_length=61, verbose_name='Name des Schülers')),
                ('summe', models.DecimalField(decimal_places=2, max_digits=7, null=True, verbose_name='Gesamtbetrag')),
                ('fehltage', models.PositiveIntegerField(default=0, verbose_name='Fehltage im Abrechnungszeitraum')),
                ('fehltage_gesamt', models.PositiveIntegerField(default=0, verbose_name='Fehltage seit Eintritt in die Einrichtung')),
                ('fehltage_nicht_abgerechnet', models.PositiveIntegerField(default=0, verbose_name='Bisher nicht abgerechnete Fehltage')),
                ('max_fehltage', models.PositiveIntegerField(default=0, verbose_name='Maximale Fehltage zum Abrechnungstag')),
            ],
            options={
                'verbose_name_plural': 'Rechnungen',
                'verbose_name': 'Rechnung',
                'ordering': ('-rechnung_sozialamt__startdatum', '-rechnung_sozialamt__enddatum', 'rechnung_sozialamt', 'schueler'),
            },
        ),
        migrations.CreateModel(
            name='RechnungSozialamt',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created', model_utils.fields.AutoCreatedField(default=django.utils.timezone.now, editable=False, verbose_name='created')),
                ('modified', model_utils.fields.AutoLastModifiedField(default=django.utils.timezone.now, editable=False, verbose_name='modified')),
                ('sozialamt_anschrift', models.TextField()),
                ('startdatum', models.DateField(verbose_name='Startdatum')),
                ('enddatum', models.DateField(help_text='Das Enddatum muss nach dem Startdatum liegen.', verbose_name='Enddatum')),
                ('sozialamt', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='rechnungen', to='schueler.Sozialamt', verbose_name='Sozialamt')),
            ],
            options={
                'verbose_name_plural': 'Sozialamtsrechnungen',
                'verbose_name': 'Sozialamtsrechnung',
                'ordering': ('-startdatum', '-enddatum', 'sozialamt'),
            },
        ),
        migrations.CreateModel(
            name='RechnungsPosition',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created', model_utils.fields.AutoCreatedField(default=django.utils.timezone.now, editable=False, verbose_name='created')),
                ('modified', model_utils.fields.AutoLastModifiedField(default=django.utils.timezone.now, editable=False, verbose_name='modified')),
                ('datum', models.DateField(verbose_name='Datum')),
                ('name_einrichtung', models.CharField(max_length=20, verbose_name='Einrichtung')),
                ('tag_art', models.CharField(choices=[('ferien', 'Ferientag'), ('schule', 'Schultag')], default='schule', max_length=20, verbose_name='Schul- oder Ferientag')),
                ('abwesend', models.BooleanField(default=False, verbose_name='Abwesenheit')),
                ('pflegesatz', models.DecimalField(decimal_places=2, max_digits=4, verbose_name='Pflegesatz')),
                ('einrichtung', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='einrichtungen.Einrichtung', verbose_name='Schüler')),
                ('rechnung', models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, related_name='positionen', to='abrechnung.Rechnung', verbose_name='Rechnung')),
                ('schueler', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='schueler.Schueler', verbose_name='Schüler')),
                ('sozialamt', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='schueler.Sozialamt', verbose_name='Sozialamt')),
            ],
            options={
                'verbose_name_plural': 'Rechnungspositionen',
                'verbose_name': 'Rechnungsposition',
                'ordering': ('sozialamt', 'schueler', 'einrichtung', 'datum'),
            },
        ),
        migrations.AddField(
            model_name='rechnung',
            name='rechnung_sozialamt',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='rechnungen', to='abrechnung.RechnungSozialamt', verbose_name='Sozialamtsrechnung'),
        ),
        migrations.AddField(
            model_name='rechnung',
            name='schueler',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='rechnungen', to='schueler.Schueler', verbose_name='Schüler'),
        ),
        migrations.AlterUniqueTogether(
            name='rechnungsposition',
            unique_together=set([('schueler', 'datum')]),
        ),
        migrations.AlterUniqueTogether(
            name='rechnungsozialamt',
            unique_together=set([('sozialamt', 'startdatum', 'enddatum')]),
        ),
        migrations.AlterUniqueTogether(
            name='rechnung',
            unique_together=set([('rechnung_sozialamt', 'schueler')]),
        ),
    ]
