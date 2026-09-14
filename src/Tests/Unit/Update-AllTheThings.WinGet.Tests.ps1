BeforeDiscovery {
    $NonInteractiveConsentCases = @(
        @{
            Name            = 'WhatIf'
            Additional      = @{ WhatIf = $true }
            ExpectedUpdates = 0
        }
        @{
            Name            = 'Confirm false'
            Additional      = @{ Confirm = $false }
            ExpectedUpdates = 1
        }
        @{
            Name            = 'AcceptPrompts'
            Additional      = @{ AcceptPrompts = $true }
            ExpectedUpdates = 1
        }
    )
}

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\Helpers\Update-AllTheThings.TestHelpers.ps1')
}

Describe 'Update-AllTheThings WinGet behavior' {
    BeforeEach {
        $script:AvailableCommands = @('winget')

        Mock Test-PSPreworkoutCommand { $Name -in $script:AvailableCommands }
        Mock Get-WindowsOperatingSystemCaption { 'Windows Server 2025 Datacenter' }
        Mock Read-WinGetServerChoice { 0 }
        Mock Invoke-WinGetUpgrade
        Mock Write-Information
        Mock Write-UpdateAllTheThingsProgress
        Mock Write-Verbose
        Mock Write-Warning
    }

    It 'updates packages when the Windows Server prompt is accepted' {
        Update-WinGetPackage

        Should -Invoke Read-WinGetServerChoice -Exactly 1
        Should -Invoke Invoke-WinGetUpgrade -Exactly 1
    }

    It 'skips packages when the Windows Server prompt is declined' {
        Mock Read-WinGetServerChoice { 1 }

        Update-WinGetPackage

        Should -Invoke Read-WinGetServerChoice -Exactly 1
        Should -Invoke Invoke-WinGetUpgrade -Exactly 0
    }

    It 'does not prompt with <Name>' -ForEach $NonInteractiveConsentCases {
        $Parameters = @{}
        foreach ($Entry in $Additional.GetEnumerator()) {
            $Parameters[$Entry.Key] = $Entry.Value
        }

        Update-WinGetPackage @Parameters

        Should -Invoke Read-WinGetServerChoice -Exactly 0
        Should -Invoke Invoke-WinGetUpgrade -Exactly $ExpectedUpdates
    }

    It 'does not prompt on a Windows client' {
        Mock Get-WindowsOperatingSystemCaption { 'Microsoft Windows 11 Pro' }

        Update-WinGetPackage

        Should -Invoke Read-WinGetServerChoice -Exactly 0
        Should -Invoke Invoke-WinGetUpgrade -Exactly 1
    }

    It 'fails closed when the Windows caption cannot be determined' {
        Mock Get-WindowsOperatingSystemCaption

        Update-WinGetPackage

        Should -Invoke Write-Warning -Exactly 1 -ParameterFilter {
            $Message -match 'Unable to determine the Windows operating system caption'
        }
        Should -Invoke Invoke-WinGetUpgrade -Exactly 0
    }

    It 'does not inspect Windows when WinGet is skipped explicitly' {
        Update-WinGetPackage -Skip

        Should -Invoke Get-WindowsOperatingSystemCaption -Exactly 0
        Should -Invoke Read-WinGetServerChoice -Exactly 0
        Should -Invoke Invoke-WinGetUpgrade -Exactly 0
    }

    It 'skips WinGet when the command is unavailable' {
        $script:AvailableCommands = @()

        Update-WinGetPackage

        Should -Invoke Get-WindowsOperatingSystemCaption -Exactly 0
        Should -Invoke Invoke-WinGetUpgrade -Exactly 0
    }
}
