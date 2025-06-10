#!/bin/bash

# importinspect.sh: Inspect .bak files and generate restore commands automatically
# This script is designed to run in a Docker container with SQL Server tools installed.
# It inspects backup files in /var/opt/mssql/backup, extracts logical file names,
# and generates a SQL script to restore them as databases.
# Usage: Place this script in the container and run it to generate restore commands that is then executed.
# nb: Generated with the help of AI tools, please review and test before use.

echo "Starting backup inspection script..."

# Check if backup directory exists
if [ ! -d "/var/opt/mssql/backup" ]; then
    echo "Error: Backup directory not found!"
    exit 1
fi

# Count backup files
backup_count=$(find /var/opt/mssql/backup -name "*.bak" | wc -l)
if [ "$backup_count" -eq 0 ]; then
    echo "No backup files found in /var/opt/mssql/backup"
    exit 0
fi

echo "Found $backup_count backup files to inspect"

# Create a temporary SQL script
restore_sql="/tmp/restore_backups.sql"
echo "PRINT 'Starting backup imports...'" > "$restore_sql"
echo "GO" >> "$restore_sql"

for bak in /var/opt/mssql/backup/*.bak; do
    bakfile=$(basename "$bak")
    dbname="${bakfile%.bak}"
    echo "Inspecting $bakfile for logical file names..."
    # Get logical names using RESTORE FILELISTONLY
    filelist=$( /opt/mssql-tools/bin/sqlcmd -Q "RESTORE FILELISTONLY FROM DISK = '$bak'" -s "," -W | tail -n +3 )
    mdf_logical=$(echo "$filelist" | awk -F, 'NR==1 {gsub(/^[ \t]+|[ \t]+$/, "", $1); print $1}')
    ldf_logical=$(echo "$filelist" | awk -F, 'NR==2 {gsub(/^[ \t]+|[ \t]+$/, "", $1); print $1}')
    if [ -z "$mdf_logical" ] || [ -z "$ldf_logical" ]; then
        echo "Could not determine logical names for $bakfile, skipping."
        continue
    fi
    echo "PRINT 'Restoring $bakfile as database $dbname...'" >> "$restore_sql"
    echo "RESTORE DATABASE [$dbname] FROM DISK = '/var/opt/mssql/backup/$bakfile' WITH MOVE '$mdf_logical' TO '/var/opt/mssql/data/${dbname}.mdf', MOVE '$ldf_logical' TO '/var/opt/mssql/data/${dbname}_log.ldf', REPLACE" >> "$restore_sql"
    echo "GO" >> "$restore_sql"
done

echo "Restore script generated at $restore_sql."
/opt/mssql-tools/bin/sqlcmd -i $restore_sql
