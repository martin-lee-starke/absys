import factory

from absys.apps.buchungskennzeichen import models


class BuchungskennzeichenFactory(factory.django.DjangoModelFactory):

    buchungskennzeichen = factory.Faker('pystr', max_chars=12)
    verfuegbar = True

    class Meta:
        model = models.Buchungskennzeichen
