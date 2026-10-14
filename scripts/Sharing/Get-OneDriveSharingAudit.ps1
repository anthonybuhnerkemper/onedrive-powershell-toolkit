#Requires -Version 7.4
#Requires -Modules Microsoft.Graph.Authentication
<#
.SYNOPSIS
    Lists shared files and folders in users' OneDrives with link type (anonymous, organization,
    specific people), roles, external recipients and expiry.
.DESCRIPTION
    Requires Connect-MgGraph with Files.Read.All and User.Read.All (app-only recommended; delegated
    access only sees drives the signed-in user can read). Uses the drive delta query to find items
    with a "shared" facet, then reads their permissions. Read-only.
.PARAMETER UserPrincipalName
    One or more users whose OneDrive to audit.
.PARAMETER AnonymousOnly
    Only report "Anyone" links.
.PARAMETER OutputFolder
    Folder for CSV output. Defaults to ./output.
.EXAMPLE
    ./Get-OneDriveSharingAudit.ps1 -UserPrincipalName user1@contoso.com, user2@contoso.com
.EXAMPLE
    ./Get-OneDriveSharingAudit.ps1 -UserPrincipalName user1@contoso.com -AnonymousOnly
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string[]]$UserPrincipalName,
    [switch]$AnonymousOnly,
    [string]$OutputFolder = (Join-Path (Get-Location) 'output')
)
$ErrorActionPreference = 'Stop'
if (-not (Get-MgContext)) { throw 'Not connected. Run Connect-MgGraph first.' }
New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null

$rows = [System.Collections.Generic.List[object]]::new()
foreach ($upn in $UserPrincipalName) {
    try { $drive = Invoke-MgGraphRequest -Uri "v1.0/users/$upn/drive?`$select=id,webUrl" -OutputType PSObject }
    catch { Write-Warning "$upn has no OneDrive or is not accessible: $($_.Exception.Message)"; continue }

    $uri = "v1.0/drives/$($drive.id)/root/delta?`$select=id,name,webUrl,shared,folder,file,parentReference"
    $shared = [System.Collections.Generic.List[object]]::new()
    do {
        $page = Invoke-MgGraphRequest -Uri $uri -OutputType PSObject
        $page.value | Where-Object { $_.shared } | ForEach-Object { $shared.Add($_) }
        $uri = $page.'@odata.nextLink'
    } while ($uri)

    foreach ($item in $shared) {
        $perms = (Invoke-MgGraphRequest -Uri "v1.0/drives/$($drive.id)/items/$($item.id)/permissions" -OutputType PSObject).value |
            Where-Object { -not ($_.roles -contains 'owner') }
        foreach ($p in $perms) {
            $scope = if ($p.link) { $p.link.scope } else { 'direct' }
            if ($AnonymousOnly -and $scope -ne 'anonymous') { continue }
            $recipients = @($p.grantedToIdentitiesV2.user.email) + @($p.grantedToV2.user.email) + @($p.invitation.email) | Where-Object { $_ } | Sort-Object -Unique
            $rows.Add([pscustomobject]@{
                Owner      = $upn
                Item       = $item.name
                Type       = if ($item.folder) { 'Folder' } else { 'File' }
                Path       = ($item.parentReference.path -replace '^/drive/root:', '')
                LinkScope  = $scope
                LinkType   = $p.link.type
                Roles      = ($p.roles -join ',')
                Recipients = ($recipients -join '; ')
                Expires    = $p.expirationDateTime
                HasPassword = $p.hasPassword
                WebUrl     = $item.webUrl
            })
        }
    }
    Write-Verbose "$upn : $($shared.Count) shared item(s)"
}
$file = Join-Path $OutputFolder "OneDriveSharing-$(Get-Date -Format 'yyyyMMdd-HHmm').csv"
$rows | Export-Csv -Path $file -NoTypeInformation
$rows | Group-Object LinkScope | Select-Object Name, Count | Out-String | Write-Information -InformationAction Continue
Write-Information "Sharing entries: $($rows.Count) -> $file" -InformationAction Continue
