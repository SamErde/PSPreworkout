function Edit-PSReadLineHistoryFile {
    <#
        .SYNOPSIS
        Edit the PSReadLine History File

        .DESCRIPTION
        Use this function to edit the PSReadLine history file. This may be useful if you want
        to reset some of your autocomplete suggestions or remove commands that did not work.

        .EXAMPLE
        Edit-PSReadLineHistoryFile

        .NOTES
        Author: Sam Erde
        Version: 0.0.1
        Modified: 2024-10-10
    #>

    [CmdletBinding()]
    [Alias('Edit-HistoryFile')]
    param (

    )

    begin {

    } # end begin block

    process {
        $filePath = (Get-PSReadLineOption).HistorySavePath
        Start-Process code -ArgumentList "$filePath"

        # Use VS Code API to set language
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
'@

        # Save the VS Code script to a temporary file
        $TempScript = [System.IO.Path]::GetTempFileName() + '.js'
        Set-Content -Path $TempScript -Value $VSCodeScript

        # Run the VS Code script with Node.js
        Start-Process node -ArgumentList "$TempScript `"$filePath`""
    } # end process block

    end {

    } # end end block

} # end function Edit-PSReadLineHistoryFile
