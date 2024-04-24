#!/bin/bash

# Database name
DATABASE_NAME="absys2"
DATABASE_RESTORE_NAME="ABSYSTEST"
DATABASE_HOST="absys-master-db-1"

DATABASE_URL_CONNECT="postgres://absys:absys@${DATABASE_HOST}/${DATABASE_NAME}"
DATABASE_URL="postgres://absys:absys@${DATABASE_HOST}/${DATABASE_RESTORE_NAME}"
echo "${DATABASE_URL}"
 

# Backup storage directory 
backupfolder="/pg-backup-dir"
scriptsfolder="/pg-backup-scrips"

# Number of days to store the backup 
#keep_day=14

#Logfile
Logfile="/pg-backup-log/${DATABASE_RESTORE_NAME}-restore.log"
Loglevel="INFO"

cleanfile=$scriptsfolder/pgrestore.sql
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

# Decompress backup 
if gzip -d -c $zipfile > $sqlfile; then
   log_info "The ${zipfile} was successfully decompressed"
else
   log_error "Error decompressing ${zipfile}, Backup was not restored!"
   log_error "------------- ERROR ------------------"
   rm $sqlfile
   exit
fi

# Clear Database
if psql -d $DATABASE_URL_CONNECT --set ON_ERROR_STOP=on -f $cleanfile; then
   log_info "Database ${DATABASE_RESTORE_NAME} cleaned"
else
   log_error "${DATABASE_RESTORE_NAME} returned non-zero code, databese not cleaned!"
   log_error "------------- ERROR ------------------"
   rm $sqlfile
   exit
fi

# Restore Backup
if psql -d $DATABASE_URL --set ON_ERROR_STOP=on -f $sqlfile; then
   log_info "Database ${DATABASE_NAME} to ${DATABASE_RESTORE_NAME} restored"
else
   log_error "restore ${sqlfile} returned non-zero code, no backup was restored!"
   log_error "------------- ERROR ------------------"
   rm $sqlfile
   exit
fi

rm $sqlfile 
log_info "Backup was successfully restored"


log_info "------------- SUCCESS ------------------"
