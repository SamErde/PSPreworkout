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
        $HistoryFilePath = (Get-PSReadLineOption).HistorySavePath
    } # end begin block

    process {
        if ((Get-Command code)) {
            # Open the file in Visual Studio Code if code found
            code $HistoryFilePath

            <#
            if ((Get-Command node -ErrorAction SilentlyContinue)) {
                # Use the Visual Studio Code API to set the open file's language (this portion rendered by AI).
                $VSCodeScript = @'
const vscode = require('vscode');

function setLanguage(uri, language) {
    vscode.workspace.openTextDocument(uri).then(document => {
        vscode.window.showTextDocument(document).then(() => {
            vscode.languages.setTextDocumentLanguage(document, language);
        });
    });
}

const uri = vscode.Uri.file(process.argv[2]);
setLanguage(uri, 'powershell');
'@ # End VSCodeScript (this portion rendered by AI)

                # Save the VS Code script to a temporary file and then run it.
                $TempScriptFile = [System.IO.Path]::GetTempFileName() + '.js'
                Set-Content -Path $TempScriptFile -Value $VSCodeScript -Force
                node $TempScriptFile "`'$HistoryFilePath`'"
            }
#> # End scriptblock to set the file language to 'PowerShell'

        } else {
            # Open the text file with the default file handler if VS Code is not found.
            Start-Process $HistoryFilePath
        }
    } # end process block

    end {
        Remove-Item -Path $TempScriptFile -Confirm:$false
    } # end end block

} # end function Edit-PSreadLineHistoryFile
