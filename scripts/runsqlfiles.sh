#!/bin/bash
# runsqlfiles.sh: Run all .sql files in /var/opt/sqlcmd/scripts/sql/<DBNAME> or all DBNAMEs if _all_ is specified
# Usage: ./runsqlfiles.sh <DBNAME|_all_>
# nb: Generated with the help of AI tools, please review and test before use.

if [ $# -ne 1 ]; then
    echo "Usage: $0 <DBNAME|_all_>"
    exit 1
fi

dbname="$1"
sql_base_dir="/var/opt/sqlcmd/scripts/sql"
sqlcmd_path="/opt/mssql-tools/bin/sqlcmd"

dbs=""
if [ "$dbname" = "_all_" ]; then
    for d in "$sql_base_dir"/*; do
        if [ -d "$d" ]; then
            dbs="$dbs $(basename "$d")"
        fi
    done
else
    dbs="$dbname"
fi

for db in $dbs; do
    sql_dir="$sql_base_dir/$db"
    if [ ! -d "$sql_dir" ]; then
        echo "Error: Directory $sql_dir does not exist. Skipping."
        continue
    fi
    found_files=0
    for sqlfile in $(ls "$sql_dir"/*.sql 2>/dev/null | sort); do
        found_files=1
        echo "Running $sqlfile against $db..."
        $sqlcmd_path -d "$db" -i "$sqlfile"
        if [ $? -ne 0 ]; then
            echo "Error running $sqlfile"
            exit 1
        fi
    done
    if [ $found_files -eq 1 ]; then
        echo "All scripts executed successfully against $db."
    else
        echo "No .sql files found for $db."
    fi
done
