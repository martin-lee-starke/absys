# Liste der Hostnamen und Domains, die diese Website ausliefern soll. Hier die
# IP Adresse und/oder den Domainnamen mit Kommata getrennt eintragen.
# Bei fehlerhafter Konfiguration ist "Bad Request (400)" im Browser zu sehen.
echo "${DJANGO_ALLOWED_HOSTS}" |  tee /var/envdir/absys/DJANGO_ALLOWED_HOSTS

# Konfiguration der Datenbank-Verbindung, siehe pg_hba.conf.
# Schema: postgres://BENUTZER:PASSWORT@localhost/DATENBANKNAME
# PASSWORT UNBEDINGT ÄNDERN!
# postgres://absys:absys@localhost/absys
echo "${DEFAULT_DATABASE_URL}" |  tee /var/envdir/absys/DEFAULT_DATABASE_URL

# Deployment Check, Datenbank Migration und Sammeln der statischen Dateien.
 envdir /var/envdir/absys manage.py check --deploy
 envdir /var/envdir/absys manage.py migrate
 envdir /var/envdir/absys manage.py collectstatic --noinput
 /etc/init.d/apache2 restart

# Täglichen cron job für Benachrichtigungen anlegen
echo -e "#! /bin/sh\nenvdir /var/envdir/absys manage.py benachrichtige" |  tee /etc/cron.daily/absys_benachrichtigungen
 chmod +x /etc/cron.daily/absys_benachrichtigungen

set +o verbose

echo
echo "###############################################################################################"
echo
echo "Installation abgeschlossen"
echo
echo "Folgende Umgebungsvariablen werden JETZT in /var/envdir/absys zur Konfiguration benutzt:"
echo
 ls -1 /var/envdir/absys
echo
echo "Es wurde ein neuer täglicher cron job unter /etc/cron.daily/absys_benachrichtigungen hinzugefügt!"
echo
echo "Nach der initialen Installation folgenden Befehle ausführen, um die Daten für das"
echo "Website Model zu laden und einen neuen Superuser zu erstellen:"
echo
echo " envdir /var/envdir/absys manage.py loaddata sites"
echo " envdir /var/envdir/absys manage.py createsuperuser"
echo
echo "Danach kann man sich mit dem Superuser anmelden und weitere Benutzer erstellen."
echo "Außerdem sollte der Domainname der importierten Website im Admin (Verwaltung) angepasst werden."
echo
echo "###############################################################################################"

envdir /var/envdir/absys manage.py loaddata sites
