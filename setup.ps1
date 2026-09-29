$ErrorActionPreference = 'Stop'

# ============================================================

# NEXUS DATA EXPLORER

# Environment setup

# ============================================================

# Ensure execution from the project directory.

Set-Location $PSScriptRoot

# Configure UTF-8 for console output.

$utf8 = New-Object System.Text.UTF8Encoding $false
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8

Write-Host '=========================================='
Write-Host ' NEXUS DATA EXPLORER'
Write-Host ' Environment setup'
Write-Host '=========================================='
Write-Host ''

# ============================================================

# SQL EXECUTION

# ============================================================

function Invoke-SqlFile {
param (
[Parameter(Mandatory = $true)]
[string]$File
)


$filePath = (Resolve-Path $File).Path
$fileName = [System.IO.Path]::GetFileName($filePath)
$containerPath = "/tmp/nexus_$fileName"

# Copy the original file without text conversion.
docker cp $filePath "nexus-postgres:$containerPath"

if ($LASTEXITCODE -ne 0) {
    throw "Failed to copy SQL file: $File"
}

try {
    # Execute SQL using UTF-8 client encoding.
    docker exec `
        -e PGCLIENTENCODING=UTF8 `
        nexus-postgres `
        psql -v ON_ERROR_STOP=1 -U nexus -d nexus -f $containerPath

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to execute SQL file: $File"
    }
}
finally {
    # Remove the temporary file from the container.
    docker exec nexus-postgres rm -f $containerPath *> $null
}

}

# ============================================================

# 01. PREREQUISITES

# ============================================================

Write-Host '> Checking prerequisites...'

$requiredCommands = @('docker', 'uv', 'python')

foreach ($command in $requiredCommands) {
if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
Write-Host "ERROR: $command not found." -ForegroundColor Red
exit 1
}
}

docker info *> $null

if ($LASTEXITCODE -ne 0) {
Write-Host 'ERROR: Docker is unavailable.' -ForegroundColor Red
Write-Host 'Check whether Docker Desktop is running.'
exit 1
}

$pythonVersion = python -c "import sys; print('{}.{}'.format(sys.version_info.major, sys.version_info.minor))"

if ($LASTEXITCODE -ne 0) {
throw 'Could not identify Python version.'
}

$versionParts = $pythonVersion.Split('.')
$pythonMajor = [int]$versionParts[0]
$pythonMinor = [int]$versionParts[1]

if (($pythonMajor -lt 3) -or (($pythonMajor -eq 3) -and ($pythonMinor -lt 12))) {
Write-Host "ERROR: Python $pythonVersion found." -ForegroundColor Red
Write-Host 'Python 3.12 or later is required.'
exit 1
}

Write-Host '   OK Docker'
Write-Host '   OK uv'
Write-Host "   OK Python $pythonVersion"
Write-Host ''

# ============================================================

# 02. PYTHON ENVIRONMENT

# ============================================================

Write-Host '> Synchronizing Python environment...'

uv sync

if ($LASTEXITCODE -ne 0) {
throw 'Failed to synchronize Python environment.'
}

Write-Host '   OK Python environment ready.'
Write-Host ''

# ============================================================

# 03. POSTGRESQL

# ============================================================

Write-Host '> Starting PostgreSQL...'

docker compose up -d

if ($LASTEXITCODE -ne 0) {
throw 'Failed to start PostgreSQL.'
}

Write-Host '   OK PostgreSQL container started.'
Write-Host ''

# ============================================================

# 04. WAIT FOR POSTGRESQL

# ============================================================

Write-Host '> Waiting for PostgreSQL...'

$timeoutSeconds = 60
$elapsedSeconds = 0

while ($true) {
    docker exec nexus-postgres pg_isready -U nexus -d nexus *> $null

    if ($LASTEXITCODE -eq 0) {
        break
    }

    if ($elapsedSeconds -ge $timeoutSeconds) {
        throw "PostgreSQL did not become available within $timeoutSeconds seconds."
    }

    Start-Sleep -Seconds 1
    $elapsedSeconds++
}

Write-Host '   OK PostgreSQL available.'
Write-Host ''

# ============================================================

# 05. CREATE SCHEMAS

# ============================================================

Write-Host '> Creating schemas...'

Invoke-SqlFile 'sql/00_criar_schemas.sql'

Write-Host '   OK Schemas created.'
Write-Host ''

# ============================================================

# 06. RAW INGESTION

# ============================================================

Write-Host '> Running RAW ingestion...'

uv run python scripts/ingest_raw.py

if ($LASTEXITCODE -ne 0) {
throw 'RAW ingestion failed.'
}

Write-Host '   OK RAW loaded.'
Write-Host ''

# ============================================================

# 07. DATA WAREHOUSE

# ============================================================

Write-Host '> Building Data Warehouse...'

$sqlFiles = @(
'sql/01_criar_dim_cliente.sql',
'sql/02_criar_dim_produto.sql',
'sql/03_criar_dim_vendedor.sql',
'sql/04_criar_fato_pedido.sql',
'sql/05_criar_fato_review.sql',
'sql/06_criar_fato_item_pedido.sql',
'sql/07_segmentar_produtos.sql',
'sql/08_enriquecer_fato_pedido.sql'
)

foreach ($file in $sqlFiles) {
Write-Host "   > Executing $(Split-Path $file -Leaf)"


Invoke-SqlFile $file


}

Write-Host '   OK Data Warehouse built.'
Write-Host ''

# ============================================================

# 08. VALIDATION

# ============================================================

Write-Host '> Validating Data Warehouse...'

Invoke-SqlFile 'sql/09_validar_dw.sql'

Write-Host ''

# ============================================================

# FINALIZATION

# ============================================================

Write-Host '=========================================='
Write-Host ' NEXUS DATA EXPLORER CONFIGURED' -ForegroundColor Green
Write-Host '=========================================='
Write-Host ''
Write-Host 'PostgreSQL : localhost:5432'
Write-Host 'Database   : nexus'
Write-Host 'User       : nexus'
Write-Host ''
Write-Host 'Environment is ready.'
