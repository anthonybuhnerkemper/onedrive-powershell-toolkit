#Requires -Version 7.4
#Requires -Modules Microsoft.Graph.Authentication
<#
.SYNOPSIS
    Downloads the Microsoft 365 OneDrive usage account detail report (files, active files,
    storage, last activity) from Microsoft Graph.
.DESCRIPTION
    Requires Connect-MgGraph with Reports.Read.All (delegated users also need a reports reader
    role). If "Display concealed user, group, and site names in all reports" is off in the
    Microsoft 365 admin center, owner names are pseudonymized. Read-only.
.PARAMETER Period
    D7, D30, D90 or D180. Default D30.
.PARAMETER OutputFolder
    Folder for CSV output. Defaults to ./output.
.EXAMPLE
    ./Get-OneDriveUsageReport.ps1 -Period D90
#>
[CmdletBinding()]
param(
    [ValidateSet('D7', 'D30', 'D90', 'D180')][string]$Period = 'D30',
    [string]$OutputFolder = (Join-Path (Get-Location) 'output')
)
$ErrorActionPreference = 'Stop'
if (-not (Get-MgContext)) { throw 'Not connected. Run Connect-MgGraph first.' }
New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null

$file = Join-Path $OutputFolder "OneDriveUsage-$Period-$(Get-Date -Format 'yyyyMMdd-HHmm').csv"
Invoke-MgGraphRequest -Method GET -Uri "v1.0/reports/getOneDriveUsageAccountDetail(period='$Period')" -OutputFilePath $file
$rows = Import-Csv $file
$inactive = @($rows | Where-Object { -not $_.'Last Activity Date' -or [datetime]$_.'Last Activity Date' -lt (Get-Date).AddDays(-90) })
if ($rows -and $rows[0].'Owner Principal Name' -notmatch '@') {
    Write-Warning 'Owner names look concealed. Enable "Display concealed user, group, and site names" in Microsoft 365 admin center > Settings > Org settings > Reports.'
}
Write-Information "Accounts: $(@($rows).Count)  No activity in 90 days: $($inactive.Count) -> $file" -InformationAction Continue
