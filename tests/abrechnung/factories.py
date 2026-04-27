import datetime
import decimal
import random

import factory
from django.utils.timezone import now

from absys.apps.abrechnung import models
from ..einrichtungen.factories import EinrichtungFactory
from ..schueler.factories import SchuelerFactory, SozialamtFactory


class RechnungSozialamtFactory(factory.django.DjangoModelFactory):

    sozialamt = factory.SubFactory(SozialamtFactory)
    startdatum = factory.LazyAttribute(
        lambda obj: obj.enddatum - datetime.timedelta(obj.zeitraum)
    )
    enddatum = datetime.date(2016, 3, 31)

    class Meta:
        model = models.RechnungSozialamt

    class Params:
        zeitraum = 30


class RechnungsPositionSchuelerFactory(factory.django.DjangoModelFactory):

    rechnung_sozialamt = factory.SubFactory(RechnungSozialamtFactory)
    schueler = factory.SubFactory(SchuelerFactory)
    einrichtung = factory.SubFactory(EinrichtungFactory)
    pflegesatz = factory.Faker('pydecimal', left_digits=2, right_digits=2, positive=True)
    datum = factory.LazyAttribute(lambda obj: now().date() - datetime.timedelta(random.randint(10, 30)))

    class Meta:
        model = models.RechnungsPositionSchueler


class RechnungEinrichtungFactory(factory.django.DjangoModelFactory):

    rechnung_sozialamt = factory.SubFactory(RechnungSozialamtFactory)
    einrichtung = factory.SubFactory(EinrichtungFactory)
    name_einrichtung = factory.Faker('company')
    buchungskennzeichen = factory.Faker('bothify', text='??########')
    datum_faellig = datetime.date(2016, 4, 15)
    betreuungstage = 20

    class Meta:
        model = models.RechnungEinrichtung


class RechnungsPositionEinrichtungFactory(factory.django.DjangoModelFactory):

    schueler = factory.SubFactory(SchuelerFactory)
    rechnung_einrichtung = factory.SubFactory(RechnungEinrichtungFactory)
    fehltage_max = 5
    anwesend = 20
    fehltage = 2
    fehltage_uebertrag = 0
    fehltage_gesamt = 2
    fehltage_abrechnung = 2
    zahltage = 22
    bargeldbetrag = factory.LazyAttribute(lambda obj: decimal.Decimal('0.00'))
    bekleidungsgeld = factory.LazyAttribute(lambda obj: decimal.Decimal('0.00'))
    summe = factory.LazyAttribute(lambda obj: decimal.Decimal('1000.00'))

    class Meta:
        model = models.RechnungsPositionEinrichtung
