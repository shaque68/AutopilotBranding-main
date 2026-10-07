# Release Checklist

Use this checklist before promoting a new package from pilot to production.

## Scope and change control

- [ ] Document what changed in `Config.xml`, script logic, or assets.
- [ ] Confirm no secrets/credentials were added to scripts or config.
- [ ] Record target version and release date.

## Build and package

- [ ] Run `makeapp.cmd` successfully.
- [ ] Verify output package `AutopilotBranding.intunewin` exists.
- [ ] Validate Intune install/uninstall commands reference `Intune` wrapper scripts.

## Functional validation (test tenant / pilot devices)

- [ ] Deploy to a lab device group first.
- [ ] Confirm install completes in Intune.
- [ ] Confirm marker file exists: `%ProgramData%\\Microsoft\\AutopilotBranding\\AutopilotBranding.ps1.tag`.
- [ ] Confirm expected branding outcomes for a new user profile.
- [ ] Check `%ProgramData%\\Microsoft\\AutopilotBranding\\AutopilotBranding.log` for errors.

## Deployment safety

- [ ] Use ringed deployment (Lab -> Pilot -> Production).
- [ ] Keep ESP blocking list minimal.
- [ ] Verify rollback path (uninstall command and assignment rollback) is ready.

## Production promotion

- [ ] Promote to broader device group.
- [ ] Monitor install failures and remediation trends for 24-48 hours.
- [ ] Update release notes with outcomes and any follow-up actions.
