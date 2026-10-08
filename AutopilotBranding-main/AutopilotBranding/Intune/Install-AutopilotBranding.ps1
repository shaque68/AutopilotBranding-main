[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$packageVersion = '3.3.1'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$mainScript = Join-Path (Split-Path -Parent $scriptRoot) 'AutopilotBranding.ps1'
$tagDir = Join-Path $env:ProgramData 'Microsoft\AutopilotBranding'
$tagFile = Join-Path $tagDir 'AutopilotBranding.ps1.tag'
$versionFile = Join-Path $tagDir 'AutopilotBranding.version'

if (-not (Test-Path -Path $mainScript)) {
    throw "Main script not found: $mainScript"
}

& "$env:SystemRoot\Sysnative\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File $mainScript
$mainExitCode = $LASTEXITCODE

if ($mainExitCode -eq 0) {
    Set-Content -Path $versionFile -Value $packageVersion -Force
}

exit $mainExitCode
