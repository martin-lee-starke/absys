# -*- coding: utf-8 -*-
# Generated by Django 1.10.2 on 2016-12-02 16:40
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('schueler', '0004_auto_20161202_1628'),
    ]

    operations = [
        migrations.AlterField(
            model_name='schueler',
            name='aktenzeichen',
            field=models.CharField(max_length=12, verbose_name='Aktenzeichen'),
        ),
    ]
