#!/bin/bash

# Dump path
backupdir="/var/mysqlbackup"
mkdir -p $backupdir

# If not on a directadmin server set user and password here
user=mysqluser
passwd=xxxxxx

# Get directadmin mysql user if present
. /usr/local/directadmin/conf/mysql.conf

# Get all databases
databases=`mysql -u $user -p$passwd -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        echo "Dumping database: $db"
        mkdir -p $backupdir/$db
        tables=`mysql -u $user -p$passwd -N -B -e "SHOW TABLES FROM $db;"`
        for table in $tables; do
            echo "   " $table
            mysqldump --skip-comments -u $user -p$passwd $db $table > $backupdir/$db/$table.sql
        done
    fi
done