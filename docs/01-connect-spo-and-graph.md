# 01 - Connect to SharePoint Online and Microsoft Graph

OneDrive administration uses both:
| Module | Used for |
|---|---|
| `Microsoft.Online.SharePoint.PowerShell` | Inventory, quotas, pre-provisioning, site admin access, tenant settings |
| `Microsoft.Graph.Authentication` | Usage reports and per-file sharing (drive and permissions APIs) |

```powershell
Install-Module Microsoft.Online.SharePoint.PowerShell, Microsoft.Graph.Authentication -Scope CurrentUser

. ./scripts/Connect/Connect-M365Admin.ps1
Connect-M365Admin -Service SharePoint, Graph -Interactive `
    -SharePointAdminUrl https://contoso-admin.sharepoint.com `
    -GraphScopes Reports.Read.All, Files.Read.All, User.Read.All
```

Certificate (app-only):
```powershell
$env:M365_TENANT_ID       = '00000000-0000-0000-0000-000000000000'
$env:M365_CLIENT_ID       = '00000000-0000-0000-0000-000000000000'
$env:M365_CERT_THUMBPRINT = '<thumbprint>'
$env:M365_SPO_ADMIN_URL   = 'https://contoso-admin.sharepoint.com'
Connect-M365Admin -Service SharePoint, Graph
```
For the sharing audit, app-only with `Files.Read.All` (Application) is recommended; delegated access only sees OneDrives the admin can open.

If you also use PnP.PowerShell, see [sharepoint-online-powershell-toolkit docs/02](https://github.com/anthonybuhnerkemper/sharepoint-online-powershell-toolkit/blob/main/docs/02-app-registration-for-pnp.md) for the app registration.
