BeforeAll {
    # Import the module or function under test
    $ModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $PublicPath = Join-Path -Path $ModulePath -ChildPath 'PSPreworkout\Public'

    function Write-PSPreworkoutTelemetry {
        [CmdletBinding()]
        param(
            [Parameter()]
            [string]$EventName,

            [Parameter()]
            [string[]]$ParameterNamesOnly
        )

        $EventName, $ParameterNamesOnly | Out-Null
    }

    function Test-IsElevated {
        [CmdletBinding()]
        param()

        return $false
    }

    function gh {
        [CmdletBinding()]
        param(
            [Parameter(ValueFromRemainingArguments)]
            [string[]]$Arguments
        )

        $Arguments | Out-Null
    }

    function copilot {
        [CmdletBinding()]
        param(
            [Parameter(ValueFromRemainingArguments)]
            [string[]]$Arguments
        )

        $Arguments | Out-Null
    }

    . (Join-Path -Path $PublicPath -ChildPath 'Update-AllTheThings.ps1')
}

Describe 'Update-AllTheThings' {
    Context 'Parameter Validation' {
        It 'Should have the correct parameters defined' {
            $Function = Get-Command Update-AllTheThings
            $Function.Parameters.Keys | Should -Contain 'SkipModules'
            $Function.Parameters.Keys | Should -Contain 'SkipScripts'
            $Function.Parameters.Keys | Should -Contain 'SkipHelp'
            $Function.Parameters.Keys | Should -Contain 'SkipWinGet'
            $Function.Parameters.Keys | Should -Contain 'IncludeChocolatey'
            $Function.Parameters.Keys | Should -Contain 'AcceptPrompts'
        }

        It 'Should have the correct alias' {
            $Function = Get-Command Update-AllTheThings
            $Function.Definition | Should -Match '\[Alias\(''uatt''\)\]'
        }

        It 'Should have AcceptPrompts parameter as a switch' {
            $Function = Get-Command Update-AllTheThings
            $AcceptPromptsParam = $Function.Parameters['AcceptPrompts']
            $AcceptPromptsParam.ParameterType.Name | Should -Be 'SwitchParameter'
        }

        It 'Should have AcceptPrompts parameter set as optional' {
            $Function = Get-Command Update-AllTheThings
            $AcceptPromptsParam = $Function.Parameters['AcceptPrompts']
            $AcceptPromptsParam.Attributes.Mandatory | Should -Not -Contain $true
        }

        It 'Should support ShouldProcess' {
            $Function = Get-Command Update-AllTheThings
            $Function.Parameters.Keys | Should -Contain 'WhatIf'
            $Function.Parameters.Keys | Should -Contain 'Confirm'
        }

        It 'Should have IncludeChocolatey parameter with SkipChoco alias' {
            $Function = Get-Command Update-AllTheThings
            $IncludeChocolateyParam = $Function.Parameters['IncludeChocolatey']
            $IncludeChocolateyParam.Aliases | Should -Contain 'SkipChoco'
        }
    }

    Context 'Help Documentation' {
        It 'Should have help documentation' {
            $Help = Get-Help Update-AllTheThings
            $Help | Should -Not -BeNullOrEmpty
            $Help.Synopsis | Should -Not -BeNullOrEmpty
        }

        It 'Should have AcceptPrompts parameter documented in help' {
            $Help = Get-Help Update-AllTheThings -Parameter AcceptPrompts
            $Help | Should -Not -BeNullOrEmpty
            $Help.Description.Text | Should -Match 'accept prompts.*Linux'
        }

        It 'Should have examples in help documentation' {
            $Help = Get-Help Update-AllTheThings -Examples
            $Help.Examples.Example | Should -Not -BeNullOrEmpty
            $Help.Examples.Example.Count | Should -BeGreaterOrEqual 2
        }

        It 'Should mention GitHub CLI tools in help description' {
            $Help = Get-Help Update-AllTheThings
            $Help.Description.Text | Should -Match 'GitHub CLI'
            $Help.Description.Text | Should -Match 'GitHub Copilot CLI'
        }

        It 'Should have an example demonstrating AcceptPrompts usage' {
            $Help = Get-Help Update-AllTheThings -Examples
            $ExamplesText = $Help.Examples.Example.Code -join ' '
            $ExamplesText | Should -Match '-AcceptPrompts'
        }
    }

    Context 'Function Definition' {
        It 'Should have CmdletBinding attribute' {
            $Function = Get-Command Update-AllTheThings
            $Function.CmdletBinding | Should -Not -BeNullOrEmpty
        }

        It 'Should have PSUseSingularNouns suppression attribute' {
            $Function = Get-Command Update-AllTheThings
            $Function.ScriptBlock.Attributes.TypeId.Name | Should -Contain 'SuppressMessageAttribute'
        }

        It 'Should have PSAvoidUsingWriteHost suppression attribute' {
            $Function = Get-Command Update-AllTheThings
            $Function.ScriptBlock.Attributes.TypeId.Name | Should -Contain 'SuppressMessageAttribute'
        }

        It 'Should update installed GitHub CLI extensions when gh is available' {
            $Function = Get-Command Update-AllTheThings
            $Function.Definition | Should -Match 'gh extension upgrade --all'
        }

        It 'Should update GitHub Copilot CLI when copilot is available' {
            $Function = Get-Command Update-AllTheThings
            $Function.Definition | Should -Match 'copilot update'
        }
    }

    Context 'GitHub CLI Tool Updates' {
        BeforeEach {
            Mock Set-PSRepository {}
            Mock Write-Host {}
            Mock Write-Progress {}
            Mock Write-Verbose {}
            Mock gh {}
            Mock copilot {}
        }

        It 'Runs gh extension upgrade when gh is available' {
            Mock Get-Command {
                param($Name)

                if ($Name -eq 'gh') {
                    return @{ Name = 'gh' }
                }

                return $null
            }

            Update-AllTheThings -SkipModules -SkipScripts -SkipHelp -SkipWinGet

            Should -Invoke gh -Exactly 1 -ParameterFilter { ($Arguments -join ' ') -eq 'extension upgrade --all' }
        }

        It 'Does not run gh extension upgrade when gh is unavailable' {
            Mock Get-Command { $null }

            Update-AllTheThings -SkipModules -SkipScripts -SkipHelp -SkipWinGet

            Should -Invoke gh -Exactly 0
        }

        It 'Runs copilot update when copilot is available' {
            Mock Get-Command {
                param($Name)

                if ($Name -eq 'copilot') {
                    return @{ Name = 'copilot' }
                }

                return $null
            }

            Update-AllTheThings -SkipModules -SkipScripts -SkipHelp -SkipWinGet

            Should -Invoke copilot -Exactly 1 -ParameterFilter { ($Arguments -join ' ') -eq 'update' }
        }

        It 'Does not run copilot update when copilot is unavailable' {
            Mock Get-Command { $null }

            Update-AllTheThings -SkipModules -SkipScripts -SkipHelp -SkipWinGet

            Should -Invoke copilot -Exactly 0
        }
    }

    Context 'Parameter Types' {
        It 'Should have all Skip parameters as switch type' {
            $Function = Get-Command Update-AllTheThings
            $Function.Parameters['SkipModules'].ParameterType.Name | Should -Be 'SwitchParameter'
            $Function.Parameters['SkipScripts'].ParameterType.Name | Should -Be 'SwitchParameter'
            $Function.Parameters['SkipHelp'].ParameterType.Name | Should -Be 'SwitchParameter'
            $Function.Parameters['SkipWinGet'].ParameterType.Name | Should -Be 'SwitchParameter'
        }

        It 'Should have IncludeChocolatey parameter as switch type' {
            $Function = Get-Command Update-AllTheThings
            $Function.Parameters['IncludeChocolatey'].ParameterType.Name | Should -Be 'SwitchParameter'
        }

        It 'Should have AcceptPrompts parameter as switch type' {
            $Function = Get-Command Update-AllTheThings
            $Function.Parameters['AcceptPrompts'].ParameterType.Name | Should -Be 'SwitchParameter'
        }
    }
}
