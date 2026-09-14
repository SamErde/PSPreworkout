function Test-PSPreworkoutCommand {
    <#
    .SYNOPSIS
    Tests whether a command is available.

    .DESCRIPTION
    Resolves a command without emitting an error and returns whether it was found.

    .PARAMETER Name
    The name of the command to resolve.

    .OUTPUTS
    System.Boolean
    #>

    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    return $null -ne (Get-Command -Name $Name -ErrorAction SilentlyContinue)
}
