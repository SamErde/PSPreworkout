function Edit-WingetSettingsFile {
    <#
    .SYNOPSIS
    Edit the WinGet settings file.

    .DESCRIPTION
    A shortcut to edit the WinGet settings file. This will create one if it does not already exist.

    .EXAMPLE
    Edit-WinGetSettingsFile

    .NOTES
    Author: Sam Erde
    Version: 0.1.0
    Modified: 2024/10/12

    #>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Edit-WinGetSettingsFile')]
    param (
        # To Do: Add parameters to choose an editor
    )

    begin {
        $WinGetSettingsFile = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
        if (-not (Test-Path -PathType Leaf -Path $WinGetSettingsFile)) {
            Write-Information -MessageData 'No WinGet configuration file found. Creating a new one.' -InformationAction Continue
        }
    } # end begin block

    process {
        if ( (Get-Command code -ErrorAction SilentlyContinue) ) {
            code $WinGetSettingsFile
        } elseif ( (Get-Command notepad -ErrorAction SilentlyContinue) ) {
            notepad $WinGetSettingsFile
        } elseif ((Get-AppxPackage -Name 'Microsoft.WindowsNotepad' -ErrorAction SilentlyContinue)) {
            Start-Process "shell:AppsFolder\$(Get-StartApps -Name 'Notepad' | Select-Object -ExpandProperty AppId)" $WinGetSettingsFile
        } elseif (Get-Command 'powershell_ise.exe' -ErrorAction SilentlyContinue) {
            powershell_ise $WinGetSettingsFile
        } else {
            Write-Warning -Message 'No editors were found. You might want to install Visual Studio Code, Notepad, or Notepad++.'
        }
    } # end process block

    end {
        # end
    }
} # end function Edit-WinGetSettingsFile
