BeforeDiscovery {
    $SwitchParameterCases = @(
        @{ Name = 'SkipModules' }
        @{ Name = 'SkipScripts' }
        @{ Name = 'SkipHelp' }
        @{ Name = 'SkipWinGet' }
        @{ Name = 'IncludeChocolatey' }
        @{ Name = 'AcceptPrompts' }
    )

    $SuppressionCases = @(
        @{ Category = 'PSUseSingularNouns' }
        @{ Category = 'PSAvoidUsingWriteHost' }
        @{ Category = 'PSShouldProcess' }
    )
}
BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\Helpers\Update-AllTheThings.TestHelpers.ps1')

    $Command = Get-Command -Name Update-AllTheThings
    $Help = Get-Help -Name Update-AllTheThings -Full
}

Describe 'Update-AllTheThings command contract' {
    It 'defines <Name> as an optional switch' -ForEach $SwitchParameterCases {
        $Parameter = $Command.Parameters[$Name]
        $ParameterAttribute = $Parameter.Attributes |
            Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }

        $Parameter.ParameterType | Should -Be ([switch])
        $ParameterAttribute.Mandatory | Should -Not -Contain $true
    }

    It 'exposes the uatt alias' {
        $Command.ScriptBlock.Attributes.AliasNames | Should -Contain 'uatt'
    }

    It 'supports ShouldProcess' {
        $Command.Parameters.Keys | Should -Contain 'WhatIf'
        $Command.Parameters.Keys | Should -Contain 'Confirm'
    }

    It 'defines SkipChoco as an alias for IncludeChocolatey' {
        $Command.Parameters['IncludeChocolatey'].Aliases | Should -Contain 'SkipChoco'
    }

    It 'declares the <Category> analyzer suppression' -ForEach $SuppressionCases {
        $Suppressions = $Command.ScriptBlock.Attributes |
            Where-Object { $_ -is [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute] }

        $Suppressions.Category | Should -Contain $Category
    }

    It 'documents the command synopsis and examples' {
        $Help.Synopsis | Should -Not -BeNullOrEmpty
        $Help.Examples.Example | Should -HaveCount 2
    }

    It 'documents cross-platform AcceptPrompts behavior' {
        $ParameterHelp = Get-Help -Name Update-AllTheThings -Parameter AcceptPrompts

        $ParameterHelp.Description.Text | Should -Match 'accept prompts.*Linux'
        $ParameterHelp.Description.Text | Should -Match 'WinGet.*Windows Server'
    }

    It 'documents GitHub CLI updates' {
        $Help.Description.Text | Should -Match 'GitHub CLI'
        $Help.Description.Text | Should -Match 'GitHub Copilot CLI'
    }
}
