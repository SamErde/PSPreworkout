function Set-ConsoleFont {
    <#
    .SYNOPSIS
    Set the font for your consoles.

    .DESCRIPTION
    Set-ConsoleFont allows you to set the font for all of your registered consoles (PowerShell, Windows PowerShell,
    Windows Terminal, or Command Prompt). It provides tab-autocomplete for the font parameter, listing all of the Nerd
    Fonts and monospace fonts installed on your system.

    .PARAMETER Font
    The name of the font to set for your consoles.

    .EXAMPLE
    Set-ConsoleFont -Font 'FiraCode Nerd Font'
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ArgumentCompleter({
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                [System.Drawing.Text.InstalledFontCollection]::new().Families |
                    Where-Object { $_.Name -match 'Mono|Courier|Consolas|Fixed|Console|Terminal|Nerd Font|NF[\s|\b]|NFP' } |
                        ForEach-Object { "'$($_.Name)'" }
            })]
        [string]$Font
    )

    # Your logic to set the console font goes here
    Write-Output "Setting console font to $Font."

    if ($IsLinux -or $IsMacOS) {
        Write-Information 'Setting the font is not yet supported in Linux or macOS.' -InformationAction Continue
        return
    }

    Get-ChildItem -Path 'HKCU:\Console' | ForEach-Object {
        Set-ItemProperty -Path (($_.Name).Replace('HKEY_CURRENT_USER', 'HKCU:')) -Name 'FaceName' -Value $Font
    }
}

# Register the argument completer for Set-ConsoleFont.
Register-ArgumentCompleter -CommandName Set-ConsoleFont -ParameterName Font -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    [System.Drawing.Text.InstalledFontCollection]::new().Families |
        Where-Object { $_.Name -match 'Mono|Courier|Consolas|Fixed|Console|Terminal|Nerd Font|NF[\s|\b]|NFP' } |
            ForEach-Object { "'$($_.Name)'" }
}
