#!/bin/bash
# inspect.sh: List information from .bak files in a human-readable format
# Usage: Run inside the container with SQL Server tools installed

backup_dir="/var/opt/mssql/backup"

if [ ! -d "$backup_dir" ]; then
    echo "Error: Backup directory not found! ($backup_dir)"
    exit 1
fi

backup_count=$(find "$backup_dir" -name "*.bak" | wc -l)
if [ "$backup_count" -eq 0 ]; then
    echo "No backup files found in $backup_dir"
    exit 0
fi

echo "Found $backup_count backup files:"
ls -1 "$backup_dir"/*.bak

echo
for bak in "$backup_dir"/*.bak; do
    bakfile=$(basename "$bak")
    echo "\n=== $bakfile ==="
    # Get filelist info and parse it for readability
    filelist=$(/opt/mssql-tools/bin/sqlcmd -Q "RESTORE FILELISTONLY FROM DISK = '$bak'" -W -s "," | tail -n +3)
    if [ -z "$filelist" ]; then
        echo "  (No filelist info found)"
        continue
    fi
    i=1
    echo "$filelist" | while IFS="," read -r LogicalName PhysicalName Type FileGroupName Size MaxSize FileId CreateLSN DropLSN UniqueId ReadOnlyLSN ReadWriteLSN BackupSizeInBytes SourceBlockSize FileGroupId LogGroupGUID DifferentialBaseLSN DifferentialBaseGUID IsReadOnly IsPresent TDEThumbprint SnapshotUrl; do
        # Skip blank/empty lines and lines with only (N rows affected)
        if [ -z "$LogicalName$PhysicalName$Type$Size" ]; then
            continue
        fi
        case "$LogicalName" in
            *rows\ affected*) continue ;;
        esac
        if [ $i -eq 1 ]; then
            echo "  Data file:"
        else
            echo "  Log file:"
        fi
        echo "    Logical Name : $LogicalName"
        echo "    Physical Name: $PhysicalName"
        echo "    Type         : $Type"
        echo "    Size (bytes) : $Size"
        i=$((i+1))
    done
done
