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
    An example

    .NOTES
    General notes
    #>
    [Alias('sev')]
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'OK')]
    param (
        # The name of the environment variable to set.
        [Parameter(Mandatory)]
        [string]$Name,

        # The value of environment variable to set.
        [Parameter(Mandatory)]
        [string]
        $Value,

        # The target of the environment variable to set.
        [Parameter()]
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
