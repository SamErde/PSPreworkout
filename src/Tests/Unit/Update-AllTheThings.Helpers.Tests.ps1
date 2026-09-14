BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\Helpers\Update-AllTheThings.TestHelpers.ps1')
}

BeforeDiscovery {
    $ExternalCommandCases = @(
        @{
            Name        = 'WinGet'
            CommandName = 'Invoke-WinGetUpgrade'
        }
        @{
            Name        = 'GitHub CLI extension'
            CommandName = 'Invoke-GitHubCliExtensionUpgrade'
        }
        @{
            Name        = 'GitHub Copilot CLI'
            CommandName = 'Invoke-GitHubCopilotCliUpdate'
        }
    )
}

Describe 'Update-AllTheThings compatibility helpers' {
    Context 'Get-PSPreworkoutPlatform' {
        It 'returns the platform reported by the current PowerShell host' {
            $ExpectedPlatform = if ($PSVersionTable.PSEdition -eq 'Desktop') {
                'Windows'
            } elseif ($IsWindows) {
                'Windows'
            } elseif ($IsLinux) {
                'Linux'
            } elseif ($IsMacOS) {
                'macOS'
            } else {
                'Unknown'
            }

            Get-PSPreworkoutPlatform | Should -Be $ExpectedPlatform
        }
    }

    Context 'Test-PSPreworkoutCommand' {
        BeforeEach {
            Mock Get-Command
        }

        It 'returns true for an available command' {
            Mock Get-Command { @{ Name = 'Get-Command' } }

            Test-PSPreworkoutCommand -Name 'Get-Command' | Should -BeTrue
        }

        It 'returns false for an unavailable command' {
            Test-PSPreworkoutCommand -Name 'PSPreworkout.Command.That.Does.Not.Exist' | Should -BeFalse
        }
    }

    Context 'Get-WindowsOperatingSystemCaption' {
        BeforeEach {
            $script:AvailableCommands = @()
            Mock Test-PSPreworkoutCommand { $Name -in $script:AvailableCommands }
            Mock Get-CimOperatingSystemCaption
            Mock Get-WmiOperatingSystemCaption
            Mock Write-Verbose
        }

        It 'uses CIM when it is available' {
            $script:AvailableCommands = @('Get-CimInstance')
            Mock Get-CimOperatingSystemCaption { 'Windows 11 Pro' }

            Get-WindowsOperatingSystemCaption | Should -Be 'Windows 11 Pro'

            Should -Invoke Get-CimOperatingSystemCaption -Exactly 1
            Should -Invoke Get-WmiOperatingSystemCaption -Exactly 0
        }

        It 'falls back to WMI when CIM fails' {
            $script:AvailableCommands = @('Get-CimInstance', 'Get-WmiObject')
            Mock Get-CimOperatingSystemCaption { throw 'CIM failure' }
            Mock Get-WmiOperatingSystemCaption { 'Windows Server 2025 Datacenter' }

            Get-WindowsOperatingSystemCaption | Should -Be 'Windows Server 2025 Datacenter'

            Should -Invoke Get-CimOperatingSystemCaption -Exactly 1
            Should -Invoke Get-WmiOperatingSystemCaption -Exactly 1
        }

        It 'returns no caption when neither API is available' {
            Get-WindowsOperatingSystemCaption | Should -BeNullOrEmpty

            Should -Invoke Get-CimOperatingSystemCaption -Exactly 0
            Should -Invoke Get-WmiOperatingSystemCaption -Exactly 0
        }
    }

    Context 'operating-system query wrappers' {
        It 'returns the CIM query result' {
            Get-CimOperatingSystemCaption -Query { 'Windows 11 Pro' } |
                Should -Be 'Windows 11 Pro'
        }

        It 'returns the WMI query result' {
            Get-WmiOperatingSystemCaption -Query { 'Windows Server 2025 Datacenter' } |
                Should -Be 'Windows Server 2025 Datacenter'
        }
    }

    Context 'Read-WinGetServerChoice' {
        It 'defaults to declining the update' {
            $HostUserInterface = [PSCustomObject]@{}
            $HostUserInterface | Add-Member -MemberType ScriptMethod -Name PromptForChoice -Value {
                param($Title, $Message, $Options, $DefaultChoice)

                $Title | Should -Be 'Windows Server OS Found'
                $Message | Should -Match 'winget upgrade'
                $Options | Should -HaveCount 2
                return $DefaultChoice
            }

            Read-WinGetServerChoice -HostUserInterface $HostUserInterface | Should -Be 1
        }
    }

    Context 'external command wrappers' {
        It 'completes the <Name> update when the command succeeds' -ForEach $ExternalCommandCases {
            { & $CommandName -Command { 0 } } | Should -Not -Throw
        }

        It 'throws for a failed <Name> update' -ForEach $ExternalCommandCases {
            { & $CommandName -Command { 23 } } | Should -Throw '*exit code 23*'
        }
    }
}
