# Intune Deployment Runbook

This package is designed for deployment as a Windows Win32 app in Microsoft Intune, running in System context during Autopilot enrollment.

## Deployment files

- `AutopilotBranding/AutopilotBranding.ps1` (main script)
- `AutopilotBranding/Config.xml` (feature flags and settings)
- `AutopilotBranding/Intune/Install-AutopilotBranding.ps1` (install entrypoint)
- `AutopilotBranding/Intune/Uninstall-AutopilotBranding.ps1` (uninstall entrypoint)
- `AutopilotBranding/Intune/Detect-AutopilotBranding.ps1` (detection script)

Success marker file:

- `%ProgramData%\Microsoft\AutopilotBranding\AutopilotBranding.ps1.tag`

## Build package

From repo root, run:

```powershell
.\makeapp.cmd
```

Output:

- `AutopilotBranding.intunewin`

## Intune app configuration

### App type

- Windows app (Win32)

### Program settings

- Install command:

```text
%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Intune\Install-AutopilotBranding.ps1
```

- Uninstall command:

```text
%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Intune\Uninstall-AutopilotBranding.ps1
```

- Install behavior: System

### Detection settings

Preferred:

- Use custom detection script `Intune\Detect-AutopilotBranding.ps1`

Script returns:

- `0` and version string (e.g., `Installed (v3.3.1)`) when marker and version file exist and match expected version
- `1` when not installed or version mismatch

Version mismatch triggers Intune to treat the app as needing remediation/upgrade. This prevents stale versions and improves supersedence reliability.

Alternative (not recommended for production):

- File detection path: `%ProgramData%\Microsoft\AutopilotBranding`
- File name: `AutopilotBranding.ps1.tag`

### Requirements and assignments

- Assign as Required to device groups.
- Roll out in rings: Lab -> Pilot -> Broad production.
- Keep ESP blocking app list minimal.
- Include this app in ESP only if branding must complete before first sign-in.

## Operational validation

Before broad rollout:

- Test on clean devices across target OS builds.
- Confirm install status in Intune portal.
- Verify branding outcomes after first user sign-in.
- Review logs for failures or long-running actions.

Runtime logs:

- `%ProgramData%\Microsoft\AutopilotBranding\AutopilotBranding.log`

## Security and reliability guidance

- Keep scripts non-interactive and silent.
- Avoid secrets in script/config/package files.
- Keep changes idempotent to support retry behavior.
- Do not force restarts from script unless explicitly required.

## Version tracking

Each release writes its version to `%ProgramData%\Microsoft\AutopilotBranding\AutopilotBranding.version`.

The detection script validates this version matches the package version. If versions don't match, Intune treats the app as needing re-deployment, which is critical for:

- Automatic supersedence when updating the package
- Preventing version skew during group rollouts
- Reliable rollback detection

Always ensure the version in `Install-AutopilotBranding.ps1` and `Detect-AutopilotBranding.ps1` match the package release version.

## Troubleshooting quick checks

- Detection reports version mismatch: ensure Install and Detect scripts have matching version numbers.
- No detection: check both marker and version files exist in `%ProgramData%\Microsoft\AutopilotBranding`.
- Script skipped: verify whether OOBE was already complete.
- Build failure: verify PSGallery/module access from packaging host.
- Deployment delay: check assignment targeting and ESP configuration.
