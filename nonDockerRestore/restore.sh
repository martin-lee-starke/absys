#!/bin/bash

# ==============================================================================
# Einfaches Script zum kopieren einer Postgres DB zu Testzwecken
# Ohne Zwischenspeicherung (Piping) - Auszuführen als OS-User "postgres"
# ==============================================================================

# Beende das Script sofort bei einem Fehler (auch innerhalb einer Pipe wie bei pg_dump | psql)
set -eo pipefail

# Stelle sicher, dass das Script als User "postgres" ausgeführt wird
if [ "$(whoami)" != "postgres" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - FEHLER: Dieses Script muss als OS-User 'postgres' ausgeführt werden! (Aktuell: $(whoami))"
    exit 1
fi

# ==============================================================================
# CHECKMK MONITORING & LOGGING
# ==============================================================================
# /var/tmp überlebt System-Neustarts (im Gegensatz zu /tmp). 
STATUS_PREFIX="/var/tmp/db_sync_absys"
TMP_LOG="${STATUS_PREFIX}_TEMP.log"

# Bereinige die temporäre Log-Datei vor jedem Start
> "$TMP_LOG"

# Kompletten Output (Echos & Fehler) in TMP_LOG schreiben & gleichzeitig im Terminal anzeigen (via tee)
exec > >(tee -a "$TMP_LOG") 2>&1

# Diese Funktion wird durch "trap" IMMER am Ende aufgerufen (egal ob Erfolg oder Fehler)
update_checkmk_status() {
    local exit_code=$?
    
    # Kleiner Puffer, damit 'tee' alle restlichen Konsolenausgaben in die Datei flushen kann
    sleep 1
    
    # Alte Status-Dateien entfernen
    rm -f "${STATUS_PREFIX}_SUCCESS" "${STATUS_PREFIX}_FAILED"
    
    if [ $exit_code -eq 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Checkmk Status: SUCCESS aktualisiert." >> "$TMP_LOG"
        mv "$TMP_LOG" "${STATUS_PREFIX}_SUCCESS"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Checkmk Status: FAILED aktualisiert (Exit-Code: $exit_code)." >> "$TMP_LOG"
        mv "$TMP_LOG" "${STATUS_PREFIX}_FAILED"
    fi
}
trap update_checkmk_status EXIT
# ==============================================================================

PROD_DB="ABSYS_LFH_PROD"
TEST_DB="ABSYS_LFH_TEST"
TEST_OWNER="absys_lfh_test"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Starte Sync von $PROD_DB nach $TEST_DB..."

# 1. Beende alle aktiven Verbindungen zur Test-DB (sonst schlägt dropdb fehl)
# Wir ignorieren Fehler (|| true), falls die Datenbank noch nicht existiert
psql -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${TEST_DB}' AND pid <> pg_backend_pid();" > /dev/null 2>&1 || true

# 2. Lösche die alte Test-DB
dropdb --if-exists "${TEST_DB}"

# 3. Erstelle eine neue leere Test-DB mit dem gewünschten Owner
createdb -O "${TEST_OWNER}" "${TEST_DB}"

# 4. Streame die Daten direkt aus der Produktion in die Test-DB
# --no-owner & --no-privileges sorgt dafür, dass die Rechte des alten PROD-Users nicht auf TEST übernommen werden
# Ansonsten würde die Django-App als (neuer Test-User) mit "keine Berechtigung" abbrechen.
pg_dump --no-owner --no-privileges "${PROD_DB}" | psql "${TEST_DB}"

# 5. Gebe dem Test-User die uneingeschränkten Rechte auf alle frisch importierten Strukturen (Tabellen, Sequenzen etc.)
# im Standard-Schema (public). Ohne diese Zuordnung würden alle importierten Tabellen sonst "postgres" (dem ausführenden User) gehören.
psql -d "${TEST_DB}" -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${TEST_OWNER};"
psql -d "${TEST_DB}" -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${TEST_OWNER};"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Sync erfolgreich abgeschlossen."