#!/bin/bash
# runsqlfiles.sh: Run all .sql files in /var/opt/sqlcmd/scripts/sql/<DBNAME> against the specified database in sorted order
# Usage: ./runsqlfiles.sh <DBNAME>
# nb: Generated with the help of AI tools, please review and test before use.

if [ $# -ne 1 ]; then
    echo "Usage: $0 <DBNAME>"
    exit 1
fi

dbname="$1"
sql_dir="/var/opt/sqlcmd/scripts/sql/$dbname"

if [ ! -d "$sql_dir" ]; then
    echo "Error: Directory $sql_dir does not exist."
    exit 1
fi

sqlcmd_path="/opt/mssql-tools/bin/sqlcmd"

for sqlfile in $(ls "$sql_dir"/*.sql 2>/dev/null | sort); do
    echo "Running $sqlfile against $dbname..."
    $sqlcmd_path -d "$dbname" -i "$sqlfile"
    if [ $? -ne 0 ]; then
        echo "Error running $sqlfile"
        exit 1
    fi
done

echo "All scripts executed successfully against $dbname."
