set windows-powershell := true

list:
    just --list
    @Write-Host "Use podman rebuild to set up the containers and import the initial data."
    @Write-Host "Use just up to start the containers in the background."
    @Write-Host "Use just down to stop and remove the containers."
    @Write-Host "Use just check to verify the SQL Server is running and list databases."
    @Write-Host "Use just sqlcmd dbname to drop into a SQLCMD shell for the specified database."
    @Write-Host "Use just runsqlfiles dbname to run SQL files in the specified database."
    

# list running containers
status:
    podman compose ps

# print and follow the logs for the containers
logs:
    podman compose logs -f

# run check.sh to check for running sql server and list databases
check:
    podman compose run --rm sqlcmd sh /var/opt/sqlcmd/scripts/check.sh

# Start the SQL Server containers in the background
up:
    podman compose up -d

# Stop and remove the containers.
down:
    podman compose down

# Rebuild the containers, removing volumes and running the import script. Complete rebuild.
rebuild:
    podman compose down -v
    sleep 10
    podman compose up -d
    sleep 10
    podman compose run --rm sqlcmd sh /var/opt/sqlcmd/scripts/importinspect.sh
    sleep 2
    just runsqlfiles
    sleep 2
    just check


inspect:
    podman compose run --rm sqlcmd sh /var/opt/sqlcmd/scripts/inspect.sh

# run the sql files listed in the sqlcmd/scripts/sql/DBName directory
runsqlfiles dbname="_all_":
    podman compose run --rm sqlcmd sh /var/opt/sqlcmd/scripts/runsqlfiles.sh {{dbname}}

# drop into a sqlcmd shell for the specified database
sqlcmd dbname:
    podman compose run --rm -it sqlcmd /opt/mssql-tools/bin/sqlcmd -d {{dbname}}

# check if a stored procedure exists in the specified database
checkproc dbname procname:
    podman compose run --rm sqlcmd sh /var/opt/sqlcmd/scripts/checkproc.sh {{dbname}} {{procname}}