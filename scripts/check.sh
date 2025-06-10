
# This script checks if SQL Server is running and retrieves version and database information.
# Use it to verify the SQL Server instance status and list databases.
# nb: Generated with the help of AI tools, please review and test before use.

/opt/mssql-tools/bin/sqlcmd -Q "SELECT @@VERSION" -o /tmp/sql_version.txt
if [ $? -ne 0 ]; then
    echo "SQL Server is not running or not accessible."
    exit 1
fi
echo "SQL Server version information:"
cat /tmp/sql_version.txt
echo "Checking for databases..."
/opt/mssql-tools/bin/sqlcmd -Q "SELECT name FROM sys.databases" -o /tmp/databases.txt
if [ $? -ne 0 ]; then
    echo "Failed to retrieve database list."
    exit 1
fi
echo "Databases found:"
cat /tmp/databases.txt
