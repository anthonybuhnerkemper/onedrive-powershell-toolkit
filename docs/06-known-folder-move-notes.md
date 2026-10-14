# 06 - Known Folder Move (KFM) notes

KFM redirects Desktop, Documents and Pictures into OneDrive so they are backed up and roam between devices.

## Settings (Intune Settings Catalog > OneDrive, or Group Policy)
| Setting | Recommended |
|---|---|
| Silently move Windows known folders to OneDrive | Enabled, with your tenant ID (`00000000-0000-0000-0000-000000000000` placeholder) |
| Prevent users from redirecting their Windows known folders to their PC | Enabled |
| Silently sign in users to the OneDrive sync app with their Windows credentials | Enabled |
| Use OneDrive Files On-Demand | Enabled |
| Show notification to users after folders have been redirected | Optional |

Registry location (for checking a device): `HKLM\SOFTWARE\Policies\Microsoft\OneDrive`, value `KFMSilentOptIn` = tenant ID.

## Rollout
1. Pre-provision OneDrive for the pilot group (`Request-OneDrivePreProvisioning.ps1`).
2. Check folder sizes; large Desktop/Documents folders upload over time. Consider `Limit the sync app upload rate`.
3. Unsupported content blocks KFM for that folder: `.pst` files, OneNote notebooks not in OneDrive, paths > 400 characters, invalid characters.
4. Pilot, then expand by device group in Intune.

## Verify
- On a device: OneDrive settings > Sync and back up > Manage back up.
- Fleet: Microsoft 365 Apps admin center > OneDrive sync health dashboard (needs `EnableSyncAdminReports`).
- Tenant: `Get-OneDriveTenantSettings.ps1` for sync client restrictions (allowed domains, blocked file types).
