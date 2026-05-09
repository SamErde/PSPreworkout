function Edit-WinGetSettingsFile {
    <#
    .SYNOPSIS
    Edit the WinGet settings file.

    .DESCRIPTION
    A shortcut to edit the WinGet settings file. This will create one if it does not already exist.

    .EXAMPLE
    Edit-WinGetSettingsFile
    #>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Edit-WinGetSettingsFile')]
    param (
        # To Do: Add parameters to choose an editor
    )

    # Send non-identifying usage statistics to PostHog.
    Write-PSPreworkoutTelemetry -EventName $MyInvocation.MyCommand.Name -ParameterNamesOnly $MyInvocation.BoundParameters.Keys

    try {
        winget settings
    } catch {
        throw "Failed to open WinGet settings: $_"
    }

} # end function Edit-WinGetSettingsFile
