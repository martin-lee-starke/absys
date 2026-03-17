# PostgreSQL Sync-Skript (Prod -> Test)

Dieses Verzeichnis enthält das Skript `backup.sh` zum automatisierten Replizieren (Spiegeln) der Produktionsdatenbank in die Testdatenbank.

## Funktionsweise
Das Skript nutzt direktes *Piping* (`pg_dump | psql`), was bedeutet, dass der Export *ohne* Zwischenspeicherung auf der Festplatte erfolgt (minimaler Speicher- und I/O-Overhead).

Da die Testdatenbank anderen Benutzern gehört als die Produktionsumgebung (`absys_lfh_test` vs. `absys_lfh_prod`), tut das Skript Folgendes:
1. Trennen aller aktiven Test-Verbindungen.
2. Droppen und neu Erstellen der Test-Datenbank.
3. Streamen der Daten **ohne** die alten Eigentümer- und Rechteinformationen (`--no-owner`, `--no-privileges`).
4. Verteilung pauschaler Rechte (`GRANT ALL PRIVILEGES...`) auf das `public` Schema an den Test-User.

## Warum "postgres" User?
Das Skript **muss zwingend** als Linux-Systembenutzer `postgres` ausgeführt werden.
Dies hat zwei Hauptgründe:
1. Der `postgres` User ist der Superuser der Datenbank. Wenn man das Skript unter diesem Account (via Socket/Peer Authentication) ausführt, entfällt das unsichere Hinterlegen von Datenbankpasswörtern in Skripten oder `.pgpass` Dateien.
2. Es garantiert volle Zugriffsrechte beim "Droppen" der Datenbanken und dem Beenden fremder Prozesse (`pg_terminate_backend`).

## Cronjob Einrichtung
Damit der Cronjob den richtigen Kontext hat (die Datenbankberechtigungen von `postgres`), liegt der Cron-Eintrag nicht systemweit in `/etc/crontab`, sondern **direkt in der crontab des Users `postgres`**.

Die aktuellen Cronjobs für dieses Skript können wie folgt eingesehen oder bearbeitet werden:

> **Ansehen:** `sudo -u postgres crontab -l`  
> **Bearbeiten:** `sudo -u postgres crontab -e`

### Beispiel für den Cron-Eintrag
Führt das Skript jeden 27. des Monats um 02:10 Uhr aus:
```cron
10 2 27 * * /pfad/zu/backup.sh > /dev/null 2>&1
```

## Monitoring / Checkmk
Die erfolgreiche oder fehlerhafte Ausführung wird nahtlos an Checkmk weitergegeben.
Das Skript schöpft sämtliche Ausgaben (via `tee`) ab und erstellt je nach Exit-Code am Ende eine Log-Datei im Verzeichnis `/var/tmp/`:

* **Im Erfolgsfall:** `/var/tmp/db_sync_absys_SUCCESS`
* **Im Fehlerfall:** `/var/tmp/db_sync_absys_FAILED`

In Checkmk gibt es entsprechende "Fileinfo" Regeln (Age/Size Check), die Alarm schlagen, wenn die `FAILED` Datei existiert oder die `SUCCESS` Datei zu alt ist (d.h. der Cronjob lange nicht ausgeführt wurde). In den Dateien selbst ist das exakte Logbuch der Ausführung enthalten.