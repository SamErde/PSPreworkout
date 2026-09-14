BeforeDiscovery {
    $CliCases = @(
        @{
            Name          = 'GitHub CLI extensions'
            CommandName   = 'gh'
            UpdateCommand = 'Invoke-GitHubCliExtensionUpgrade'
            UpdateScript  = { Invoke-GitHubCliExtensionUpgrade }
        }
        @{
            Name          = 'GitHub Copilot CLI'
            CommandName   = 'copilot'
            UpdateCommand = 'Invoke-GitHubCopilotCliUpdate'
            UpdateScript  = { Invoke-GitHubCopilotCliUpdate }
        }
    )
}

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\Helpers\Update-AllTheThings.TestHelpers.ps1')
}

Describe 'Update-AllTheThings optional CLI updates' {
    BeforeEach {
        $script:AvailableCommands = @()

        Mock Test-PSPreworkoutCommand { $Name -in $script:AvailableCommands }
        Mock Write-Information
        Mock Write-UpdateAllTheThingsProgress
        Mock Write-Verbose
        Mock Invoke-GitHubCliExtensionUpgrade
        Mock Invoke-GitHubCopilotCliUpdate
    }

    It 'updates <Name> when <CommandName> is available' -ForEach $CliCases {
        $script:AvailableCommands = @($CommandName)
        $UpdateParameters = @{
            CommandName      = $CommandName
            DisplayName      = "Updating $Name"
            CurrentOperation = "Updating $Name"
            TargetName       = $Name
            ActionName       = "Update $Name"
            PercentComplete  = 90
            UpdateCommand    = $UpdateScript
            Confirm          = $false
        }

        Update-OptionalCli @UpdateParameters

        Should -Invoke -CommandName $UpdateCommand -Exactly 1
    }

    It 'does not update <Name> when <CommandName> is unavailable' -ForEach $CliCases {
        Update-OptionalCli -CommandName $CommandName -DisplayName "Updating $Name" `
            -CurrentOperation "Updating $Name" -TargetName $Name -ActionName "Update $Name" `
            -PercentComplete 90 -UpdateCommand $UpdateScript -Confirm:$false

        Should -Invoke -CommandName $UpdateCommand -Exactly 0
    }

    It 'does not run optional CLI updates during WhatIf' {
        $script:AvailableCommands = @('gh', 'copilot')

        Update-OptionalCli -CommandName 'gh' -DisplayName 'Updating GitHub CLI extensions' `
            -CurrentOperation 'Updating GitHub CLI extensions' -TargetName 'GitHub CLI extensions' `
            -ActionName 'Update GitHub CLI extensions' -PercentComplete 90 `
            -UpdateCommand { Invoke-GitHubCliExtensionUpgrade } -WhatIf
        Update-OptionalCli -CommandName 'copilot' -DisplayName 'Updating GitHub Copilot CLI' `
            -CurrentOperation 'Updating GitHub Copilot CLI' -TargetName 'GitHub Copilot CLI' `
            -ActionName 'Update GitHub Copilot CLI' -PercentComplete 95 `
            -UpdateCommand { Invoke-GitHubCopilotCliUpdate } -WhatIf

        Should -Invoke Invoke-GitHubCliExtensionUpgrade -Exactly 0
        Should -Invoke Invoke-GitHubCopilotCliUpdate -Exactly 0
    }
}
