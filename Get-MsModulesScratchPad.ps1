<#
    .SYNOPSIS
        Trying to figure out how to query the PowerShell Gallery for all modules created/owned by Microsoft,
        then get their latest GA and prerelease versions of each.
#>
$Author = 'Microsoft Corporation'
$BaseUrl = 'https://www.powershellgallery.com/api/v2/Packages'
$Filter = "?`$filter=Authors eq '$Author'"
$Skip = 0
$Modules = @()

do {
    # This loop takes 3+ minutes.
    $Url = $BaseUrl + $Filter + "&`$skip=$Skip"
    $Response = Invoke-RestMethod -Uri $Url

    $Modules += $Response.properties
    $Skip += 100
} while ($response.properties.Id)

# This is close, but doesn't include the actual title for 95% of the modules listed. Just the text "Title."

<#
    NuGet v2 repositories return OData v2 (XML), but v3 repositories can return JSON. Reference: https://joelverhagen.github.io/NuGetUndocs/#v2-protocol
    I haven't yet learned how to effectively parse OData or XML, so extracting the data first was my most expedient approach.
    Also should check out Justin Grote's v2 to v3 bridge at https://github.com/JustinGrote/pwshgallery.
#>
$NormalizedList = $Modules | Select-Object Id,Title,Version,Created,Description,NormalizedVersion,@{N="LatestVersion";E={$_.islatestversion.'#text'}}, @{N="AbsoluteLatestVersion";E={$_.isabsolutelatestversion.'#text'}},@{N="Prerelease";E={$_.isprerelease.'#text'}}, @{N='ModifiedDate';E={$_.LastEdited.'#text'}}, @{N='PublishedDate';E={$_.Published.'#text'}}

$Releases = $NormalizedList | Group-Object Id,Prerelease |
    ForEach-Object {
        $_.Group | Sort-Object PublishedDate, ModifiedDate -Descending | Select-Object -First 1
    }

$Releases | Select-Object -First 20 | Format-Table Id,Version,NormalizedVersion,Prerelease,LatestVersion,AbsoluteLatestVersion,ModifiedDate,PublishedDate -AutoSize



<#
    Below are my original attempts to pull info out of XML and group it as-is. Difficult and messy!
#>

# For a start, this takes the full results and groups them by Id to find the most recent version (by date) of each.
$Modules | Sort-Object -Property Id | Group-Object -Property Id |
    ForEach-Object {
        $_.Group | Sort-Object LastEdited.'#text' | Select-Object -First 1
    } | Format-Table Id,Version,Title -AutoSize

$ModuleGroups = $Modules | Sort-Object -Property @{Expression = {$_.Id}}, @{Expression = {$_.IsPrerelease.'#text'}}, @{Expression = {$_.LastEdited.'#text'}} | Group-Object -Property Id |
    ForEach-Object {
    # For each ModuleGroup, do
        $_.Group | Sort-Object LastEdited.'#text' | Group-Object -Property IsPrerelease |
            ForEach-Object {
                $_.Group | Sort-Object LastEdited.'#text' | Select-Object -First 1
            }
    }

$PrereleaseModules = $ModuleGroups | Where-Object {$_.IsPrerelease.'#text' -eq 'true'} | Select-Object Id,Version,Title
$PrereleaseModules.Count
