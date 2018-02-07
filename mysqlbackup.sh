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

verbose=0

while getopts "vVh" opt; do
    case $opt in
        v) verbose=1 ;;
        V) verbose=2 ;;
        h) echo "Usage: $0 [-v | -V]

-v   verbose (show database name)
-V   more verbose (show table name too)"; exit ;;
       \?) echo "Invalid option: -$OPTARG" >&2 ;;
    esac
done

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        if (( $verbose>=1 )) ; then
            echo "Dumping database: $db"
        fi
        mkdir -p $backupdir/$db
        tables=`mysql -u $user -p$passwd -N -B -e 'SHOW TABLES FROM \`'$db'\`;'`
        for table in $tables; do
            if (( $verbose>=2 )) ; then
                echo - $table
            fi
            mysqldump --skip-comments -u $user -p$passwd $db $table > $backupdir/$db/$table.sql
        done
    fi
done