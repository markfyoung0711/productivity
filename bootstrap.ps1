# bootstrap.ps1 - Windows onboarding script
# Usage: .\bootstrap.ps1
#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host ">>> Installing uv if not present..."
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    irm https://astral.sh/uv/install.ps1 | iex
    $uvBin = Join-Path $env:USERPROFILE ".local\bin"
    if (Test-Path $uvBin) {
        $env:Path = "$uvBin;$env:Path"
    }
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

Write-Host ">>> Installing IBM DB2 CLI driver if not present..."
$db2Home = "C:\IBM\clidriver"
if (-not (Test-Path $db2Home)) {
    $db2Url = "https://public.dhe.ibm.com/ibmdl/export/pub/software/data/db2/drivers/odbc_cli/ntx64_odbc_cli.zip"
    $db2Zip = Join-Path $env:TEMP "ntx64_odbc_cli.zip"
    Write-Host "  Downloading DB2 CLI driver..."
    Invoke-WebRequest -Uri $db2Url -OutFile $db2Zip -UseBasicParsing
    Write-Host "  Extracting to C:\IBM..."
    New-Item -ItemType Directory -Path "C:\IBM" -Force | Out-Null
    Expand-Archive -Path $db2Zip -DestinationPath "C:\IBM" -Force
    Remove-Item $db2Zip
    Write-Host "  DB2 CLI driver installed at $db2Home"
} else {
    Write-Host "  DB2 CLI driver already installed at $db2Home"
}
$env:IBM_DB_HOME = $db2Home
$env:Path = "$db2Home\bin;$env:Path"

Write-Host ">>> Installing ibm-db Python package..."
uv sync --frozen --extra db2

Write-Host ">>> Validating DB2 driver..."
try {
    uv run python -c "import ibm_db; print('DB2 driver OK')"
} catch {
    Write-Warning "ibm_db import failed. The driver may require Visual C++ Redistributable."
}

Write-Host ">>> Running smoke test..."
uv run python scripts/smoke_test.py

Write-Host ""
Write-Host "Bootstrap complete. Run 'uv run python <script.py>' to execute scripts."
