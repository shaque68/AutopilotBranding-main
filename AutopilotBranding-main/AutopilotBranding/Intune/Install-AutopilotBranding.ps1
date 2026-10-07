[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$mainScript = Join-Path (Split-Path -Parent $scriptRoot) 'AutopilotBranding.ps1'

if (-not (Test-Path -Path $mainScript)) {
    throw "Main script not found: $mainScript"
}

& "$env:SystemRoot\Sysnative\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File $mainScript
exit $LASTEXITCODE
