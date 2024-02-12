#!/bin/bash
# This script will backup the postgresql database
# and store it in a specified directory

# Constants


TIMESTAMP=$(date +"%F_%H")
BACKUP_DIR="/pg-backup-dir"

BACKUPFILENAME="pgdump_${TIMESTAMP}.dump.gz"

logfile="/pg-backup-log/pgsql.log"
cmklogfile="/pg-backup-log/cmklog.log"
touch $logfile
# Date stamp (formated YYYYMMDD)
# just used in file name
CURRENT_DATE=$(date "+%Y%m%d")
 
echo "Starting backup of Pg to file ${BACKUPFILENAME}" >> $logfile

cd $BACKUP_DIR
PGPASSWORD=$PG_PASSWORD
# DATABASE_URL Bsp.: postgres://absys:absys@localhost/absys
pg_dump $DATABASE_URL > $BACKUPFILENAME 2>> $logfile
if [ $? -ne 0 -o ${PIPESTATUS[0]} -ne 0 ]; then
    echo "Backup failed." >> $logfile
    echo "Backup ({$BACKUPFILENAME}) failed." >> $cmklogfile
    exit 1
else
    echo Backup complete. >> $logfile
    echo "Backup ({$BACKUPFILENAME}) complete." >> $cmklogfile
fi

# Delete old Backkupfiles
#echo "Deleting fils 'pgdump_*.gz' older than 5 days."
#find ./pgdump_*.gz -mtime +5 -exec rm {} \;
#echo "Done."