function Get-LoadedAssemblies {
    <#
    .SYNOPSIS
    Get all assemblies loaded in PowerShell.

    .DESCRIPTION
    Get all assemblies loaded in PowerShell.

    .PARAMETER GridView
    Show the results in a grid view.

    .EXAMPLE
    Get-LoadedAssemblies

    Returns a list of all loaded assemblies.

    .EXAMPLE
    Get-LoadedAssemblies -GridView

    Shows a list of all loaded assemblies in a grid view.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'But this is better.')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'There is a lot of them.')]
    [Alias('Show-Assemblies')]
    param (
        # Show a grid view of the loaded assemblies
        [Parameter()]
        [switch]
        $GridView
    )

    $LoadedAssemblies = [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object -FilterScript { $_.Location } | Sort-Object -Property FullName | Select-Object -Property FullName, Location, GlobalAssemblyCache, IsFullyTrusted

    if ($PSBoundParameters.ContainsKey('GridView')) {

        if ((Get-Command -Name Out-ConsoleGridView -ErrorAction SilentlyContinue) -and ($PSVersionTable.PSEdition -eq 'Core')) {

            $LoadedAssemblies | Out-ConsoleGridView -OutputMode Multiple

        } elseif ((Get-Command -Name Out-GridView -ErrorAction SilentlyContinue) -and ($PSVersionTable.PSEdition -eq 'Desktop')) {

            $LoadedAssemblies | Out-GridView -OutputMode Multiple

        } else {
            Write-Output 'The Out-GridView and Out-ConsoleGridView cmdlets were not found. Please install the Microsoft.PowerShell.ConsoleGuiTools module or re-install the PowerShell ISE if using Windows PowerShell 5.1.'
            $LoadedAssemblies | Format-Table -AutoSize
        }
    }
    $LoadedAssemblies
}
