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
    Version: 0.0.2
    Modified: 2024/10/12

    #>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
    param (
        # Specify the path to the editor that you would like to use.
        [Parameter()]
        [ValidateScript({
                if ( -not (Test-Path -Path $_ ) ) {
                    throw 'The file does not exist.'
                }
                return $true
            })]
        [System.IO.FileInfo]
        $EditorPath
    )

    begin {
        $WinGetSettingsFile = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
        if (-not (Test-Path -PathType Leaf -Path $WinGetSettingsFile)) {
            # Exit the function if the WinGet settings file does not exist.
            Write-Information -MessageData 'WinGet is not installed.' -InformationAction Continue
            return
        }
    } # end begin block

    process {
        if ($PSBoundParameters.ContainsKey($EditorPath)) {
            Start-Process $EditorPath $WinGetSettingsFile
        } elseif ( (Get-Command code -ErrorAction SilentlyContinue) ) {
            code $WinGetSettingsFile
        } else {
            Start-Process notepad $WinGetSettingsFile
        }
    } # end process block

    end {
        # end
    }
} # end function Edit-WinGetSettingsFile
