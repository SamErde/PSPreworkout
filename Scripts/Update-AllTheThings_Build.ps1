[CmdletBinding()]
param (
    # Type of version level update
    [Parameter(Position = 0)]
    [ValidateSet('Major', 'Minor', 'Patch')]
    [string]
    $VersionLevel,

    # Custom version declaration
    [Parameter()]
    [version]
    $CustomVersion,

    # Publish the script
    [Parameter()]
    [switch]
    $Publish,

    # Destination for the generated standalone script
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]
    $OutputPath
)

$ScriptsRoot = if ($PSScriptRoot) {
    $PSScriptRoot
} else {
    $PWD.Path
}

$RepositoryRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $ScriptsRoot -ChildPath '..'))
$ModuleRoot = Join-Path -Path $RepositoryRoot -ChildPath 'src\PSPreworkout'
$ScriptInfoPath = Join-Path -Path $ScriptsRoot -ChildPath 'Update-AllTheThings_ScriptInfo.ps1'
$UpdateCommandPath = Join-Path -Path $ModuleRoot -ChildPath 'Public\Update-AllTheThings.ps1'

if (-not $PSBoundParameters.ContainsKey('OutputPath')) {
    $OutputPath = Join-Path -Path $ScriptsRoot -ChildPath 'Update-AllTheThings.ps1'
}

$SourcePaths = @(
    (Join-Path -Path $ModuleRoot -ChildPath 'Private\Test-PSPreworkoutCommand.ps1')
    (Join-Path -Path $ModuleRoot -ChildPath 'Private\Get-PSPreworkoutPlatform.ps1')
    (Join-Path -Path $ModuleRoot -ChildPath 'Private\Write-UpdateAllTheThingsProgress.ps1')
    (Join-Path -Path $ModuleRoot -ChildPath 'Private\Invoke-UpdateNativeCommand.ps1')
    (Join-Path -Path $ModuleRoot -ChildPath 'Private\Get-CimOperatingSystemCaption.ps1')
    (Join-Path -Path $ModuleRoot -ChildPath 'Private\Get-WmiOperatingSystemCaption.ps1')
    (Join-Path -Path $ModuleRoot -ChildPath 'Private\Get-WindowsOperatingSystemCaption.ps1')
    (Join-Path -Path $ModuleRoot -ChildPath 'Private\Read-WinGetServerChoice.ps1')
    (Join-Path -Path $ModuleRoot -ChildPath 'Private\Invoke-WinGetUpgrade.ps1')
    (Join-Path -Path $ModuleRoot -ChildPath 'Private\Invoke-GitHubCliExtensionUpgrade.ps1')
    (Join-Path -Path $ModuleRoot -ChildPath 'Private\Invoke-GitHubCopilotCliUpdate.ps1')
    (Join-Path -Path $ModuleRoot -ChildPath 'Private\Set-UpdateRepositoryTrust.ps1')
    (Join-Path -Path $ModuleRoot -ChildPath 'Private\Update-PowerShellArtifact.ps1')
    (Join-Path -Path $ModuleRoot -ChildPath 'Private\Update-WinGetPackage.ps1')
    (Join-Path -Path $ModuleRoot -ChildPath 'Private\Update-LinuxPackage.ps1')
    (Join-Path -Path $ModuleRoot -ChildPath 'Private\Update-MacOSPackage.ps1')
    (Join-Path -Path $ModuleRoot -ChildPath 'Private\Update-OptionalCli.ps1')
    (Join-Path -Path $ModuleRoot -ChildPath 'Private\Update-ChocolateyPackage.ps1')
    (Join-Path -Path $ModuleRoot -ChildPath 'Public\Test-IsElevated.ps1')
    $UpdateCommandPath
)

$ScriptInfoContent = Get-Content -LiteralPath $ScriptInfoPath -Raw
$UpdateCommandContent = Get-Content -LiteralPath $UpdateCommandPath -Raw
$NewLine = [string][char]13 + [string][char]10

$SemVerPattern = 'v(\d+)\.(\d+)\.(\d+)'
$SemVerMatch = [regex]::Match($UpdateCommandContent, $SemVerPattern)
if (-not $SemVerMatch.Success) {
    throw "Unable to find a semantic version in '$UpdateCommandPath'."
}

$CurrentVersion = [version]$SemVerMatch.Groups[0].Value.TrimStart('v')

if ($CustomVersion) {
    $NewVersion = $CustomVersion
} else {
    switch ($VersionLevel) {
        'Major' {
            $NewVersion = [version]::new($CurrentVersion.Major + 1, 0, 0)
        }
        'Minor' {
            $NewVersion = [version]::new($CurrentVersion.Major, $CurrentVersion.Minor + 1, 0)
        }
        'Patch' {
            $NewVersion = [version]::new($CurrentVersion.Major, $CurrentVersion.Minor, $CurrentVersion.Build + 1)
        }
        default {
            $NewVersion = $CurrentVersion
        }
    }
}

$ScriptInfoVersionPattern = '(?m)^\.VERSION\s+\d+\.\d+\.\d+\s*$'
if (-not [regex]::IsMatch($ScriptInfoContent, $ScriptInfoVersionPattern)) {
    throw "Unable to find a .VERSION declaration in '$ScriptInfoPath'."
}

$ScriptInfoContent = [regex]::Replace(
    $ScriptInfoContent,
    $ScriptInfoVersionPattern,
    ".VERSION $NewVersion"
)
$UpdateCommandContent = $UpdateCommandContent.Replace($SemVerMatch.Value, "v$NewVersion")

$GeneratedParts = @(($ScriptInfoContent -replace "`r`n?|\n", $NewLine).TrimEnd())
foreach ($SourcePath in $SourcePaths) {
    if ($SourcePath -eq $UpdateCommandPath) {
        $GeneratedParts += ($UpdateCommandContent -replace "`r`n?|\n", $NewLine).TrimEnd()
    } else {
        $SourceContent = Get-Content -LiteralPath $SourcePath -Raw
        $GeneratedParts += ($SourceContent -replace "`r`n?|\n", $NewLine).TrimEnd()
    }
}

$GeneratedContent = ($GeneratedParts -join ($NewLine + $NewLine)) + $NewLine
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($OutputPath, $GeneratedContent, $Utf8NoBom)

if ($Publish) {
    if (-not $env:POWERSHELLGALLERY_KEY) {
        throw 'POWERSHELLGALLERY_KEY environment variable is not set.'
    }

    Publish-Script -Path $OutputPath -NuGetApiKey $env:POWERSHELLGALLERY_KEY -ErrorAction Stop
}
