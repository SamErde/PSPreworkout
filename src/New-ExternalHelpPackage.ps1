Copy-Item "$PSScriptRoot\Artifacts\en-US\PSPreworkout-help.xml" "$PSScriptRoot\Help\en-US"
$params = @{
    CabFilesFolder  = "$PSScriptRoot\Help\en-US"
    LandingPagePath = "$PSScriptRoot\..\docs\PSPreworkout.md"
    OutputFolder    = "$PSScriptRoot\Help\en-US"
}
New-ExternalHelpCab @params
