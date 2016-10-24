# -*- coding: utf-8 -*-
# Generated by Django 1.10.2 on 2016-10-24 10:53
from __future__ import unicode_literals

from django.db import migrations, models
import django.utils.timezone
import model_utils.fields


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Buchungskennzeichen',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created', model_utils.fields.AutoCreatedField(default=django.utils.timezone.now, editable=False, verbose_name='created')),
                ('modified', model_utils.fields.AutoLastModifiedField(default=django.utils.timezone.now, editable=False, verbose_name='modified')),
                ('buchungskennzeichen', models.CharField(max_length=20, unique=True, verbose_name='Buchungskennzeichen')),
                ('verfuegbar', models.BooleanField(default=True, editable=False, verbose_name='ist verfügbar')),
            ],
            options={
                'verbose_name': 'Buchungskennzeichen',
                'ordering': ['-created'],
                'verbose_name_plural': 'Buchungskennzeichen',
            },
        ),
    ]
