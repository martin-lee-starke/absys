# Datenbank für Absys
Die Django App benötigt eine PostgressSQL Datenbank die auf einem Server mit passender Version laufen muss. Die Version ist vom aktuellen Stand der Datenbank abhänig.

Um die Datenbank aufzustezten kann entweder eine neue Datenbank erstellt werden oder ein bestehendes Backup eingespielt werden. 

Beim Ausrollen von Absys als Docker Container muss der Connection String für die Datenbank als ENV-Variable übergeben werden.
Bsp.:`DEFAULT_DATABASE_URL=postgres://absys:absys@875128a60a85/absys`

## Anlegen der Datenbank
### Komplett neue Datenbank anlegen
1. Anlegen des Users absys 
``` bash
sudo -u postgres psql -d postgres -c "CREATE USER \"absys\" WITH PASSWORD 'absys' CREATEDB;"
```
2. Anlegen der Datenbank absys mit dem owner absys
``` bash
sudo -u postgres createdb -l en_US.UTF-8 -E UTF8 -O absys -T template0 -e absys
```
wenn keine Daten vorhanden sind kann ab hier Absys genutzt werden.

Alle Datenbanken anzeigen:
```bash
psql -l 
```
### Datenbankbestand aus Backup einspielen
3. Backup File auf Server oder in Container kopieren
4. Datenstand in Datenbank importieren
```bash
sudo psql -u absys -d absys -f backup.sql
```

## Backup der Datenbank mit Backup Container
Der Backup Container führt einen einfachen psql dump aus.
```bash
pg_dump backup.sql absys
```

>Damit der Backup-Container funktioniert muss der User absys in der Gruppe `createdb` sein!!!

mit psql befehl:
```sql
alter user absys createdb;
```