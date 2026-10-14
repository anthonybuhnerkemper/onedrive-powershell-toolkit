#Requires -Version 7.4
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    Gives a manager (or records owner) access to a departed user's OneDrive by adding them as a
    site collection admin, and reports the retention window.
.DESCRIPTION
    Requires Connect-SPOService (SharePoint Administrator). Finds the OneDrive by owner UPN, adds
    the delegate as a secondary site collection admin, and prints the share URL plus the tenant's
    OrphanedPersonalSitesRetentionPeriod (how long the OneDrive is kept after the account is
    deleted). Supports -WhatIf and -Confirm; writes a change log CSV.
    Remove access later with Remove-OneDriveSecondaryAdmin.ps1.
.PARAMETER DepartedUser
    UPN of the departed user.
.PARAMETER Delegate
    UPN that receives access, for example the manager.
.PARAMETER OutputFolder
    Folder for the change log. Defaults to ./output.
.EXAMPLE
    ./Grant-DepartedUserOneDriveAccess.ps1 -DepartedUser former.user@contoso.com -Delegate manager@contoso.com -WhatIf
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory)][string]$DepartedUser,
    [Parameter(Mandatory)][string]$Delegate,
    [string]$OutputFolder = (Join-Path (Get-Location) 'output')
)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null

$site = Get-SPOSite -IncludePersonalSite $true -Limit All -Filter "Owner -eq '$DepartedUser'" |
    Where-Object Url -like '*-my.sharepoint.com/personal/*' | Select-Object -First 1
if (-not $site) { throw "No OneDrive found for $DepartedUser. If the account was deleted, check Get-SPODeletedSite -IncludeOnlyPersonalSite." }

$retention = (Get-SPOTenant).OrphanedPersonalSitesRetentionPeriod
$result = 'Skipped'
if ($PSCmdlet.ShouldProcess($site.Url, "Add $Delegate as site collection admin")) {
    Set-SPOUser -Site $site.Url -LoginName $Delegate -IsSiteCollectionAdmin $true | Out-Null
    $result = 'Granted'
}
$log = [pscustomobject]@{
    DepartedUser   = $DepartedUser
    OneDriveUrl    = $site.Url
    DocumentsUrl   = "$($site.Url)/Documents"
    Delegate       = $Delegate
    Result         = $result
    StorageUsedGB  = [math]::Round($site.StorageUsageCurrent / 1024, 2)
    RetentionDaysAfterDeletion = $retention
    Time           = Get-Date
}
$file = Join-Path $OutputFolder "OneDriveAccessGrant-$(Get-Date -Format 'yyyyMMdd-HHmm').csv"
$log | Export-Csv -Path $file -NoTypeInformation -Append
Write-Information "$result : $Delegate -> $($log.DocumentsUrl). OneDrive is kept $retention days after the account is deleted (then 93 days in the recycle bin). Log: $file" -InformationAction Continue
