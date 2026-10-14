#Requires -Version 7.4
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    Pre-provisions OneDrive for licensed users who have never signed in (for example before a file
    migration or Known Folder Move rollout).
.DESCRIPTION
    Requires Connect-SPOService (SharePoint Administrator). Users must be licensed for OneDrive
    and allowed to create a personal site. Calls Request-SPOPersonalSite in batches of 199
    with -NoWait; provisioning completes in the background (often minutes, up to 24 hours).
    Input: -UserPrincipalName or a CSV with a UserPrincipalName column.
    Supports -WhatIf and -Confirm.
.PARAMETER UserPrincipalName
    Users to provision.
.PARAMETER CsvPath
    CSV with a UserPrincipalName column.
.EXAMPLE
    ./Request-OneDrivePreProvisioning.ps1 -CsvPath ./samples/preprovision-users.sample.csv -WhatIf
#>
[CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Upn')]
param(
    [Parameter(Mandatory, ParameterSetName = 'Upn')][string[]]$UserPrincipalName,
    [Parameter(Mandatory, ParameterSetName = 'Csv')][string]$CsvPath
)
$ErrorActionPreference = 'Stop'
$users = if ($PSCmdlet.ParameterSetName -eq 'Csv') { (Import-Csv $CsvPath).UserPrincipalName } else { $UserPrincipalName }
$users = @($users | Where-Object { $_ } | Sort-Object -Unique)

$batchSize = 199
for ($i = 0; $i -lt $users.Count; $i += $batchSize) {
    $batch = $users[$i..([math]::Min($i + $batchSize, $users.Count) - 1)]
    if ($PSCmdlet.ShouldProcess("$($batch.Count) user(s): $($batch[0]) ...", 'Request OneDrive provisioning')) {
        Request-SPOPersonalSite -UserEmails $batch -NoWait
        Write-Information "Requested batch $([int]($i / $batchSize) + 1): $($batch.Count) user(s)" -InformationAction Continue
    }
}
Write-Information 'Check progress later with Get-OneDriveInventory.ps1.' -InformationAction Continue
