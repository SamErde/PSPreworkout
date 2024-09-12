function Edit-WingetSettingsFile {
    <#
    .SYNOPSIS
    Edit the WinGet settings file.

    .DESCRIPTION
    A shortcut to edit the WinGet settings file. This will create one if it does not already exist.

    .EXAMPLE
    Edit-WinGetSettingsFile

    .NOTES
    This is just an idea that may or may not prove to be useful.
    #>
    [CmdletBinding()]
    param (
    )

    if (Test-Path -PathType Container -Path "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState") {
        if (Get-Command code -ErrorAction SilentlyContinue) {
            code "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
        } else {
            notepad "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
        }
    } else {
        Write-Information -MessageData 'WinGet is not installed.' -InformationAction Continue
    }
}
