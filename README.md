# containerizedsqlserver

A containerized Microsoft SQL Server environment with automated restore tooling from bak files, designed for local development and testing.

## Features

- **Containerized SQL Server**: Uses Podman Compose to orchestrate SQL Server and related services.
- **Automated Backup Restore**: Includes scripts to inspect `.bak` files and generate SQL restore commands automatically.
- **Task Automation**: Uses a `Justfile` for common operations like starting, stopping, rebuilding containers, and running checks.
- **Cross-platform**: Designed for Windows with PowerShell support, but scripts are Bash-based for container compatibility.

## Usage

### Prerequisites

- Configured for Windows and powershell
- [Podman](https://podman.io/) (or Docker, with adjustments)
- [Just](https://just.systems/) command runner

### Common Commands

- `just up` — Start the SQL Server containers in the background.
- `just down` — Stop and remove the containers.
- `just check` — Run a health check script inside the SQL Server container.
- `just logs` — Follow container logs.
- `just rebuild` — Rebuild containers and re-import backups (can take a minute or more).

### Backup Restore Workflow

1. Place your `.bak` files in the `backups/` directory (ignored by git).
2. Run `just rebuild` to bring up the environment and trigger the import/inspection script. 
3. The script will discard the current database by dropping the persistent volume inspect each backup, generate restore SQL, and attempt to restore databases automatically.

### File Structure

- `Justfile` — Task automation recipes.
- `scripts/importinspect.sh` — Bash script to inspect and restore `.bak` files.
- `backups/` — Place your SQL Server backup files here (not tracked by git).
- `.gitignore` — Ignores environment, backup, and temp files.

## License

MIT License — see [LICENSE](LICENSE) for details.

## AI Usage

This project was created and refined with the assistance of AI tools, including GitHub Copilot and other generative AI technologies. These tools were used to help generate scripts, documentation, and automation logic. All code and documentation have been reviewed and tested by a human before inclusion in this repository. Please review and validate any AI-generated content for your specific use case and environment.

### AI Review Todo
- [ ] completely review [scripts/importinspect.sh](scripts/importinspect.sh)
