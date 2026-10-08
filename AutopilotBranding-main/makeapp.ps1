[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)] [string] $SourceFolder,
    [Parameter(Mandatory = $True)] [string] $SetupFile,
    [Parameter(Mandatory = $False)] [string] $OutputFolder = ""
)

$ErrorActionPreference = 'Stop'

# Auto-sync version from main script to Intune wrappers
function Sync-PackageVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $SourceFolder
    )

    $mainScript = Join-Path $SourceFolder 'AutopilotBranding.ps1'
    if (-not (Test-Path -Path $mainScript)) {
        throw "Main script not found: $mainScript"
    }

    # Read version from main script
    $content = Get-Content -Path $mainScript -Raw
    $versionMatch = $content | Select-String '\.VERSION\s+([\d.]+)' -AllMatches
    if (-not $versionMatch.Matches) {
        throw "Could not parse version from $mainScript"
    }
    $packageVersion = $versionMatch.Matches[0].Groups[1].Value
    Write-Verbose "Detected package version: $packageVersion"

    # Update Install script
    $installScript = Join-Path $SourceFolder 'Intune' 'Install-AutopilotBranding.ps1'
    if (Test-Path -Path $installScript) {
        $installContent = Get-Content -Path $installScript -Raw
        $installContent = $installContent -replace '\$packageVersion = .*', "\$packageVersion = '$packageVersion'"
        Set-Content -Path $installScript -Value $installContent -NoNewline
        Write-Verbose "Updated $installScript with version $packageVersion"
    }

    # Update Detect script
    $detectScript = Join-Path $SourceFolder 'Intune' 'Detect-AutopilotBranding.ps1'
    if (Test-Path -Path $detectScript) {
        $detectContent = Get-Content -Path $detectScript -Raw
        $detectContent = $detectContent -replace '\$expectedVersion = .*', "\$expectedVersion = '$packageVersion'"
        Set-Content -Path $detectScript -Value $detectContent -NoNewline
        Write-Verbose "Updated $detectScript with version $packageVersion"
    }
}

Sync-PackageVersion -SourceFolder $SourceFolder

# Check NuGet version
$MinimumVersion = [version]'2.8.5.201'
$provider = Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue |
Sort-Object Version -Descending |
Select-Object -First 1

if (-not $provider) {
    Write-Verbose 'NuGet Provider Package not detected, installing...'
    Install-PackageProvider -Name NuGet -Force | Out-Null
} elseif ($provider.Version -lt $MinimumVersion) {
    Write-Verbose "NuGet provider v$($provider.Version) is less than required v$MinimumVersion; updating."
    Install-PackageProvider -Name NuGet -Force | Out-Null
    
} else {
    Write-Verbose "NuGet provider meets min requirements (v:$($provider.Version))."
}

# Install and import the module to create the .intunewin file
$moduleName = 'SvRooij.ContentPrep.Cmdlet'
$module = Get-Module -ListAvailable -Name $moduleName | Sort-Object Version -Descending | Select-Object -First 1
if (-not $module -or $module.Version -lt [version]'0.4.0') {
    Write-Verbose "Installing module $moduleName..."
    Install-Module -Name $moduleName -MinimumVersion 0.4.0 -Force -Scope CurrentUser -Repository PSGallery -AllowClobber
}
Import-Module SvRooij.ContentPrep.Cmdlet

# Create the .intunewin file
if ($OutputFolder -eq "") {
    $OutputFolder = $PSScriptRoot
}
if (Test-Path "$OutputFolder\AutopilotBranding.intunewin") {
    Remove-Item "$OutputFolder\AutopilotBranding.intunewin" -Force
}
New-IntuneWinPackage -SourcePath $SourceFolder -SetupFile $SetupFile -DestinationPath $OutputFolder
