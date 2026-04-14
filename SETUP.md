# Developer Setup Guide

This guide walks you through setting up the development environment for this project. The recommended approach is the **Docker devcontainer**, which provides a fully reproducible environment with all Snowflake and DB2 dependencies pre-installed.

---

## Prerequisites

| Tool | Purpose |
|---|---|
| Python 3.12+ | Runtime |
| `uv` | Dependency & environment management |
| Git | Version control |
| Docker Desktop | Container runtime (enable WSL2 integration on Windows) |
| VS Code + Dev Containers extension | IDE option (either VS Code or PyCharm) |
| PyCharm Professional + Docker plugin | IDE option (either VS Code or PyCharm) |

---

## Devcontainer Setup (Recommended)

The devcontainer provides a complete, reproducible environment including:

- Python 3.12 with `uv` package manager
- IBM DB2 CLI driver (`clidriver`) at `/opt/ibm/clidriver`
- `snowflake-connector-python` for Snowflake connectivity
- `ibm-db` for DB2 connectivity
- `pytest`, `ruff`, and dev tooling
- VS Code extensions: Python, Pylance, Ruff, SQLTools, Snowflake driver
- PyCharm plugins: Database Tools, .env file support

### Option A: VS Code

1. Install the **Dev Containers** extension
2. Open this repository in VS Code
3. When prompted, click **"Reopen in Container"** (or run `Dev Containers: Reopen in Container` from the command palette)
4. VS Code builds the image and attaches to the running container automatically

### Option B: PyCharm Professional

PyCharm Professional can connect to the devcontainer in two ways:

**Via JetBrains Gateway (devcontainer support):**

1. Install **JetBrains Gateway**
2. Select **Dev Containers** from the connection options
3. Point it to this repository — Gateway reads `.devcontainer/devcontainer.json` and builds the image
4. PyCharm opens inside the container with the correct interpreter and plugins

**Via Docker remote interpreter:**

1. Open this repository in PyCharm Professional
2. Build the image first: `docker build -f .devcontainer/Dockerfile -t productivity-dev .`
3. Go to **Settings > Project > Python Interpreter > Add Interpreter > Docker**
4. Select the `productivity-dev:latest` image
5. Set the interpreter path to `/workspace/.venv/bin/python`
6. Under **Path Mappings**, map your local project root to `/workspace`

> **Note:** Dev Container support requires PyCharm **Professional** edition. Community edition does not support Docker-based interpreters.

### Option C: CLI

```bash
# Build the image
docker build -f .devcontainer/Dockerfile -t productivity-dev .

# Run interactively with the project mounted
docker run -it --rm -v $(pwd):/workspace productivity-dev bash
```

### What the devcontainer does on creation

1. Builds the Docker image (`.devcontainer/Dockerfile`)
2. Installs all Python dependencies including Snowflake, DB2, and dev extras (`uv sync --frozen --all-extras`)
3. Copies `.env.example` to `.env` if `.env` doesn't already exist

### Docker image details

The image is based on `python:3.12-slim` and includes:

| Component | Details |
|---|---|
| Base image | `python:3.12-slim` (Debian) |
| Architecture | x86_64 / AMD64 |
| Python packages | `uv` (latest, via multi-stage copy from `ghcr.io/astral-sh/uv`) |
| System libraries | `libssl-dev`, `libffi-dev`, `libxml2-dev`, `libxslt1-dev`, `libpam0g`, `build-essential`, `curl`, `unzip`, `git` |
| IBM DB2 CLI driver | Downloaded from IBM public CDN, installed at `/opt/ibm/clidriver` |
| Environment variables | `IBM_DB_HOME=/opt/ibm/clidriver`, `LD_LIBRARY_PATH=/opt/ibm/clidriver/lib` |

---

## Local Setup (Without Docker)

If you prefer to develop without Docker, you will need to install the IBM DB2 CLI driver manually.

### Quick Start

#### Linux / macOS / WSL

```bash
bash bootstrap.sh
```

#### Windows (PowerShell)

```powershell
.\bootstrap.ps1
```

The bootstrap script will:
1. Install `uv` if not already present
2. Create a virtual environment and install all dependencies from `uv.lock`
3. Copy `.env.example` to `.env` (if `.env` doesn't exist yet)
4. Validate the DB2 driver installation
5. Run a smoke test to confirm the environment works

### Manual Setup

```bash
# 1. Install uv (Linux/macOS)
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. Install the IBM DB2 CLI driver
curl -fsSL \
  "https://public.dhe.ibm.com/ibmdl/export/pub/software/data/db2/drivers/odbc_cli/linuxx64_odbc_cli.tar.gz" \
  -o /tmp/clidriver.tar.gz
sudo mkdir -p /opt/ibm
sudo tar xzf /tmp/clidriver.tar.gz -C /opt/ibm
rm /tmp/clidriver.tar.gz

# 3. Set environment variables (add to your shell profile)
export IBM_DB_HOME=/opt/ibm/clidriver
export LD_LIBRARY_PATH=$IBM_DB_HOME/lib:$LD_LIBRARY_PATH
export PATH=$IBM_DB_HOME/bin:$PATH

# 4. Install all Python dependencies
uv sync --frozen --all-extras

# 5. Set up environment variables
cp .env.example .env
# Edit .env with your actual credentials

# 6. Run a script
uv run python scripts/smoke_test.py
```

---

## Dependency Management

All dependencies are managed via `uv`. The `uv.lock` file is committed to the repository and ensures everyone gets identical environments.

```bash
# Add a new dependency
uv add <package-name>

# Add an optional/extra dependency
uv add --optional snowflake snowflake-connector-python

# Update all dependencies
uv lock --upgrade

# Sync your environment to the lockfile
uv sync --frozen
```

> **Never** use `pip install` directly — use `uv add` so the lockfile stays up to date.

### Optional Extras

The project defines optional extras for database connectors:

```bash
# Install Snowflake connector only
uv sync --extra snowflake

# Install IBM DB2 driver only
uv sync --extra db2

# Install all extras (recommended)
uv sync --all-extras
```

---

## Environment Variables

Copy `.env.example` to `.env` and fill in your values:

```bash
cp .env.example .env
```

| Variable | Description |
|---|---|
| `SNOWFLAKE_ACCOUNT` | Snowflake account identifier |
| `SNOWFLAKE_USER` | Snowflake username |
| `SNOWFLAKE_PASSWORD` | Snowflake password |
| `SNOWFLAKE_DATABASE` | Target database |
| `SNOWFLAKE_SCHEMA` | Target schema |
| `SNOWFLAKE_WAREHOUSE` | Compute warehouse |
| `SNOWFLAKE_ROLE` | Access role |
| `DB2_HOST` | IBM DB2 hostname |
| `DB2_PORT` | IBM DB2 port (default: 50000) |
| `DB2_DATABASE` | DB2 database name |
| `DB2_USER` | DB2 username |
| `DB2_PASSWORD` | DB2 password |

> `.env` is listed in `.gitignore` — **never commit real credentials**.

---

## Onboarding Timeline

| Phase | Action |
|---|---|
| Week 1 | Clone repo, run devcontainer or `bootstrap.sh`, fill in `.env` |
| Week 2-3 | Explore scripts, run smoke tests, add new dependencies with `uv add` |
| Month 1-2 | Develop against Snowflake and DB2 in the devcontainer |
