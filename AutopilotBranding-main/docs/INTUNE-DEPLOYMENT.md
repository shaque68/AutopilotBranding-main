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

- `0` and `Installed` when marker exists
- `1` when not installed

Alternative:

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

## Troubleshooting quick checks

- No detection: check marker file exists in `%ProgramData%\Microsoft\AutopilotBranding`.
- Script skipped: verify whether OOBE was already complete.
- Build failure: verify PSGallery/module access from packaging host.
- Deployment delay: check assignment targeting and ESP configuration.
