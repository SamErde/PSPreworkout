function Get-Types {
    <#
    .SYNOPSIS
    List all available types and type accelerators.

    .DESCRIPTION
    List all available types and type accelerators.

    .EXAMPLE
    Get-Types

    #>
    [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get
}
