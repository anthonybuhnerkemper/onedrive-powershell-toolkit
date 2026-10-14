# 05 - Departed user OneDrive access transfer

## Before deleting the account
1. Block sign-in and revoke sessions ([entra-id-powershell-toolkit](https://github.com/anthonybuhnerkemper/entra-id-powershell-toolkit) `Invoke-EntraUserOffboarding.ps1`).
2. Give the manager access:
   ```powershell
   ./scripts/Access/Grant-DepartedUserOneDriveAccess.ps1 -DepartedUser former.user@contoso.com -Delegate manager@contoso.com -WhatIf
   ./scripts/Access/Grant-DepartedUserOneDriveAccess.ps1 -DepartedUser former.user@contoso.com -Delegate manager@contoso.com
   ```
3. The manager opens the `DocumentsUrl` and moves what is needed to a team site.

## Retention timeline
| Event | What happens |
|---|---|
| Account deleted | OneDrive kept for `OrphanedPersonalSitesRetentionPeriod` days (default 30, max 3650) |
| Retention ends | OneDrive moved to the recycle bin for 93 days |
| Retention policy applies | Content preserved per policy regardless of the above |

Change the period: `Set-SPOTenant -OrphanedPersonalSitesRetentionPeriod 90`.

The Microsoft 365 admin center also offers automatic access delegation to the manager when a user is deleted (SharePoint admin center > Settings > OneDrive retention > Access delegation).

## Clean up
```powershell
./scripts/Access/Remove-OneDriveSecondaryAdmin.ps1 -OneDriveUrl https://contoso-my.sharepoint.com/personal/former_user_contoso_com -Admin manager@contoso.com -WhatIf
```
