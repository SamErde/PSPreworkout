BeforeDiscovery {
    $PlatformCases = @(
        @{
            Platform        = 'Windows'
            ExpectedCommand = 'Update-WinGetPackage'
        }
        @{
            Platform        = 'Linux'
            ExpectedCommand = 'Update-LinuxPackage'
        }
        @{
            Platform        = 'macOS'
            ExpectedCommand = 'Update-MacOSPackage'
        }
    )
}

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\Helpers\Update-AllTheThings.TestHelpers.ps1')
}

Describe 'Update-AllTheThings orchestration' {
    BeforeEach {
        Mock Test-PSPreworkoutCommand { $false }
        Mock Get-PSPreworkoutPlatform { 'Unknown' }
        Mock Set-UpdateRepositoryTrust
        Mock Update-PowerShellArtifact
        Mock Update-WinGetPackage
        Mock Update-LinuxPackage
        Mock Update-MacOSPackage
        Mock Update-OptionalCli
        Mock Update-ChocolateyPackage
        Mock Write-Host
        Mock Write-Verbose
        Mock Write-UpdateAllTheThingsProgress
    }

    It 'runs the shared update stages once' {
        Update-AllTheThings -SkipModules -SkipScripts -SkipHelp -SkipWinGet

        Should -Invoke Set-UpdateRepositoryTrust -Exactly 1
        Should -Invoke Update-PowerShellArtifact -Exactly 1 -ParameterFilter {
            $SkipModules -and $SkipScripts -and $SkipHelp
        }
        Should -Invoke Update-OptionalCli -Exactly 2
        Should -Invoke Update-ChocolateyPackage -Exactly 1
    }

    It 'runs only the <Platform> platform updater' -ForEach $PlatformCases {
        Mock Get-PSPreworkoutPlatform { $Platform }

        Update-AllTheThings -SkipModules -SkipScripts -SkipHelp -Confirm:$false

        Should -Invoke -CommandName $ExpectedCommand -Exactly 1
        Should -Invoke Update-WinGetPackage -Exactly ([int]($Platform -eq 'Windows'))
        Should -Invoke Update-LinuxPackage -Exactly ([int]($Platform -eq 'Linux'))
        Should -Invoke Update-MacOSPackage -Exactly ([int]($Platform -eq 'macOS'))
    }

    It 'forwards package-manager options to their update stages' {
        Mock Get-PSPreworkoutPlatform { 'Windows' }

        Update-AllTheThings -SkipModules -SkipScripts -SkipHelp -SkipWinGet `
            -AcceptPrompts -IncludeChocolatey -Confirm:$false

        Should -Invoke Update-WinGetPackage -Exactly 1 -ParameterFilter {
            $Skip -and $AcceptPrompts -and (-not $Confirm)
        }
        Should -Invoke Update-ChocolateyPackage -Exactly 1 -ParameterFilter {
            $Include -and (-not $Confirm)
        }
    }

    It 'forwards WhatIf to update stages' {
        Update-AllTheThings -SkipModules -SkipScripts -SkipHelp -SkipWinGet -WhatIf

        Should -Invoke Set-UpdateRepositoryTrust -Exactly 1 -ParameterFilter { $WhatIf }
        Should -Invoke Update-PowerShellArtifact -Exactly 1 -ParameterFilter { $WhatIf }
        Should -Invoke Update-OptionalCli -Exactly 2 -ParameterFilter { $WhatIf }
        Should -Invoke Update-ChocolateyPackage -Exactly 1 -ParameterFilter { $WhatIf }
    }
}
