function Edit-PSReadLineHistoryFile {
    <#
    .SYNOPSIS
    Edit the PSReadLine History File

    .DESCRIPTION
    Use this function to edit the PSReadLine history file. This may be useful if you want to reset some of your autocomplete suggestions orremove commands that did not work.

    .EXAMPLE
    Edit-PSReadLineHistoryFile

    .NOTES
    Author: Sam Erde
    Version: 0.0.1
    Modified: 2024-10-10

    Idea: History search with a TUI? This may already be done by the PowerShell Run module.

    #>
    [CmdletBinding()]
    [Alias('Edit-HistoryFile')]
    param (

    )

    begin {

    } # end begin block

    process {
        if ((Get-Command code)) {
            Start-Process code -ArgumentList (Get-PSReadLineOption).HistorySavePath
        } else {
            Start-Process (Get-PSReadLineOption).HistorySavePath
        }
    } # end process block

    end {

    } # end end block

} # end function Edit-PSreadLineHistoryFile
