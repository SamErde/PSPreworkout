function Show-LoadedAssembly {
    <#
    .SYNOPSIS
    Show all assemblies loaded in PowerShell.

    .DESCRIPTION
    Show all assemblies loaded in PowerShell.

    .PARAMETER GridView
    Show the results in a grid view.

    .EXAMPLE
    Show-LoadedAssembly

    Shows a simple list of all loaded assemblies.

    .EXAMPLE
    Show-LoadedAssembly -GridView

    Shows a list of all loaded assemblies in a grid view.

    #>
    [CmdletBinding(HelpUri = 'https://raw.githubusercontent.com/SamErde/PSPreworkout/main/src/Help/')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'But this is better.')]
    # [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'There is a lot of them.')]
    [Alias('Show-LoadedAssemblies')]
    param (
        # Show a grid view of the loaded assemblies
        [Parameter()]
        [switch]
        $GridView
    )

    $LoadedAssemblies = Get-LoadedAssembly | Select-Object -Property FullName, Location, GlobalAssemblyCache, IsFullyTrusted |
        ForEach-Object {
            # Create a custom object to split out the details of each assembly
            $NameSplit = $_.FullName.Split(',').Trim()
            [PSCustomObject]@{
                Name                = [string]$NameSplit[0]
                Version             = [version]($NameSplit[1].Replace('Version=', ''))
                Location            = [string]$_.Location
                GlobalAssemblyCache = [bool]$_.GlobalAssemblyCache
                IsFullyTrusted      = [bool]$_.IsFullyTrusted
            }
        }

    if ($PSBoundParameters.ContainsKey('GridView')) {

        if ((Get-Command -Name Out-ConsoleGridView -ErrorAction SilentlyContinue) -and ($PSVersionTable.PSEdition -eq 'Core')) {
            $LoadedAssemblies | Out-ConsoleGridView
        } elseif ((Get-Command -Name Out-GridView -ErrorAction SilentlyContinue) -and ($PSVersionTable.PSEdition -eq 'Desktop')) {
            $LoadedAssemblies | Out-GridView
        } else {
            Write-Output 'The Out-GridView and Out-ConsoleGridView cmdlets were not found. Please install the Microsoft.PowerShell.ConsoleGuiTools module or re-install the PowerShell ISE if using Windows PowerShell 5.1.'
            $LoadedAssemblies | Format-Table -AutoSize
        }
    }

    $LoadedAssemblies
}
