# productivity
python productivity techniques

## Quick Start with Docker (Recommended)

The project includes a devcontainer with all dependencies (Python 3.12, DB2 CLI driver, Snowflake connector) pre-installed.

### VS Code

1. Install the **Dev Containers** extension
2. Open this repository in VS Code
3. Click **"Reopen in Container"** when prompted

### PyCharm Professional

1. Install **JetBrains Gateway**
2. Select **Dev Containers** and point it to this repository

### CLI

```bash
# Build the image
./scripts/build-docker.sh

# Run interactively with the project mounted
docker run -it --rm -v $(pwd):/workspace productivity-dev bash
```

See [SETUP.md](SETUP.md) for full setup details, local (non-Docker) setup, dependency management, and environment variable configuration. SETUP.md also serves as the specification for regenerating this project's development environment and infrastructure.

## Running tests

Tests are written with **pytest** and managed through `uv`.

```bash
# Install dev dependencies (includes pytest)
uv sync --extra dev

# Run the full test suite
uv run pytest

# Run with verbose output
uv run pytest -v
```
