function Get-LoadedAssembly {
    <#
    .SYNOPSIS
    Get all assemblies loaded in PowerShell.

    .DESCRIPTION
    Get all assemblies loaded in PowerShell.

    .EXAMPLE
    Get-LoadedAssembly

    Returns a list of all loaded assemblies.

    .NOTES
    To Do: Add -Name parameter to get a specific one.

    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'But this is better.')]
    # [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'There is a lot of them.')]
    [Alias('Get-Assembly')]
    param ()

    [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object -FilterScript { $_.Location } | Sort-Object -Property FullName

}
