function Get-Types {
    <#
    .SYNOPSIS
    List all available .NET types and type accelerators.

    .DESCRIPTION
    List all available types and type accelerators. These can be useful when trying to find or remember the different types and accellerators that are available to use in PowerShell.

    .EXAMPLE
    Get-Types

    #>
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', 'Get-Types', Justification = 'The types are plural.')]
    param ()
    [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get
}
