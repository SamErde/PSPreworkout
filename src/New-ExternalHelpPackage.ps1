Copy-Item "$PSScriptRoot\Artifacts\en-US\PSPreworkout-help.xml" "$PSScriptRoot\PSPreworkout\en-US"
$params = @{
    CabFilesFolder  = "$PSScriptRoot\Artifacts\en-US"
    LandingPagePath = "$PSScriptRoot\..\docs\PSPreworkout.md"
    OutputFolder    = "$PSScriptRoot\PSPreworkout\en-US"
}
New-ExternalHelpCab @params -IncrementHelpVersion
