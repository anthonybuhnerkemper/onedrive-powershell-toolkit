#Requires -Version 7.4
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    Exports every OneDrive (personal site) with owner, storage used/quota, last content change and
    lock state.
.DESCRIPTION
    Requires Connect-SPOService (SharePoint Administrator). OneDrives whose owner has been deleted
    show up with a blank or unresolved owner. Read-only.
.PARAMETER WarningPercent
    Flag OneDrives using at least this percentage of quota. Default 90.
.PARAMETER OutputFolder
    Folder for CSV output. Defaults to ./output.
.EXAMPLE
    ./Get-OneDriveInventory.ps1
#>
[CmdletBinding()]
param(
    [ValidateRange(1, 100)][int]$WarningPercent = 90,
    [string]$OutputFolder = (Join-Path (Get-Location) 'output')
)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null

$sites = Get-SPOSite -IncludePersonalSite $true -Limit All -Filter "Url -like '-my.sharepoint.com/personal/'"
$rows = foreach ($s in $sites) {
    $pct = if ($s.StorageQuota -gt 0) { [math]::Round(100 * $s.StorageUsageCurrent / $s.StorageQuota, 1) } else { $null }
    [pscustomobject]@{
        Url               = $s.Url
        Owner             = $s.Owner
        Title             = $s.Title
        StorageUsedGB     = [math]::Round($s.StorageUsageCurrent / 1024, 2)
        StorageQuotaGB    = [math]::Round($s.StorageQuota / 1024, 0)
        PercentUsed       = $pct
        NearQuota         = ($null -ne $pct -and $pct -ge $WarningPercent)
        LastContentChange = $s.LastContentModifiedDate
        DaysSinceChange   = [int]((Get-Date) - $s.LastContentModifiedDate).TotalDays
        LockState         = $s.LockState
        SharingCapability = $s.SharingCapability
    }
}
$file = Join-Path $OutputFolder "OneDriveInventory-$(Get-Date -Format 'yyyyMMdd-HHmm').csv"
$rows | Sort-Object StorageUsedGB -Descending | Export-Csv -Path $file -NoTypeInformation
$totalTB = [math]::Round(($rows | Measure-Object StorageUsedGB -Sum).Sum / 1024, 2)
Write-Information "OneDrives: $(@($rows).Count)  Total used: $totalTB TB  Near quota: $(@($rows | Where-Object NearQuota).Count) -> $file" -InformationAction Continue
