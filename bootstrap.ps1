# bootstrap.ps1 - Windows onboarding script
# Usage: .\bootstrap.ps1
#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host ">>> Installing uv if not present..."
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    irm https://astral.sh/uv/install.ps1 | iex
}

Write-Host ">>> uv $(uv --version)"

Write-Host ">>> Syncing dependencies from lockfile..."
uv sync --frozen

Write-Host ">>> Copying .env.example to .env if not present..."
if (-not (Test-Path .env)) {
    Copy-Item .env.example .env
    Write-Host "  .env created -- fill in your credentials before continuing."
} else {
    Write-Host "  .env already exists, skipping."
}

Write-Host ">>> Validating DB2 driver..."
try {
    uv run python -c "import ibm_db; print('DB2 driver OK')"
} catch {
    Write-Warning "ibm_db not available. Install the db2 extra with: uv sync --extra db2"
}

Write-Host ">>> Running smoke test..."
uv run python scripts/smoke_test.py

Write-Host ""
Write-Host "Bootstrap complete. Run 'uv run python <script.py>' to execute scripts."
