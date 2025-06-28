function Edit-PSReadLineHistoryFile {
    <#
    .SYNOPSIS
    Edit the PSReadLine History File

    .DESCRIPTION
    Use this function to edit the PSReadLine history file. This may be useful if you want to reset some of your
    autocomplete suggestions or remove commands that did not work.

    .EXAMPLE
    Edit-PSReadLineHistoryFile

    .NOTES
    Author: Sam Erde
    Version: 0.0.3
    Modified: 2025-01-06
    #>

    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Edit-PSReadLineHistoryFile')]
    [Alias('Edit-HistoryFile')]
    param ( )

    $HistoryFilePath = (Get-PSReadLineOption).HistorySavePath
    if ((Get-Command code)) {
        # Open the file in Visual Studio Code if code found
        code $HistoryFilePath
    } else {
        # Open the text file with the default file handler if VS Code is not found.
        Start-Process $HistoryFilePath
    }

} # end function Edit-PSreadLineHistoryFile
