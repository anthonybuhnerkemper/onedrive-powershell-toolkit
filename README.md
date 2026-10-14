# OneDrive PowerShell Toolkit

A practical toolkit and step-by-step guide for **OneDrive for Business** administration with **PowerShell 7**, using **Microsoft.Online.SharePoint.PowerShell** and **Microsoft Graph**.

It covers OneDrive inventory and storage, usage reports, a per-file sharing audit, pre-provisioning, departed-user OneDrive access transfer, tenant settings, and Known Folder Move notes. Every script has comment-based help (`Get-Help ./script.ps1 -Full`), reports export to CSV, and every change script supports `-WhatIf` / `-Confirm`. Authentication uses **certificates** (app-only) or **interactive** sign-in via the same `Connect-M365Admin` pattern as [graph-powershell7-admin-toolkit](https://github.com/anthonybuhnerkemper/graph-powershell7-admin-toolkit). No secrets are stored in the repo.

> ⚠️ **Disclaimer:** Test everything in a non-production / developer tenant first. Examples use `contoso.com`, `contoso-my.sharepoint.com`, and placeholder GUIDs (`00000000-0000-0000-0000-000000000000`). Review each script before running it in your environment.

## Prerequisites

| Requirement | Version / notes |
|---|---|
| PowerShell | 7.4 or later (`pwsh`) |
| Microsoft.Online.SharePoint.PowerShell | Latest from PSGallery |
| Microsoft.Graph.Authentication | 2.x |
| Roles | SharePoint Administrator; Reports Reader for usage reports |

```powershell
Install-Module Microsoft.Online.SharePoint.PowerShell, Microsoft.Graph.Authentication -Scope CurrentUser
```

## Quick start

```powershell
git clone https://github.com/anthonybuhnerkemper/onedrive-powershell-toolkit.git
cd onedrive-powershell-toolkit

. ./scripts/Connect/Connect-M365Admin.ps1
Connect-M365Admin -Service SharePoint, Graph -Interactive -SharePointAdminUrl https://contoso-admin.sharepoint.com `
    -GraphScopes Reports.Read.All, Files.Read.All, User.Read.All

# Reports (CSV files land in ./output)
./scripts/Inventory/Get-OneDriveInventory.ps1
./scripts/Inventory/Get-OneDriveUsageReport.ps1
./scripts/Settings/Get-OneDriveTenantSettings.ps1

# Preview a change before applying it
./scripts/Access/Grant-DepartedUserOneDriveAccess.ps1 -DepartedUser former.user@contoso.com -Delegate manager@contoso.com -WhatIf

. ./scripts/Connect/Disconnect-M365Admin.ps1
Disconnect-M365Admin
```

## Repo map

```text
.github/workflows/pssa.yml  PSScriptAnalyzer CI on push and PR
docs/
  01-connect-spo-and-graph.md
  02-inventory-and-storage.md
  03-sharing-audit.md
  04-pre-provisioning.md
  05-departed-user-access.md
  06-known-folder-move-notes.md
samples/        preprovision-users.sample.csv
scripts/
  Connect/      Connect-M365Admin.ps1, Disconnect-M365Admin.ps1
  Inventory/    Get-OneDriveInventory, Get-OneDriveUsageReport
  Sharing/      Get-OneDriveSharingAudit
  Provisioning/ Request-OneDrivePreProvisioning
  Access/       Grant-DepartedUserOneDriveAccess, Remove-OneDriveSecondaryAdmin
  Settings/     Get-OneDriveTenantSettings
```

## Permissions

| Script | Module | Role / Graph permission | Changes? |
|---|---|---|---|
| Get-OneDriveInventory | SPO | SharePoint Administrator | No |
| Get-OneDriveUsageReport | Graph | `Reports.Read.All` | No |
| Get-OneDriveSharingAudit | Graph | `Files.Read.All`, `User.Read.All` (Application recommended) | No |
| Request-OneDrivePreProvisioning | SPO | SharePoint Administrator | Yes (`-WhatIf`) |
| Grant-DepartedUserOneDriveAccess | SPO | SharePoint Administrator | Yes (`-WhatIf`) |
| Remove-OneDriveSecondaryAdmin | SPO | SharePoint Administrator | Yes (`-WhatIf`) |
| Get-OneDriveTenantSettings | SPO | SharePoint Administrator | No |

## Related

- [sharepoint-online-powershell-toolkit](https://github.com/anthonybuhnerkemper/sharepoint-online-powershell-toolkit): sharing baseline and site lifecycle
- [entra-id-powershell-toolkit](https://github.com/anthonybuhnerkemper/entra-id-powershell-toolkit): user offboarding

## License

[MIT](LICENSE) © 2026 Anthony Buhnerkemper
