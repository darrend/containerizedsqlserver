# Justfile
set windows-powershell := true

status:
    podman compose ps

logs:
    podman compose logs -f

check:
    podman compose run --rm sqlcmd sh /var/opt/sqlcmd/scripts/check.sh

up:
    podman compose up -d

down:
    podman compose down

# this can take a while...like a minute or more
rebuild:
    podman compose down -v
    sleep 10
    podman compose up -d
    sleep 10
    podman compose run --rm sqlcmd sh /var/opt/sqlcmd/scripts/importinspect.sh
    just check
