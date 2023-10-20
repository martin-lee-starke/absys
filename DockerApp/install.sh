#!/usr/bin/env bash
# Installation und Konfiguration AbSys

set -o errexit
set -o nounset
set -o pipefail
set -o verbose

#Ordner für media und static_root
MEDIA=/home/vagrant/media/
STATIC_ROOT=/home/vagrant/static_root/

# PACKAGE_PATH Variable anpassen. Dies kann entweder ein vollständiger Pfad
# oder ein URL sein, an dem pip alle für die Installation nötigen Python Pakete
# finden kann.
PACKAGE_PATH=/home/vagrant/wheelhouse

# Pfad zum Python Virtual Environment, in das alle Python Pakete später
# installiert werden. Falls nötig anpassen.
VENV_PATH=/home/vagrant/pyvenv

# Hier, falls nötig, weitere Optionen für pip angeben. Beispiel:
# PIP_DEFAULT_OPTIONS="--proxy https://proxy.example.com"
# pip Dokumentation: https://pip.pypa.io/
PIP_DEFAULT_OPTIONS=""

# Erstellen der envdir Verzeichnisse
 mkdir -p /var/envdir/absys
 chgrp -R www-data /var/envdir
 chmod -R g=rX,o= /var/envdir

# Django Konfiguration, bitte wie benötigt anpassen.
#
# Python Pfad zum Modul, das die zu benutzenden Django Einstellungen enthält.
echo 'absys.config.settings.public' |  tee /var/envdir/absys/DJANGO_SETTINGS_MODULE

# Name der Klasse, die die zu benutzenden Django Einstellungen enthält.
# Mögliche Werte: Staging oder Production
echo 'Staging' |  tee /var/envdir/absys/DJANGO_CONFIGURATION

# Konfiguration der Datenbank-Verbindung, siehe pg_hba.conf.
# Schema: postgres://BENUTZER:PASSWORT@localhost/DATENBANKNAME
# PASSWORT UNBEDINGT ÄNDERN!
#echo 'postgres://absys:absys@localhost/absys' |  tee /var/envdir/absys/DEFAULT_DATABASE_URL

# Dauer in Sekunden, die die Datenbankverbindung aufrecht gehalten wird.
echo '600' |  tee /var/envdir/absys/DEFAULT_CONN_MAX_AGE

# Geheimer Schlüssel, der für kryptografische Signaturen benutzt wird.
# UNBEDINGT ÄNDERN! - SOLLTE 50 BELIEBIGE ZEICHEN ENTHALTEN.
echo 'INSECURE' |  tee /var/envdir/absys/DJANGO_SECRET_KEY

# E-Mail Adresse, die als Absender für automatische E-Mails benutzt wird.
echo 'noreply@example.com' |  tee /var/envdir/absys/DJANGO_DEFAULT_FROM_EMAIL

# SMTP Host.
# echo 'localhost' |  tee /var/envdir/absys/DJANGO_EMAIL_HOST
# SMTP Passwort.
echo 'INSECURE' |  tee /var/envdir/absys/DJANGO_EMAIL_HOST_PASSWORD

# SMTP User.
echo 'noreply@example.com' |  tee /var/envdir/absys/DJANGO_EMAIL_HOST_USER

# SMTP Port.
# echo '465' |  tee /var/envdir/absys/DJANGO_EMAIL_PORT

# SSL für SMTP benutzen, Port 465.
# echo 'True' |  tee /var/envdir/absys/DJANGO_EMAIL_USE_SSL

# TLS für SMTP benutzen, Port 587.
# echo 'False' |  tee /var/envdir/absys/DJANGO_EMAIL_USE_TLS

# Pfad zum Verzeichnis für alle Uploads, alle Dateien sollten als Backup
# gesichert werden.
echo "${MEDIA}" |  tee /var/envdir/absys/DJANGO_MEDIA_ROOT

# Pfad zum Verzeichnis für statische Dateien, diese ändern sich bei jedem
# Deployment und müssen nicht zwingend als Backup gesichert werden.
echo "${STATIC_ROOT}" |  tee /var/envdir/absys/DJANGO_STATIC_ROOT

# Liste der Hostnamen und Domains, die diese Website ausliefern soll. Hier die
# IP Adresse und/oder den Domainnamen mit Kommata getrennt eintragen.
# Bei fehlerhafter Konfiguration ist "Bad Request (400)" im Browser zu sehen.
#echo "${STATIC_ROOT}127.0.0.1,localhost,172.19.0.5" |  tee /var/envdir/absys/DJANGO_ALLOWED_HOSTS

# Sessionlänge in Sekunden. Nach Ablauf wird der user "ausgeloggt".
# echo "7200" |  tee /var/envdir/absys/DJANGO_SESSION_COOKIE_AGE

# Liste von Administratoren, die über Fehler via E-Mail informiert werden.
# echo "'Ada Lovelace',ada@example.com;'Bea Blue',bea@example.com" |  tee /var/envdir/absys/DJANGO_ADMINS

