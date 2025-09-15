function Set-EnvironmentVariable {
    <#
    .SYNOPSIS
    Set environment variables.

    .DESCRIPTION
    Set environment variables in any OS using .NET types.

    .PARAMETER Name
    Parameter description

    .PARAMETER Value
    Parameter description

    .PARAMETER Target
    Parameter description

    .EXAMPLE
    Set-EnvironmentVariable -Name 'FavoriteDrink' -Value 'Coffee' -Target 'User'

    #>
    [Alias('sev')]
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Set-EnvironmentVariable')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'OK')]
    param (
        # The name of the environment variable to set.
        [Parameter(Mandatory, Position = 0)]
        [string]$Name,

        # The value of environment variable to set.
        [Parameter(Mandatory, Position = 1)]
        [string]
        $Value,

        # The target of the environment variable to set.
        [Parameter(Mandatory, Position = 2)]
        [System.EnvironmentVariableTarget]
        $Target
    )

    begin {
        # Send non-identifying usage statistics to PostHog.
        Write-PSPreworkoutTelemetry -EventName $MyInvocation.MyCommand.Name -ParameterNamesOnly $MyInvocation.BoundParameters.Keys
    }

    process {
        try {
            [Environment]::SetEnvironmentVariable($Name, $Value, $Target)
        } catch {
            throw "Failed to set environment variable '$Name' with value '$Value' for target '$Target': $_"
        }
    }
}
