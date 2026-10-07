# Autopilot Branding

PowerShell-based branding and baseline customization package for Windows Autopilot deployments, designed to be delivered as a Microsoft Intune Win32 app.

This repo supports Windows 10 and Windows 11 scenarios and is intended for OOBE/ESP-time execution in System context.

## What this package does

The main script can apply a subset of the following (controlled in `AutopilotBranding/Config.xml`):

- Start menu and taskbar defaults.
- Desktop wallpaper and lock screen branding.
- Time zone and selected device defaults.
- Removal of selected in-box/provisioned apps.
- OneDrive machine-wide installer update.
- Optional language/config association artifacts.

Most optional or advanced actions are intentionally disabled/commented by default for safer production rollout.

## Repository structure

- `AutopilotBranding/AutopilotBranding.ps1` - Main script invoked during deployment.
- `AutopilotBranding/Config.xml` - Feature flags and settings.
- `AutopilotBranding/Intune/Install-AutopilotBranding.ps1` - Intune Win32 install entrypoint.
- `AutopilotBranding/Intune/Uninstall-AutopilotBranding.ps1` - Intune Win32 uninstall entrypoint.
- `AutopilotBranding/Intune/Detect-AutopilotBranding.ps1` - Intune detection script.
- `makeapp.cmd` / `makeapp.ps1` - Build `.intunewin` package.
- `docs/INTUNE-DEPLOYMENT.md` - Extended deployment runbook.

## Prerequisites

- Intune admin permissions to create/update Win32 apps.
- Autopilot enrollment profile and target device groups already in place.
- Packaging host with PowerShell 7+ and internet access to PSGallery.
- Review and customize `AutopilotBranding/Config.xml` before packaging.

## Production quick start

1. **Customize**
	- Update `AutopilotBranding/Config.xml`.
	- Replace assets as needed (`Autopilot.jpg`, `AutopilotLock.jpg`, `Autopilot.theme`, layout files).
2. **Build package**
	- Run `makeapp.cmd` from repo root.
	- Output file: `AutopilotBranding.intunewin`.
3. **Create Intune Win32 app**
	- App type: Windows app (Win32).
	- Upload `AutopilotBranding.intunewin`.
4. **Set program commands**
	- Install:
	  - `%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Intune\Install-AutopilotBranding.ps1`
	- Uninstall:
	  - `%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Intune\Uninstall-AutopilotBranding.ps1`
	- Install behavior: **System**.
5. **Configure detection**
	- Preferred: custom detection script `Intune\Detect-AutopilotBranding.ps1`.
	- Alternative: file exists at `%ProgramData%\Microsoft\AutopilotBranding\AutopilotBranding.ps1.tag`.
6. **Assign safely**
	- Deploy to device groups in rings: Lab -> Pilot -> Broad production.
	- Keep ESP blocking list minimal and include this app only if required pre-sign-in.

## Runtime behavior

- Log file: `%ProgramData%\Microsoft\AutopilotBranding\AutopilotBranding.log`
- Success marker: `%ProgramData%\Microsoft\AutopilotBranding\AutopilotBranding.ps1.tag`
- Script returns non-zero on failure so Intune can retry/report correctly.
- Script exits early outside OOBE unless run with `-Force`.

## Validation checklist (before broad rollout)

- Validate on clean test devices matching production OS builds.
- Confirm app install status in Intune is successful.
- Verify branding artifacts and start/taskbar behavior for new users.
- Confirm no unexpected reboot loops or long ESP delays.
- Review local log file and Intune Management Extension logs for errors.

## Rollback and update strategy

- Keep versioned package releases and release notes.
- Use Intune supersedence for upgrades.
- Keep uninstall command available for emergency rollback.
- Change one area at a time (layout, apps, theme, etc.) to reduce blast radius.

## Security and operational best practices

- Do not store credentials, secrets, or tenant-sensitive data in scripts or XML.
- Keep scripts non-interactive and silent (required for OOBE/ESP reliability).
- Prefer idempotent changes and stable detection markers.
- Test any newly enabled commented sections before production use.

## Troubleshooting

- If detection fails, verify marker file creation at `%ProgramData%\Microsoft\AutopilotBranding`.
- If script appears skipped, confirm whether the device had already completed OOBE.
- If package fails to build, re-run `makeapp.cmd` from repo root and verify module download access.
- If deployment is delayed, verify Intune assignment targeting and ESP configuration.

## More detail

- Extended runbook: `docs/INTUNE-DEPLOYMENT.md`
- Release checklist: `docs/RELEASE-CHECKLIST.md`
- Background article: https://oofhours.com/2020/05/18/two-for-one-updated-autopilot-branding-and-update-os-scripts/

## Change history

- 2023-09-23: Added logic to handle the Windows 11 Start menu process using `Start2.bin`; Windows 10 continues to use `Layout.xml`.
- 2024-01-31: Added additional apps to remove, timestamps in logging, and error logging cleanup.
- 2024-04-27: Added logic to stop Start from popping up on first sign-in.
- 2024-12-26: Added support for removing FODs and disabling optional features.

## Suggestions

If you have suggestions on additional customizations, contact michael@oofhours.com.
