#!/bin/bash

#################################
# Constants / global variables
#################################
LOGFILE="/pg-backup-log/pgsql.log"
LOGLEVEL='INFO'
BACKUP_DIR="/pg-backup-dir"
TIMESTAMP=$(date +"%F_%H")
BACKUPFILENAME="pgdump_${TIMESTAMP}.dump.gz"
PGPASSWORD=$PG_PASSWORD

#################################
# Functions
#################################

# Logging functions
function log_output {
  echo `date "+%Y/%m/%d %H:%M:%S"`" $1"
  echo `date "+%Y/%m/%d %H:%M:%S"`" $1" >> $LOGFILE
}

function log_debug {
  if [[ "$LOGLEVEL" =~ ^(DEBUG)$ ]]; then
    log_output "DEBUG $1"
  fi
}

function log_info {
  if [[ "$LOGLEVEL" =~ ^(DEBUG|INFO)$ ]]; then
    log_output "INFO $1"
  fi
}

function log_warn {
  if [[ "$LOGLEVEL" =~ ^(DEBUG|INFO|WARN)$ ]]; then
    log_output "WARN $1"
  fi
}

function log_error {
  if [[ "$LOGLEVEL" =~ ^(DEBUG|INFO|WARN|ERROR)$ ]]; then
    log_output "ERROR $1"
  fi
}

# Some other helper functions
# ...

# Help output
function usage {
  echo
  echo "This is a Bash script template"
  echo "Usage: ./example.sh -l <logfile> -L <loglevel>"
  echo "Example: ./example.sh -l example.log -L INFO"
  echo
}

#################################
# Main
#################################

# Get input parameters
while [[ "$1" != "" ]]; do
  case $1 in
      -l | --logfile )        shift
                              LOGFILE=$1
                              ;;
      -L | --loglevel )       shift
                              LOGLEVEL=$1
                              ;;
      -h | --help )           usage
                              exit
                              ;;
      * )                     usage
                              exit 1
  esac
  shift
done

# Check input parameters and other required conditions

log_info "Starting backup of Postgres to file ${BACKUPFILENAME}"

cd $BACKUP_DIR

# DATABASE_URL Bsp.: postgres://absys:absys@localhost/absys

pg_dump $DATABASE_URL > $BACKUPFILENAME 2>> | log_info
if [ $? -ne 0 -o ${PIPESTATUS[0]} -ne 0 ]; then
    log_error "Backup failed."
    exit 1
else
    log_info Backup complete. >> $logfile
fi

# Check if a param is set to a valid value
if [[ ! "$LOGLEVEL" =~ ^(DEBUG|INFO|WARN|ERROR)$ ]]; then
  log_error "Logging level needs to be DEBUG, INFO, WARN or ERROR."
  exit 1
fi