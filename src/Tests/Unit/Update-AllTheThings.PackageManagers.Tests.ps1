BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\Helpers\Update-AllTheThings.TestHelpers.ps1')
}

Describe 'Update-AllTheThings package-manager helpers' {
    BeforeEach {
        $script:AvailableCommands = @()

        Mock Test-PSPreworkoutCommand { $Name -in $script:AvailableCommands }
        Mock Test-IsElevated { $true }
        Mock Invoke-UpdateNativeCommand
        Mock Write-Information
        Mock Write-Verbose
        Mock Write-Warning
        Mock Write-UpdateAllTheThingsProgress
    }

    Context 'Linux package updates' {
        It 'updates apt non-interactively without sudo when elevated' {
            $script:AvailableCommands = @('apt')

            Update-LinuxPackage -AcceptPrompts -Confirm:$false

            Should -Invoke Invoke-UpdateNativeCommand -Exactly 1 -ParameterFilter {
                $Name -eq 'apt' -and ($ArgumentList -join ' ') -eq 'update'
            }
            Should -Invoke Invoke-UpdateNativeCommand -Exactly 1 -ParameterFilter {
                $Name -eq 'apt' -and ($ArgumentList -join ' ') -eq 'upgrade -y'
            }
        }

        It 'uses sudo for dnf when not elevated' {
            $script:AvailableCommands = @('dnf')
            Mock Test-IsElevated { $false }

            Update-LinuxPackage -Confirm:$false

            Should -Invoke Invoke-UpdateNativeCommand -Exactly 1 -ParameterFilter {
                $Name -eq 'sudo' -and ($ArgumentList -join ' ') -eq 'dnf update'
            }
        }

        It 'does not invoke package managers during WhatIf' {
            $script:AvailableCommands = @('apt', 'dnf')

            Update-LinuxPackage -WhatIf

            Should -Invoke Invoke-UpdateNativeCommand -Exactly 0
        }

        It 'does not inspect elevation when no supported package manager is installed' {
            Update-LinuxPackage

            Should -Invoke Test-IsElevated -Exactly 0
            Should -Invoke Invoke-UpdateNativeCommand -Exactly 0
        }
    }

    Context 'macOS package updates' {
        It 'updates system software and Homebrew' {
            $script:AvailableCommands = @('brew')

            Update-MacOSPackage -Confirm:$false

            Should -Invoke Invoke-UpdateNativeCommand -Exactly 1 -ParameterFilter {
                $Name -eq 'softwareupdate' -and ($ArgumentList -join ' ') -eq '-l'
            }
            Should -Invoke Invoke-UpdateNativeCommand -Exactly 1 -ParameterFilter {
                $Name -eq 'brew' -and ($ArgumentList -join ' ') -eq 'update'
            }
            Should -Invoke Invoke-UpdateNativeCommand -Exactly 1 -ParameterFilter {
                $Name -eq 'brew' -and ($ArgumentList -join ' ') -eq 'upgrade'
            }
        }
    }

    Context 'Chocolatey package updates' {
        It 'updates Chocolatey features and packages when included and elevated' {
            $script:AvailableCommands = @('choco')

            Update-ChocolateyPackage -Include -Confirm:$false

            Should -Invoke Invoke-UpdateNativeCommand -Exactly 4
            Should -Invoke Invoke-UpdateNativeCommand -Exactly 1 -ParameterFilter {
                ($ArgumentList -join ' ') -eq 'upgrade chocolatey -y --limit-output --accept-license --no-color'
            }
            Should -Invoke Invoke-UpdateNativeCommand -Exactly 1 -ParameterFilter {
                ($ArgumentList -join ' ') -eq 'upgrade all -y --limit-output --accept-license --no-color'
            }
        }

        It 'does not invoke Chocolatey when it is not included' {
            $script:AvailableCommands = @('choco')

            Update-ChocolateyPackage

            Should -Invoke Invoke-UpdateNativeCommand -Exactly 0
        }
    }
}
