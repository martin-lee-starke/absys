# -*- coding: utf-8 -*-
# Generated by Django 1.10.2 on 2016-10-25 18:42
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('abrechnung', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='rechnungeinrichtung',
            name='buchungskennzeichen',
            field=models.CharField(max_length=12, verbose_name='Buchungskennzeichen'),
        ),
    ]
