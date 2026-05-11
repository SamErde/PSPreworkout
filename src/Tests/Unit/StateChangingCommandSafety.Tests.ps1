BeforeAll {
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

    . (Join-Path -Path $PublicPath -ChildPath 'Install-OhMyPosh.ps1')
    . (Join-Path -Path $PublicPath -ChildPath 'Install-PowerShellISE.ps1')
    . (Join-Path -Path $PublicPath -ChildPath 'Install-WinGet.ps1')
    . (Join-Path -Path $PublicPath -ChildPath 'New-ScriptFromTemplate.ps1')
    . (Join-Path -Path $PublicPath -ChildPath 'Set-ConsoleFont.ps1')
    . (Join-Path -Path $PublicPath -ChildPath 'Set-DefaultTerminal.ps1')
}

Describe 'State-changing command safety' {
    It 'Exposes ShouldProcess common parameters for <Name>' -ForEach @(
        @{ Name = 'Install-OhMyPosh' }
        @{ Name = 'Install-PowerShellISE' }
        @{ Name = 'Install-WinGet' }
        @{ Name = 'New-ScriptFromTemplate' }
        @{ Name = 'Set-ConsoleFont' }
        @{ Name = 'Set-DefaultTerminal' }
    ) {
        $Function = Get-Command -Name $Name

        $Function.Parameters.Keys | Should -Contain 'WhatIf'
        $Function.Parameters.Keys | Should -Contain 'Confirm'
    }

    It 'Does not create a script file when New-ScriptFromTemplate runs with WhatIf' {
        $Path = 'TestDrive:\'

        New-ScriptFromTemplate -Name 'Get-GeneratedThing' -Synopsis 'Get a generated thing.' -Description 'Gets a generated thing.' -Author 'Pester' -Path $Path -SkipValidation -WhatIf

        Join-Path -Path $Path -ChildPath 'Get-GeneratedThing.ps1' | Should -Not -Exist
    }

    It 'Creates a script file from the template when confirmed' {
        $Path = 'TestDrive:\'
        $ScriptPath = Join-Path -Path $Path -ChildPath 'Get-GeneratedThing.ps1'

        New-ScriptFromTemplate -Name 'Get-GeneratedThing' -Synopsis 'Get a generated thing.' -Description 'Gets a generated thing.' -Alias 'ggt' -Author 'Pester' -Path $Path -SkipValidation

        $ScriptPath | Should -Exist
        Get-Content -Path $ScriptPath -Raw | Should -BeLike '*function Get-GeneratedThing*'
        Get-Content -Path $ScriptPath -Raw | Should -BeLike "*[Alias('ggt')]*"
    }

    It 'Can evaluate the direct Oh My Posh install path with WhatIf without downloading a script' {
        Mock Invoke-RestMethod

        Install-OhMyPosh -Method direct -WhatIf

        Should -Invoke Invoke-RestMethod -Times 0 -Exactly
    }

    It 'Runs the mocked direct Oh My Posh installer from a downloaded file' {
        Mock Invoke-RestMethod {
            param(
                [Parameter()]
                [string]$Uri,

                [Parameter()]
                [string]$OutFile
            )

            $Uri | Out-Null
            "'mock installer ran'" | Set-Content -Path $OutFile -Encoding utf8
        }

        $Result = Install-OhMyPosh -Method direct 6>&1

        $Result | Should -Contain 'mock installer ran'
        Should -Invoke Invoke-RestMethod -Times 1 -Exactly
    }

    It 'Reports missing package managers for Oh My Posh package installs' {
        Mock Get-Command { $null } -ParameterFilter { $Name -in @('choco.exe', 'winget.exe') }

        { Install-OhMyPosh -Method chocolatey } | Should -Throw '*Chocolatey was not found*'
        { Install-OhMyPosh -Method winget } | Should -Throw '*WinGet was not found*'
    }

    It 'Can evaluate the Scoop Oh My Posh install path with WhatIf' {
        Install-OhMyPosh -Method scoop -WhatIf

        $true | Should -BeTrue
    }

    It 'Can evaluate the Oh My Posh font install path with WhatIf' {
        Install-OhMyPosh -Method scoop -InstallNerdFont -Font Meslo -WhatIf -InformationAction SilentlyContinue

        $true | Should -BeTrue
    }

    It 'Rejects Install-WinGet on non-Windows platforms' -Skip:($IsWindows) {
        { Install-WinGet -WhatIf } | Should -Throw '*only supported on Windows*'
    }

    It 'Rejects Install-PowerShellISE on non-Windows platforms' -Skip:($IsWindows) {
        { Install-PowerShellISE -WhatIf } | Should -Throw '*only supported on Windows*'
    }

    It 'Rejects Set-DefaultTerminal on non-Windows platforms' -Skip:($IsWindows) {
        { Set-DefaultTerminal -WhatIf } | Should -Throw '*only supported on Windows*'
    }
}

