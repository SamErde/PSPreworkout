function Edit-PSReadLineHistoryFile {
    <#
    .SYNOPSIS
    Edit the PSReadLine History File

    .DESCRIPTION
    Use this function to edit the PSReadLine history file. This may be useful if you want to reset some of your
    autocomplete suggestions or remove commands that did not work.

    .EXAMPLE
    Edit-PSReadLineHistoryFile
    #>

    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Edit-PSReadLineHistoryFile')]
    [Alias('Edit-HistoryFile')]
    param ( )

    begin {
        # Send non-identifying usage statistics to PostHog.
        Write-PSPreworkoutTelemetry -EventName $MyInvocation.MyCommand.Name -ParameterNamesOnly $MyInvocation.BoundParameters.Keys
    }

    process {
        $HistoryFilePath = (Get-PSReadLineOption).HistorySavePath
        if ((Get-Command code)) {
            # Open the file in Visual Studio Code if code found
            try {
                code $HistoryFilePath
            } catch {
                throw "Failed to open history file in VS Code: $_"
            }
        } else {
            # Open the text file with the default file handler if VS Code is not found.
            try {
                Start-Process $HistoryFilePath
            } catch {
                throw "Failed to open history file with default handler: $_"
            }
        }
    }
} # end function Edit-PSReadLineHistoryFile
