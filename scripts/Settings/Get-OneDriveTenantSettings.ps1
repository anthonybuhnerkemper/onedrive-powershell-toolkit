#Requires -Version 7.4
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    Exports OneDrive tenant settings: default quota, sharing, retention for deleted users, and sync
    client restrictions.
.DESCRIPTION
    Requires Connect-SPOService (SharePoint Administrator). Combines Get-SPOTenant and
    Get-SPOTenantSyncClientRestriction into one Setting/Value CSV for documentation and drift
    checks. Read-only.
.PARAMETER OutputFolder
    Folder for CSV output. Defaults to ./output.
.EXAMPLE
    ./Get-OneDriveTenantSettings.ps1
#>
[CmdletBinding()]
param(
    [string]$OutputFolder = (Join-Path (Get-Location) 'output')
)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null

$tenant = Get-SPOTenant
$sync = Get-SPOTenantSyncClientRestriction
$tenantProps = 'OneDriveStorageQuota', 'OneDriveSharingCapability', 'OrphanedPersonalSitesRetentionPeriod',
    'OneDriveForGuestsEnabled', 'NotifyOwnersWhenItemsReshared', 'NotifyOwnersWhenInvitationsAccepted',
    'BlockMacSync', 'DisableReportProblemDialog', 'ConditionalAccessPolicy', 'DefaultSharingLinkType', 'DefaultLinkPermission'
$syncProps = 'TenantRestrictionEnabled', 'AllowedDomainList', 'BlockMacSync', 'ExcludedFileExtensions', 'OptOutOfGrooveBlock', 'DisableReportProblemDialog'

$rows = @(
    foreach ($p in $tenantProps) { [pscustomobject]@{ Source = 'Get-SPOTenant'; Setting = $p; Value = ($tenant.$p -join '; ') } }
    foreach ($p in $syncProps) { [pscustomobject]@{ Source = 'SyncClientRestriction'; Setting = $p; Value = ($sync.$p -join '; ') } }
)
$file = Join-Path $OutputFolder "OneDriveTenantSettings-$(Get-Date -Format 'yyyyMMdd-HHmm').csv"
$rows | Export-Csv -Path $file -NoTypeInformation
$rows | Format-Table -AutoSize | Out-String | Write-Information -InformationAction Continue
Write-Information "Settings exported -> $file" -InformationAction Continue
