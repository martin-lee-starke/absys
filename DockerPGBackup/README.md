# How to Use the Backup Container

## Introduction
The pgbackup container is a very simple container based on Ubuntu 22.04 with Cron and postgresql-client-16 installed. With the postgresql-client-16 it connects via network to the postgres container and runs the backup script with a Cronjob.

## Arm the Backup Script
The backup script that is run by the cronjob has to be located in `/pg-backup-scrips/host`. The cronjob is defined in `/etc/cron.d/container_cronjob`. To allow changes to the backupscript while the Container is running, the directory `/pg-backup-scrips/host` should be mounted to a host directory. Then you need to place the script `pg_backup2.sh` in the host folder. An example for that code is placed in `/pg-backup-scrips/pg_backup2_example.sh`. Copy this file and adjust the variables.

# Use the Restore Script
The restore script plays nicely with the existing backup feature. It gets the backup of the current day and restores the test-db with the data from the backup. You can modify the script to alter the restore taget-db. For the restore process, the script has to drop and recreate the test-db, for that there is a `pgrestore.sql` file in the `/pg-backup-scrips` folder. If you change the restore-db name, you need to alter the name there too! 


### Cronjob
The job runs every Day at 2 AM and starts the backup and restore scripts.
```cron
0 2 * * * /pg-backup-scrips/host/pg_backup2.sh > /proc/1/fd/1 2>/proc/1/fd/2
10 2 27 * * /pg-backup-scrips/host/pg_restore.sh > /proc/1/fd/1 2>/proc/1/fd/2
```

### Backup Example
```bash
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

sqlfile=$backupfolder/${DATABASE_NAME}-$(date +%d-%m-%Y_%H-%M-%S).sql
zipfile=$backupfolder/${DATABASE_NAME}-$(date +%d-%m-%Y_%H-%M-%S).gzip

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

```

### Restore Example