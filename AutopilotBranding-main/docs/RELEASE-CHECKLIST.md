# Release Checklist

Use this checklist before promoting a new release from pilot to production.

## Scope and change control

- [ ] Document what changed in `Config.xml`, script logic, or assets.
- [ ] Confirm no secrets/credentials were added to scripts or config.
- [ ] Update `.VERSION` in `AutopilotBranding.ps1` (version sync is automatic during build).
- [ ] Record target version and release date.

## Build and package

- [ ] Run `makeapp.cmd` successfully.
- [ ] Verify output package `AutopilotBranding.intunewin` exists.
- [ ] **Version sync is automatic**: the build script reads `.VERSION` from the main script and updates Intune wrapper scripts automatically.
- [ ] Validate Intune install/uninstall commands reference `Intune` wrapper scripts.

## Functional validation (test tenant / pilot devices)

- [ ] Deploy to a lab device group first.
- [ ] Confirm install completes in Intune.
- [ ] Confirm marker file exists: `%ProgramData%\Microsoft\AutopilotBranding\AutopilotBranding.ps1.tag`.
- [ ] Confirm version file exists and contains expected version: `%ProgramData%\Microsoft\AutopilotBranding\AutopilotBranding.version`.
- [ ] Confirm expected branding outcomes for a new user profile.
- [ ] Check `%ProgramData%\Microsoft\AutopilotBranding\AutopilotBranding.log` for warnings/errors.

## Deployment safety

- [ ] Use ringed deployment (Lab -> Pilot -> Production).
- [ ] Keep ESP blocking list minimal.
- [ ] Verify rollback path (uninstall command and assignment rollback) is ready.

## Production promotion (GitHub Actions automated release)

- [ ] Tag the release: `git tag v[major].[minor].[patch]` (e.g., `git tag v3.3.2`)
- [ ] Push tag: `git push origin v[tag]`
- [ ] GitHub Actions validates scripts and builds package automatically
- [ ] Release appears in GitHub Releases page with `.intunewin` attached
- [ ] Download package from GitHub Release and upload to Intune (or link directly if using PowerShell automation)
- [ ] Monitor install failures and remediation trends for 24-48 hours
- [ ] Update release notes with outcomes and any follow-up actions
