# -*- coding: utf-8 -*-
# Generated by Django 1.10.2 on 2016-12-02 16:29
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('einrichtungen', '0009_auto_20161202_1618'),
    ]

    operations = [
        migrations.AddField(
            model_name='einrichtung',
            name='pers_bkz',
            field=models.BooleanField(default=False, verbose_name='Persönliches BKZ'),
        ),
    ]
