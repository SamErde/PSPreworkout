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

    .NOTES
    Author: Sam Erde
    Version: 1.0.0
    Modified: 2024-10-23

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
        #
    }

    process {
        [Environment]::SetEnvironmentVariable($Name, $Value, $Target)
    }

    end {
        #
    }
}
