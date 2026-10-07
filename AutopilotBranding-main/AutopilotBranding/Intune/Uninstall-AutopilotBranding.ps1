[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$tagFile = Join-Path $env:ProgramData 'Microsoft\AutopilotBranding\AutopilotBranding.ps1.tag'
if (Test-Path -Path $tagFile) {
    Remove-Item -Path $tagFile -Force
}

exit 0
