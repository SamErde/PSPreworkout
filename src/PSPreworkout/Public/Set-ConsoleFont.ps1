function Set-ConsoleFont {
    <#
    .SYNOPSIS
    Set the font for your consoles in Windows.

    .DESCRIPTION
    Set-ConsoleFont allows you to set the font for all of your registered Windows consoles (Windows PowerShell,
    Windows Terminal, PowerShell, or Command Prompt). It provides tab-autocomplete for the font parameter, listing
    all of the Nerd Fonts and monospace fonts installed in Windows.

    .PARAMETER Font
    The name of the font to set for your consoles in Windows.

    .EXAMPLE
    Set-ConsoleFont -Font 'FiraCode Nerd Font'
    #>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Set-ConsoleFont')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'Argument completers are weird.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
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

    # Send non-identifying usage statistics to PostHog.
    Write-PSPreworkoutTelemetry -EventName $MyInvocation.MyCommand.Name -ParameterNamesOnly $MyInvocation.BoundParameters.Keys

    # Suppress PSScriptAnalyzer Errors
    $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter | Out-Null

    # Your logic to set the console font goes here
    Write-Output "Setting console font to $Font."

    if ($IsLinux -or $IsMacOS) {
        Write-Information 'Setting the font is not yet supported in Linux or macOS.' -InformationAction Continue
        return
    }

    try {
        Get-ChildItem -Path 'HKCU:\Console' | ForEach-Object {
            Set-ItemProperty -Path (($_.Name).Replace('HKEY_CURRENT_USER', 'HKCU:')) -Name 'FaceName' -Value $Font
        }
    } catch {
        throw "Failed to set console font: $_"
    }
}

# Register the argument completer for Set-ConsoleFont.
Register-ArgumentCompleter -CommandName Set-ConsoleFont -ParameterName Font -ScriptBlock {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'Argument completers are weird.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    [System.Drawing.Text.InstalledFontCollection]::new().Families |
        Where-Object { $_.Name -match 'Mono|Courier|Consolas|Fixed|Console|Terminal|Nerd Font|NF[\s|\b]|NFP' } |
            ForEach-Object { "'$($_.Name)'" }

    # Suppress PSScriptAnalyzer Errors
    $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter | Out-Null
}
