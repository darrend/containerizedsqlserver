#!/bin/bash
# checkproc.sh: Check for the existence of a stored procedure in a given database
# Usage: ./checkproc.sh <DBNAME> <PROCNAME>\
# nb: Generated with the help of AI tools, please review and test before use.

if [ $# -ne 2 ]; then
    echo "Usage: $0 <DBNAME> <PROCNAME>"
    exit 1
fi

dbname="$1"
procname="$2"

sqlcmd_path="/opt/mssql-tools/bin/sqlcmd"

# Query to check for the stored procedure
query="IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'${procname}') AND type IN (N'P', N'PC'))
    PRINT 'EXISTS'
ELSE
    PRINT 'NOT FOUND'"

result=$($sqlcmd_path -d "$dbname" -Q "$query" -h -1 -W | grep -E 'EXISTS|NOT FOUND')

echo "Stored procedure $procname in database $dbname: $result"

if [ "$result" = "EXISTS" ]; then
    exit 0
else
    exit 2
fi
