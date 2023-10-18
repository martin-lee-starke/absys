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
