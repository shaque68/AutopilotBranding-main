[CmdletBinding()]
param()

$tagFile = Join-Path $env:ProgramData 'Microsoft\AutopilotBranding\AutopilotBranding.ps1.tag'
if (Test-Path -Path $tagFile) {
    Write-Output 'Installed'
    exit 0
}

exit 1
