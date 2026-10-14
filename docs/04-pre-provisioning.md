# 04 - Pre-provisioning OneDrive

A OneDrive is normally created the first time a user opens it. Pre-provision when you need to migrate files or apply settings before users sign in.

```powershell
./scripts/Provisioning/Request-OneDrivePreProvisioning.ps1 -CsvPath ./samples/preprovision-users.sample.csv -WhatIf
./scripts/Provisioning/Request-OneDrivePreProvisioning.ps1 -CsvPath ./samples/preprovision-users.sample.csv
```

Requirements:
1. Users are licensed for SharePoint/OneDrive and not blocked from sign-in.
2. Users have the **Create Personal Site** permission (SharePoint admin center > More features > User profiles > Manage User Permissions).
3. Batches of at most 199 users per `Request-SPOPersonalSite` call (handled by the script).

Provisioning runs in the background; verify with `Get-OneDriveInventory.ps1` after a few minutes to a few hours.
