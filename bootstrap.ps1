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

Write-Host ">>> Installing ibm-db Python package (bundles DB2 CLI driver)..."
uv sync --frozen --extra db2

# The ibm-db wheel bundles clidriver inside site-packages. Python 3.8+ requires
# the DLL directory to be on PATH for native extensions to load.
$clidriver = uv run python -c "import importlib.util, os; spec = importlib.util.find_spec('ibm_db'); print(os.path.join(os.path.dirname(os.path.dirname(spec.origin)), 'clidriver', 'bin'))" 2>$null
if ($clidriver -and (Test-Path $clidriver)) {
    $env:Path = "$clidriver;$env:Path"
    $env:IBM_DB_HOME = (Split-Path $clidriver)
    Write-Host "  Using bundled clidriver at $(Split-Path $clidriver)"
}

Write-Host ">>> Validating DB2 driver..."
try {
    uv run python -c "import ibm_db; print('DB2 driver OK')"
} catch {
    Write-Warning "ibm_db import failed. You may need the Visual C++ Redistributable: https://aka.ms/vs/17/release/vc_redist.x64.exe"
}

Write-Host ">>> Running smoke test..."
uv run python scripts/smoke_test.py

Write-Host ""
Write-Host "Bootstrap complete. Run 'uv run python <script.py>' to execute scripts."
