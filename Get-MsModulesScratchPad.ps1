<#
    .SYNOPSIS
        Trying to figure out how to query the PowerShell Gallery for all modules created/owned by Microsoft,
        then get their latest GA and prerelease versions of each.
#>
$Author = 'Microsoft Corporation'
$BaseUrl = 'https://www.powershellgallery.com/api/v2/Packages'
$Filter = "?`$filter=Authors eq '$Author'"
$skip = 0
$modules = @()

do {
    # This loop takes 3+ minutes.
    $Url = $BaseUrl + $Filter + "&`$skip=$skip"
    $Response = Invoke-RestMethod -Uri $Url

    $Modules += $Response.properties
    $skip += 100
} while ($response.properties.Id)

# It's returning XML and I haven't yet learned how to effectively parse that.

# For a start, this takes the full results and groups them by Id to find the most recent version (by date) of each.
$Modules | Sort-Object -Property Id | Group-Object -Property Id |
    ForEach-Object {
        $_.Group | Sort-Object LastEdited.'#text' | Select-Object -First 1
    } | Format-Table Id,Version,Title -AutoSize

# This is close, but doesn't include the actual title for 95% of the modules listed. Just the text "Title."
