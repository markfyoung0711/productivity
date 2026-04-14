# productivity
python productivity techniques

## Quick Start with Docker (Recommended)

The project includes a devcontainer with all dependencies (Python 3.12, DB2 CLI driver, Snowflake connector) pre-installed.

### VS Code

1. Install the **Dev Containers** extension (`ms-vscode-remote.remote-containers`)
2. Open this repository in VS Code
3. Reopen in the container — do one of:
   - Click the blue `><` icon in the bottom-left corner → **Reopen in Container**
   - Or press `Ctrl+Shift+P` → type `Dev Containers: Reopen in Container`
4. VS Code will build the Docker image, start the container with your repo mounted at `/workspace`, install the configured extensions (Python, Pylance, Ruff, SQLTools), and connect your editor to the container

Your git repo stays on the host — VS Code bind-mounts it into the container, so commits, branches, and history all work normally.

### PyCharm Professional

**Option A: JetBrains Gateway (recommended — full container experience including terminal)**

1. Install **JetBrains Gateway** (separate application from PyCharm)
2. Select **Dev Containers** from the connection options
3. Point it to this repository — Gateway reads `.devcontainer/devcontainer.json` and builds the image
4. PyCharm opens inside the container with the correct interpreter, plugins, and terminal
5. The built-in terminal runs inside the container, so all tools (`uv`, `pytest`, `ruff`, DB2 CLI) are available

Your git repo stays on the host — Gateway bind-mounts it into the container, so commits, branches, and history all work normally.

**Option B: Docker remote interpreter (terminal stays on host)**

1. Open this repository in PyCharm Professional
2. Build the image first: `./scripts/build-docker.sh`
3. Go to **Settings → Project → Python Interpreter → Add Interpreter → Docker**
4. Select the `productivity-dev:latest` image
5. Set the interpreter path to `/opt/venv/bin/python`
6. Under **Path Mappings**, map your local project root to `/workspace`

> **Note:** With Option B, code completion and run configurations use the container, but the built-in terminal remains on your host. Use Option A if you need `pytest`, `ruff`, and other container tools in the terminal. Dev Container support requires PyCharm **Professional** edition.

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
