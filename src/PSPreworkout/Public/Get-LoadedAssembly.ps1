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

    Author: Sam Erde
    Version: 0.0.2
    Modified: 2024/10/12
    #>
    [CmdletBinding(HelpUri = 'https://raw.githubusercontent.com/SamErde/PSPreworkout/main/src/Help/')]
    [OutputType('System.Array')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'But this is better.')]
    [Alias('Get-Assembly')]
    param ()

    [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object -FilterScript { $_.Location } | Sort-Object -Property FullName
}
