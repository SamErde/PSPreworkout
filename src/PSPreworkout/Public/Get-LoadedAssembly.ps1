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
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Get-LoadedAssembly')]
    [OutputType('Object[]')]

    [Alias('Get-Assembly')]
    param ()

    # Send non-identifying usage statistics to PostHog.
    Write-PSPreworkoutTelemetry -EventName $MyInvocation.MyCommand.Name -ParameterNamesOnly $MyInvocation.BoundParameters.Keys

    [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object -FilterScript { $_.Location } | Sort-Object -Property FullName
}
