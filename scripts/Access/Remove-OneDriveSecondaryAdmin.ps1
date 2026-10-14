#Requires -Version 7.4
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    Removes a secondary site collection admin from one or more OneDrives (for example after a
    departed user's files have been reviewed or moved).
.DESCRIPTION
    Requires Connect-SPOService (SharePoint Administrator). The OneDrive's primary owner is never
    removed. Supports -WhatIf and -Confirm.
.PARAMETER OneDriveUrl
    One or more OneDrive URLs, for example https://contoso-my.sharepoint.com/personal/former_user_contoso_com.
.PARAMETER Admin
    UPN of the admin to remove.
.EXAMPLE
    ./Remove-OneDriveSecondaryAdmin.ps1 -OneDriveUrl https://contoso-my.sharepoint.com/personal/former_user_contoso_com -Admin manager@contoso.com -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string[]]$OneDriveUrl,
    [Parameter(Mandatory)][string]$Admin
)
$ErrorActionPreference = 'Stop'

foreach ($url in $OneDriveUrl) {
    $site = Get-SPOSite -Identity $url
    if ($site.Owner -eq $Admin) { Write-Warning "$Admin is the primary owner of $url; skipped."; continue }
    $user = Get-SPOUser -Site $url -LoginName $Admin -ErrorAction SilentlyContinue
    if (-not $user -or -not $user.IsSiteAdmin) { Write-Information "$Admin is not an admin on $url" -InformationAction Continue; continue }
    if ($PSCmdlet.ShouldProcess($url, "Remove site collection admin $Admin")) {
        Set-SPOUser -Site $url -LoginName $Admin -IsSiteCollectionAdmin $false | Out-Null
        Write-Information "Removed $Admin from $url" -InformationAction Continue
    }
}
