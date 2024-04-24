#!/bin/bash

# Database name
DATABASE_NAME="LFHPROD"
DATABASE_HOST="absys-db-lfh"

DATABASE_URL="postgres://absys:absys@${DATABASE_HOST}/${DATABASE_NAME}"
echo "${DATABASE_URL}"
 

# Backup storage directory 
backupfolder="/pg-backup-dir"

# Number of days to store the backup 
keep_day=14

#Logfile
Logfile="/pg-backup-log/${DATABASE_NAME}.log"
Loglevel="INFO"

sqlfile=$backupfolder/${DATABASE_NAME}-$(date +%d-%m-%Y).sql
zipfile=$backupfolder/${DATABASE_NAME}-$(date +%d-%m-%Y).gz

# --------------------------------------------------------------------
# Logging functions
function log_output {
  echo `date "+%Y/%m/%d %H:%M:%S"`" $1";
  echo `date "+%Y/%m/%d %H:%M:%S"`" $1" >> $Logfile;
}

function log_debug {
  if [[ "$Loglevel" =~ ^(DEBUG)$ ]]; then
    log_output "DEBUG $1";
  fi
}

function log_info {
  if [[ "$Loglevel" =~ ^(DEBUG|INFO)$ ]]; then
    log_output "INFO $1";
  fi
}

function log_warn {
  if [[ "$Loglevel" =~ ^(DEBUG|INFO|WARN)$ ]]; then
    log_output "WARN $1";
  fi
}

function log_error {
  if [[ "$Loglevel" =~ ^(DEBUG|INFO|WARN|ERROR)$ ]]; then
    log_output "ERROR $1";
  fi
}

# Create a backup

if pg_dump $DATABASE_URL > $sqlfile ; then
   log_info "Sql dump created"
else
   log_error "pg_dump return non-zero code, no backup was created!"
   log_error "------------- ERROR ------------------"
   rm $sqlfile
   exit
fi

# Compress backup 
if gzip -c $sqlfile > $zipfile; then
   log_info "The backup was successfully compressed"
else
   log_error "Error compressing backup, Backup was not created!"
   log_error "------------- ERROR ------------------"
   rm $zipfile 
   exit
fi

rm $sqlfile 
log_info "${zipfile} : Backup was successfully created"

# Delete old backups 
log_info "Deleting Backups older than $keep_day days."
find $backupfolder -mtime +$keep_day -delete

log_info "------------- SUCCESS ------------------"