# Anzahl der Tage, die im aktuellen Monat für rückwirkende Änderungen der
# Anwesenheitsliste im Frontend zur Verfügung stehen.
# echo '15' |  tee /var/envdir/absys/DJANGO_ABSYS_ANWESENHEIT_TAGE_VORMONAT_ERLAUBT

# Möglichkeit zur Deaktivierung der Prüfung des Datums in der
# Anwesenheitsliste im Frontend.
# echo 'True' |  tee /var/envdir/absys/DJANGO_ABSYS_ANWESENHEIT_DATUMSPRUEFUNG

# Anzahl der Tage bis zur Fälligkeit einer Rechnung einer Einrichtung
# echo '31' |  tee /var/envdir/absys/DJANGO_ABSYS_TAGE_FAELLIGKEIT_EINRICHTUNG_RECHNUNG

# Feste Adresse der Schule
# echo 'Musterschule\nMusterstr. 42\n23232 Musterstadt' |  tee /var/envdir/absys/DJANGO_ABSYS_ADRESSE_SCHULE

# Ob das Buchungskennzeichen des Sozialamtes der Sozialamtsrechnung für alle ihre
# Einrichtungsrechnungen verwendet werden soll.
# echo 'False' |  tee /var/envdir/absys/DJANGO_ABSYS_NUTZE_SOZIALAMTS_BUCHUNGSKENNZEICHEN


# Konfiguration der automatierten 'Hintergrundprüfungen'/Benachrichtigungen.
# Anzahl der Buchungskennzeichen die unterschritten werden muss um eine
# 'Buchungskennzeichen gehen aus' Benachrichtigung zu veranlassen.
# echo '30' |  tee /var/envdir/absys/DJANGO_ABSYS_BUCHUNGSKENNZEICHEN_MIN_VERBLEIBEND

# Anzahl der Tage die ein Schüler noch in einer Einrichtung verbleibend ist
# bevor eine Benachrichtigung ausgelöst wird.
# echo '30' |  tee /var/envdir/absys/DJANGO_ABSYS_EINRICHTUNG_MIN_VERBLEIBENDE_TAGE

# Anzahl der Tage für ``EinrichtungHatPflegesatz.pflegesatz_enddatum``
# die wenn unterschritten eine Bennachrichtigung auslöst.
# echo '30' |  tee /var/envdir/absys/DJANGO_ABSYS_EINRICHTUNG_HAT_PFLEGESATZ_MIN_VERBLEIBENDE_TAGE

# Anzahl der Tage für ``Bettengeldsatz.enddatum`` die wenn unterschritten
# eine Bennachrichtigung auslöst.
# echo '30' |  tee /var/envdir/absys/DJANGO_ABSYS_BETTENGELDSATZ_MIN_VERBLEIBENDE_TAGE

# SaxMBS Konfiguration
# SaxMBS Anord-Kz - "J" oder "N"
# echo 'J' |  tee /var/envdir/absys/DJANGO_ABSYS_SAX_ANORDKZ
# SaxMBS Ebene 1 - String, muss acht Stellen haben
# echo '        ' |  tee /var/envdir/absys/DJANGO_ABSYS_SAX_EBENE_1
# SaxMBS Kapitel - Integer, darf maximal fünf Stellen haben; OHNE FÜHRENDE NULLEN ANGEBEN!
# echo '12345' |  tee /var/envdir/absys/DJANGO_ABSYS_SAX_KAPITEL
# SaxMBS Mahnschlüssel - Integer, darf maximal zwei Stellen haben
# echo '10' |  tee /var/envdir/absys/DJANGO_ABSYS_SAX_MAHNSCHLUESSEL
# SaxMBS SEPA - Integer, muss eine Stelle haben
# echo '1' |  tee /var/envdir/absys/DJANGO_ABSYS_SAX_SEPA
# SaxMBS Währung - String, darf maximal drei Stellen haben
# echo 'EUR' |  tee /var/envdir/absys/DJANGO_ABSYS_SAX_WAEHRUNG
# SaxMBS Zahlungsanzeigeschlüssel - Integer, darf maximal zwei Stellen haben
# echo '10' |  tee /var/envdir/absys/DJANGO_ABSYS_SAX_ZAHLUNGSANZEIGESCHLUESSEL
# SaxMBS Zinsschlüssel - Integer, muss eine Stelle haben
# echo '1' |  tee /var/envdir/absys/DJANGO_ABSYS_SAX_ZINSSCHLUESSEL

# Lockdown-Schutz aktivieren/deaktivieren
# echo 'True' |  tee /var/envdir/absys/DJANGO_LOCKDOWN_ENABLED

# Passwort für den Lockdown-Schutz
# echo '1234' |  tee /var/envdir/absys/DJANGO_LOCKDOWN_PASSWORDS

# Berechtigungen korrigieren
 chgrp -R www-data /var/envdir/absys &&  chmod -R g=rX,o= /var/envdir/absys

# Installation/Upgrade AbSys und den abhängigen Paketen. Es werden nur Pakete
# aus ${PACKAGE_PATH} installiert, es findet kein Download statt.
python3 -m pip install ${PIP_DEFAULT_OPTIONS} --force-reinstall --ignore-installed --no-index --find-links ${PACKAGE_PATH} --upgrade absys

