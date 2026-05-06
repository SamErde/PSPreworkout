BeforeAll {
    $ModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $PrivatePath = Join-Path -Path $ModulePath -ChildPath 'PSPreworkout\Private'
    . (Join-Path -Path $PrivatePath -ChildPath 'Write-PSPreworkoutTelemetry.ps1')
}

Describe 'Write-PSPreworkoutTelemetry' {
    BeforeEach {
        [System.Environment]::SetEnvironmentVariable('PSPREWORKOUT_DISABLE_TELEMETRY', $null, 'Process')
    }

    AfterEach {
        [System.Environment]::SetEnvironmentVariable('PSPREWORKOUT_DISABLE_TELEMETRY', $null, 'Process')
    }

    It 'Does not send telemetry when disabled by environment variable' {
        [System.Environment]::SetEnvironmentVariable('PSPREWORKOUT_DISABLE_TELEMETRY', 'true', 'Process')
        Mock Invoke-RestMethod

        Write-PSPreworkoutTelemetry -EventName 'Test-Command'

        Should -Invoke Invoke-RestMethod -Times 0 -Exactly
    }

    It 'Posts telemetry with a short timeout and parameter names only' {
        Mock Invoke-RestMethod

        Write-PSPreworkoutTelemetry -EventName 'Test-Command' -ParameterNamesOnly 'Name', 'Target'

        Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
            $Uri -eq 'https://us.i.posthog.com/capture/' -and
            $Method -eq 'Post' -and
            $TimeoutSec -eq 2 -and
            ($Body | ConvertFrom-Json).properties.parameters_used[0] -eq 'Name'
        }
    }

    It 'Does not throw when telemetry submission fails' {
        Mock Invoke-RestMethod { throw 'offline' }

        { Write-PSPreworkoutTelemetry -EventName 'Test-Command' } | Should -Not -Throw
    }
}

