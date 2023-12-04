<#
.SYNOPSIS
    Trying to figure out how to query the PowerShell Gallery for all modules created/owned by Microsoft,
    then get their latest GA and prerelease versions of each.
#>
$Author = 'Microsoft Corporation'
$BaseUrl = 'https://www.powershellgallery.com/api/v2/Packages'
$Filter = "?`$filter=Authors eq '$Author'"
$url = $BaseUrl + $Filter

# The API will limit these results to 100
$Results = (Invoke-RestMethod -Uri $url).properties
$Results.Count
$Results.properties.Title

<#
    Here is Bing Chat's suggestion for getting all paged results from the API.
#>
$authorName = 'Microsoft Corporation'
$baseUrl = 'https://www.powershellgallery.com/api/v2/Packages'
$filter = "?`$filter=Authors eq '$authorName'"
$skip = 0
$modules = @()

do {
    $url = $baseUrl + $filter + "&`$skip=$skip"
    $response = Invoke-RestMethod -Uri $url

    $modules += $response.properties
    $skip += 100
} while ($response.properties.Id)

<#
    It is returning XML and I'm not proficient enough to parse that easily yet.
#>

# For a start, this takes the full results and groups them by Id to find the most recent version (by date) of each.
$Modules | Group-Object Id |
    ForEach-Object {$_.Group | Sort-Object LastEdited.'#text' | Select-Object -first 1} |
    Format-Table Id,Version,Title

<#
    $Results[0].properties | select Id,Title,Version,Authors,Created,Description,IsLatestVersion,IsAbsoluteLatestVersion,IsPrerelease,LastUpdated
    $Results[0].properties.IsLatestVersion
    $Results[0].properties.IsAbsoluteLatestVersion
    $Results[0].properties.IsPrerelease
#>
