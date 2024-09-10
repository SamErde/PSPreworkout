param (
    # Type of version level update
    [Parameter(Position = 0)]
    [ValidateSet('Major', 'Minor', 'Build')]
    [string]
    $VersionLevel,

    # Custom version declaration
    [Parameter()]
    [version]
    $CustomVersion,

    # Publish the script
    [Parameter()]
    [switch]
    $Publish
)

# Detect if running as a script or copy/paste in shell ($PSScriptRoot vs $PWD).
if ($PSScriptRoot) {
    $ScriptInfo = (Join-Path -Path $PSScriptRoot -ChildPath 'Update-AllTheThings_ScriptInfo.ps1')
    $Path1 = $([System.IO.Path]::Combine($PSScriptRoot, '..', 'src', 'PSPreworkout', 'Public', 'Test-IsElevated.ps1'))
    $Path2 = $([System.IO.Path]::Combine($PSScriptRoot, '..', 'src', 'PSPreworkout', 'Public', 'Update-AllTheThings.ps1'))
} else {
    $ScriptInfo = (Join-Path -Path $pwd -ChildPath 'Update-AllTheThings_ScriptInfo.ps1')
    $Path1 = $([System.IO.Path]::Combine($PWD, '..', 'src', 'PSPreworkout', 'Public', 'Test-IsElevated.ps1'))
    $Path2 = $([System.IO.Path]::Combine($PWD, '..', 'src', 'PSPreworkout', 'Public', 'Update-AllTheThings.ps1'))
}

# Get the contents of the PSScriptInfo file and any scripts to merge.
$Content0 = Get-Content -Path $ScriptInfo
$Content1 = Get-Content -Path $Path1
$Content2 = Get-Content -Path $Path2

if ($CustomVersion) {
    # Manually set a custom new version number.
    $NewVersion = "v$($CustomVersion.Replace('v',''))"
} else {
    # Find the current version number in file Content2.
    $SemVerPattern = 'v(\d+)\.(\d+)\.(\d+)'
    $SemVerMatch = [regex]::Match($Content2, $SemVerPattern)

    # Remove the 'v' and incrememnt the manjor, minor, or build # if specified by function parameters.
    $CurrentVersion = [version]$($semVerMatch.Value).Replace('v', '')
    if ($VersionLevel -eq 'Major') {
        $NewVersion = [version]::new($CurrentVersion.Major + 1, 0, 0)
        $NewVersion = "v$($NewVersion)"
    }
    if ($VersionLevel -eq 'Minor') {
        $NewVersion = [version]::new($CurrentVersion.Major, $CurrentVersion.Minor + 1, 0)
        $NewVersion = "v$($NewVersion)"
    }
    if ($Versionlevel -eq 'Build') {
        $NewVersion = [version]::new($CurrentVersion.Major, $CurrentVersion.Minor, $CurrentVersion.Build + 1)
        $NewVersion = "v$($NewVersion)"
    }
}

# Check the version number in PSScriptInfo.
$ScriptInfoVersion = $Content0 | Select-String -Pattern '.VERSION ((\d+).(\d+).(\d+))'
if ($NewVersion -ne $ScriptInfoVersion) {
    # Align the version to the contents of the script if they are different.
    $Content0 = $Content0.Replace($ScriptInfoVersion, ".VERSION $($NewVersion.Replace('v',''))")
}

# Set the new version number in the contents of the script.
$Content2 = $Content2.Replace($($SemVerMatch.Value), $NewVersion)

# Write the PSScriptInfo and scripts into the merged script.
$Content0 + $Content1 + $Content2 | Set-Content -Path 'Update-AllTheThings.ps1'

if ($PSBoundParameters.ContainsKey('Publish')) {
    # Publish-Script -Path ./Update-AllTheThings -NuGetApiKey ${{ secrets.POWERSHELLGALLERY_KEY }}
}
