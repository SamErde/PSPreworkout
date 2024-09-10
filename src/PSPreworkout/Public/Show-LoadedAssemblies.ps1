function Show-LoadedAssemblies {
    <#
    .SYNOPSIS
    Show all assemblies loaded in PowerShell.

    .DESCRIPTION
    Show all assemblies loaded in PowerShell.

    .EXAMPLE
    Show-LoadedAssemblies

    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'But this is better.')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'There is a lot of them.')]
    [Alias('Show-Assemblies')]
    param ( )

    if (Get-Command -Name Out-ConsoleGridView) {
        [System.AppDomain]::CurrentDomain.GetAssemblies() |
            Where-Object -FilterScript { $_.Location } |
                Sort-Object -Property FullName |
                    Select-Object -Property FullName, Location, GlobalAssemblyCache, IsFullyTrusted |
                        Out-ConsoleGridView -OutputMode Multiple
    } elseif (Get-Command -Name Out-GridView) {
        [System.AppDomain]::CurrentDomain.GetAssemblies() |
            Where-Object -FilterScript { $_.Location } |
                Sort-Object -Property FullName |
                    Select-Object -Property FullName, Location, GlobalAssemblyCache, IsFullyTrusted |
                        Out-GridView -OutputMode Multiple
    } else {
        [System.AppDomain]::CurrentDomain.GetAssemblies() |
            Where-Object -FilterScript { $_.Location } |
                Sort-Object -Property FullName |
                    Select-Object -Property FullName, Location, GlobalAssemblyCache, IsFullyTrusted |
                        Format-Table -AutoSize
    }
}
