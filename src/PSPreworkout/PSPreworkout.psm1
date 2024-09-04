# This psm1 is for local testing and development use only

# Dot-source the parent import for local development variables
. $PSScriptRoot\Imports.ps1

# Discover all ps1 file(s) in Public and Private paths

$itemSplat = @{
    Filter      = '*.ps1'
    Recurse     = $true
    ErrorAction = 'Stop'
}
try {
    $Public = @(Get-ChildItem -Path "$PSScriptRoot\Public" @itemSplat)
    $Private = @(Get-ChildItem -Path "$PSScriptRoot\Private" @itemSplat)
} catch {
    Write-Error $_
    throw 'Unable to get get file information from Public & Private src.'
}

# Dot-source all .ps1 file(s) found
foreach ($file in @($public + $private)) {
    try {
        . $file.FullName
    } catch {
        throw ('Unable to dot source {0}' -f $file.FullName)
    }
}

# export all public functions
Export-ModuleMember -Function $Public.Basename
