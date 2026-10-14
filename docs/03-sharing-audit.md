# 03 - OneDrive sharing audit

```powershell
./scripts/Sharing/Get-OneDriveSharingAudit.ps1 -UserPrincipalName user1@contoso.com, user2@contoso.com
./scripts/Sharing/Get-OneDriveSharingAudit.ps1 -UserPrincipalName user1@contoso.com -AnonymousOnly
```
How it works: the drive **delta** query lists every item once; only items with a `shared` facet have their permissions read, so large OneDrives are audited quickly.

| LinkScope | Meaning |
|---|---|
| anonymous | "Anyone with the link" (no sign-in) |
| organization | People in your organization |
| users | Specific people (may include guests) |
| direct | Permission granted directly, not through a link |

## Reduce oversharing
- Tenant: set `OneDriveSharingCapability` and `RequireAnonymousLinksExpireInDays` (see `Get-OneDriveTenantSettings.ps1` and the [SharePoint toolkit baseline](https://github.com/anthonybuhnerkemper/sharepoint-online-powershell-toolkit)).
- Default link type: `Set-SPOTenant -DefaultSharingLinkType Internal`.
- Remove a link: Graph `DELETE /drives/{drive-id}/items/{item-id}/permissions/{perm-id}` after confirming with the owner.
