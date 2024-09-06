function Edit-WingetSettings {
    <#
    .SYNOPSIS
    Edit the WinGet settings file.

    .DESCRIPTION
    A shortcut to edit the WinGet settings file. This will create one if it does not already exist.

    .EXAMPLE
    Edit-WinGetSettings

    .NOTES
    This is just an idea that may or may not prove to be useful.
    #>
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', 'Edit-WingetSettings', Justification = 'The settings are plural.')]
    param (
    )

    begin {
    }

    process {
        if (Get-Command code -ErrorAction SilentlyContinue) {
            code (Get-WinGetSettings | Select-Object -ExpandProperty userSettingsFile)
        } else {
            notepad (Get-WinGetSettings | Select-Object -ExpandProperty userSettingsFile)
        }
    }

    end {
    }
}
