BeforeDiscovery {
    $CliCases = @(
        @{
            Name          = 'GitHub CLI extensions'
            CommandName   = 'gh'
            UpdateCommand = 'Invoke-GitHubCliExtensionUpgrade'
        }
        @{
            Name          = 'GitHub Copilot CLI'
            CommandName   = 'copilot'
            UpdateCommand = 'Invoke-GitHubCopilotCliUpdate'
        }
    )
}

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\Helpers\Update-AllTheThings.TestHelpers.ps1')
}

Describe 'Update-AllTheThings optional CLI updates' {
    BeforeEach {
        $script:AvailableCommands = @()
        $script:SkipUnrelatedUpdates = @{
            SkipModules = $true
            SkipScripts = $true
            SkipHelp    = $true
            SkipWinGet  = $true
        }

        Mock Get-PSPreworkoutPlatform { 'Unknown' }
        Mock Test-PSPreworkoutCommand { $Name -in $script:AvailableCommands }
        Mock Write-Host
        Mock Write-Progress
        Mock Write-Verbose
        Mock Invoke-GitHubCliExtensionUpgrade
        Mock Invoke-GitHubCopilotCliUpdate
    }

    It 'updates <Name> when <CommandName> is available' -ForEach $CliCases {
        $script:AvailableCommands = @($CommandName)

        Update-AllTheThings @script:SkipUnrelatedUpdates

        Should -Invoke -CommandName $UpdateCommand -Exactly 1
    }

    It 'does not update <Name> when <CommandName> is unavailable' -ForEach $CliCases {
        Update-AllTheThings @script:SkipUnrelatedUpdates

        Should -Invoke -CommandName $UpdateCommand -Exactly 0
    }

    It 'does not run optional CLI updates during WhatIf' {
        $script:AvailableCommands = @('gh', 'copilot')

        Update-AllTheThings @script:SkipUnrelatedUpdates -WhatIf

        Should -Invoke Invoke-GitHubCliExtensionUpgrade -Exactly 0
        Should -Invoke Invoke-GitHubCopilotCliUpdate -Exactly 0
    }
}
