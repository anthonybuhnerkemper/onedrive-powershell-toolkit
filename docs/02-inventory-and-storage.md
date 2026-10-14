# 02 - OneDrive inventory and storage

## Inventory (SPO)
```powershell
./scripts/Inventory/Get-OneDriveInventory.ps1 -WarningPercent 85
```
Owner, storage used vs quota, last content change and lock state for every OneDrive.

## Usage (Graph reports)
```powershell
./scripts/Inventory/Get-OneDriveUsageReport.ps1 -Period D90
```
File counts, active files and last activity per account. If owner names look like hashes, turn off report concealment: Microsoft 365 admin center > Settings > Org settings > Reports.

## Quotas
- Default quota: `Set-SPOTenant -OneDriveStorageQuota 1048576` (MB, 1 TB).
- Per user: `Set-SPOSite -Identity <onedrive url> -StorageQuota 5242880`.
- Above 1 TB requires eligible plans and, past 5 TB, a support request.
