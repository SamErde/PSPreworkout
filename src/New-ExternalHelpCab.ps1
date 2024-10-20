$params = @{
    CabFilesFolder  = "$PSScriptRoot\Artifacts\en-US"
    LandingPagePath = "$PSScriptRoot\..\docs\PSPreworkout.md"
    OutputFolder    = "$PSScriptRoot\Artifacts\en-US"
}
New-ExternalHelpCab @params
