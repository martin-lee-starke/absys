#!/bin/bash

touch/var/log/cron.log
crontab/etc/cron.d/container_cronjob

# Reset the crontab file, else the line below will be copied multiple times.
#echo "0 1 * * 1-5 root /pg-backup-scrips/pg_backup.sh" >> /etc/crontab
#echo "* * * * * root /pg-backup-scrips/pg_backup.sh" >> /etc/crontab
#exec ${@}
