#!/bin/bash
# bootstrap.sh — Linux / macOS / WSL onboarding script
# Usage: bash bootstrap.sh
set -e

echo ">>> Installing uv if not present..."
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Reload PATH so the newly installed uv is found
    export PATH="$HOME/.local/bin:$PATH"
fi

echo ">>> uv $(uv --version)"

echo ">>> Syncing dependencies from lockfile..."
uv sync --frozen

echo ">>> Copying .env.example to .env if not present..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "  .env created — fill in your credentials before continuing."
else
    echo "  .env already exists, skipping."
fi

echo ">>> Validating DB2 driver..."
uv run python -c "import ibm_db; print('DB2 driver OK')" 2>/dev/null \
    || echo "  WARNING: ibm_db not available. Install the db2 extra with: uv sync --extra db2"

echo ">>> Running smoke test..."
uv run python scripts/smoke_test.py

echo ""
echo "Bootstrap complete. Run 'uv run python <script.py>' to execute scripts."
