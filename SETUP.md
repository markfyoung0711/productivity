# Developer Setup Guide

This guide walks you through setting up the development environment for this project using [`uv`](https://docs.astral.sh/uv/) — the modern Python package and environment manager.

---

## Prerequisites

| Tool | Purpose |
|---|---|
| Python 3.11+ | Runtime |
| `uv` | Dependency & environment management |
| Git | Version control |
| Docker (optional) | Devcontainer support |

---

## Quick Start

### Linux / macOS / WSL

```bash
bash bootstrap.sh
```

### Windows (PowerShell)

```powershell
.\bootstrap.ps1
```

The bootstrap script will:
1. Install `uv` if not already present
2. Create a virtual environment and install all dependencies from `uv.lock`
3. Copy `.env.example` → `.env` (if `.env` doesn't exist yet)
4. Validate the DB2 driver installation
5. Run a smoke test to confirm the environment works

---

## Manual Setup

If you prefer to run steps individually:

```bash
# 1. Install uv (Linux/macOS)
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. Install dependencies (exact versions from lockfile)
uv sync --frozen

# 3. Set up environment variables
cp .env.example .env
# Edit .env with your actual credentials

# 4. Run a script
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

---

## Optional Extras

The project defines optional extras for database connectors:

```bash
# Install Snowflake connector
uv sync --extra snowflake

# Install IBM DB2 driver
uv sync --extra db2

# Install all extras
uv sync --all-extras
```

---

## Devcontainer (VS Code / GitHub Codespaces)

Open the repository in VS Code and click **"Reopen in Container"** when prompted. The devcontainer will:

- Build the Docker image with `uv` pre-installed
- Run `uv sync --frozen` automatically on creation
- Copy `.env.example` → `.env` if needed

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
| Week 1 | Clone repo, run `bootstrap.sh`, fill in `.env` |
| Week 2–3 | Explore scripts, run smoke tests, add new dependencies with `uv add` |
| Month 1–2 | Use devcontainer for a fully reproducible environment |
