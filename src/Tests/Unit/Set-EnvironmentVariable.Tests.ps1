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

    . (Join-Path -Path $PublicPath -ChildPath 'Set-EnvironmentVariable.ps1')
}

Describe 'Set-EnvironmentVariable' {
    BeforeEach {
        [System.Environment]::SetEnvironmentVariable('PSPREWORKOUT_TEST_SET', $null, 'Process')
    }

    AfterEach {
        [System.Environment]::SetEnvironmentVariable('PSPREWORKOUT_TEST_SET', $null, 'Process')
    }

    It 'Supports ShouldProcess common parameters' {
        $Function = Get-Command Set-EnvironmentVariable

        $Function.Parameters.Keys | Should -Contain 'WhatIf'
        $Function.Parameters.Keys | Should -Contain 'Confirm'
    }

    It 'Sets an environment variable value when confirmed' {
        Set-EnvironmentVariable -Name 'PSPREWORKOUT_TEST_SET' -Value 'PesterValue' -Target Process

        [System.Environment]::GetEnvironmentVariable('PSPREWORKOUT_TEST_SET', 'Process') | Should -Be 'PesterValue'
    }

    It 'Does not set an environment variable value with WhatIf' {
        Set-EnvironmentVariable -Name 'PSPREWORKOUT_TEST_SET' -Value 'PesterValue' -Target Process -WhatIf

        [System.Environment]::GetEnvironmentVariable('PSPREWORKOUT_TEST_SET', 'Process') | Should -BeNullOrEmpty
    }
}

