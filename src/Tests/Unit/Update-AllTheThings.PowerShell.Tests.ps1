BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\Helpers\Update-AllTheThings.TestHelpers.ps1')
}

Describe 'Update-AllTheThings PowerShell updates' {
    BeforeEach {
        $script:AvailableCommands = @('Get-InstalledModule', 'Update-Script')

        Mock Test-PSPreworkoutCommand { $Name -in $script:AvailableCommands }
        Mock Get-InstalledModule {
            @(
                [PSCustomObject]@{ Name = 'StableModule'; Version = [version]'1.2.3' }
                [PSCustomObject]@{ Name = 'PreviewModule'; Version = '2.0.0-preview1' }
            )
        }
        Mock Update-Module
        Mock Update-Script
        Mock Update-Help
        Mock Get-Culture { [cultureinfo]'en-US' }
        Mock Write-Information
        Mock Write-Warning
        Mock Write-Verbose
        Mock Write-Progress
        Mock Write-UpdateAllTheThingsProgress
    }

    It 'updates stable modules, scripts, and help' {
        Update-PowerShellArtifact -Confirm:$false

        Should -Invoke Update-Module -Exactly 1 -ParameterFilter { $Name -eq 'StableModule' }
        Should -Invoke Update-Module -Exactly 0 -ParameterFilter { $Name -eq 'PreviewModule' }
        Should -Invoke Update-Script -Exactly 1
        Should -Invoke Update-Help -Exactly 1
    }

    It 'skips every PowerShell update when requested' {
        Update-PowerShellArtifact -SkipModules -SkipScripts -SkipHelp

        Should -Invoke Get-InstalledModule -Exactly 0
        Should -Invoke Update-Module -Exactly 0
        Should -Invoke Update-Script -Exactly 0
        Should -Invoke Update-Help -Exactly 0
    }

    It 'skips unavailable module and script tooling with explicit warnings' {
        $script:AvailableCommands = @()

        Update-PowerShellArtifact -SkipHelp

        Should -Invoke Write-Warning -Exactly 2
        Should -Invoke Update-Module -Exactly 0
        Should -Invoke Update-Script -Exactly 0
    }
}
