[CmdletBinding()]
param()

$expectedVersion = '3.3.1'
$tagDir = Join-Path $env:ProgramData 'Microsoft\AutopilotBranding'
$versionFile = Join-Path $tagDir 'AutopilotBranding.version'

if (Test-Path -Path $versionFile) {
    $installedVersion = Get-Content -Path $versionFile -ErrorAction SilentlyContinue
    if ($installedVersion -eq $expectedVersion) {
        Write-Output "Installed (v${installedVersion})"
        exit 0
    } else {
        Write-Output "Version mismatch: installed v${installedVersion}, expected v${expectedVersion}"
        exit 1
    }
}

exit 1
