function Get-Types {
    <#
    .SYNOPSIS
    List all available types and type accelerators.

    .DESCRIPTION
    List all available types and type accelerators.

    .EXAMPLE
    Get-Types

    #>
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', 'Get-Types', Justification = 'The types are plural.')]
    param ()
    [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get
}
