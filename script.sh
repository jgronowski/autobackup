#!/bin/bash
#
# Script for rotation
# Please put this script in cron
#
#


# Global configuration

oldBackups=+1
dates=`date '+%d%m%Y'`
times=`date '+%H:%M'`

# MySQL Configuration

password=password
dbuser=username
dbname=databasename

# APP Path Configuration

applocation=/path/to/folder/with/app

# BACKUP Path Configuration

backup=/path/to/folder/with/backup
sql=$backup/mysql
app=$backup/app

# LOG location

log=/var/log/autobackup.log

if [ ! -e $log ]
then
    touch $log
    echo `date +%d.%m.%Y" "%H:%M:%S` "[INFO] touch $log to keep the logs" >> $log
fi
# Checking if folders exist
if [ ! -d $sql ] || [ ! -d $app ]
then
        mkdir -p $sql $app
        echo `date +%d.%m.%Y" "%H:%M:%S` "[INFO] Folders $sql and $app has been created " >> $log
        # Starting database dump
	cd $sql
	mysqldump -u $dbuser -p$password $dbname | gzip -c > ${dates}"_"BACKUP"_"${times}.gz
	echo `date +%d.%m.%Y" "%H:%M:%S` "[OK] Dump of Mysql has been saved" >> $log
	tar zcfP ${app}'/backup.tar.gz' $applocation
	mv ${app}'/backup.tar.gz' ${app}'/'${dates}"_"BACKUP"_"${times}.tar.gz
	echo `date +%d.%m.%Y" "%H:%M:%S` "[OK] Dump of App has been saved" >> $log
else [ -d $sql ] && [ -d $app ]
        # Starting database dump
	cd $sql
        mysqldump -u $dbuser -p$password $dbname | gzip -c > ${dates}"_"BACKUP"_"${times}.gz
        echo `date +%d.%m.%Y" "%H:%M:%S` "[OK] Dump of Mysql has been saved" >> $log
        tar zcfP ${app}'/backup.tar.gz' $applocation
	mv ${app}'/backup.tar.gz' ${app}'/'${dates}"_"BACKUP"_"${times}.tar.gz
        echo `date +%d.%m.%Y" "%H:%M:%S` "[OK] Dump of App has been saved" >> $log
fi

# Remove files in both location of backup if older then 7 days

counter=`find $backup -maxdepth 2 -mtime $oldBackups | wc -l`
if [ $counter -ge 1 ]
then
	echo `date +%d.%m.%Y" "%H:%M:%S` "[OK] Removed $counter files olders then $oldBackups days" >> $log
	find $backup -maxdepth 2 -mtime $oldBackups -exec rm {} \;
else
	echo `date +%d.%m.%Y" "%H:%M:%S` "[OK] Nothing to clean" >> $log 
fi
