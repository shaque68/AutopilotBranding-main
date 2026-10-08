[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$tagDir = Join-Path $env:ProgramData 'Microsoft\AutopilotBranding'
$tagFile = Join-Path $tagDir 'AutopilotBranding.ps1.tag'
$versionFile = Join-Path $tagDir 'AutopilotBranding.version'

if (Test-Path -Path $tagFile) {
    Remove-Item -Path $tagFile -Force
}

if (Test-Path -Path $versionFile) {
    Remove-Item -Path $versionFile -Force
}

exit 0
