# -*- coding: utf-8 -*-
# Generated by Django 1.10.2 on 2017-01-19 21:03
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('schueler', '0011_auto_20170117_1422'),
    ]

    operations = [
        migrations.AlterField(
            model_name='sozialamt',
            name='sbkz',
            field=models.CharField(blank=True, max_length=12, verbose_name='Sozialamts-buchungskennzeichen'),
        ),
    ]
