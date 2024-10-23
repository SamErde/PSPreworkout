function Install-CommandNotFoundUtility {
    <#
        .SYNOPSIS
        Install and setup the WinGetCommandNotFound utility from Microsoft PowerToys.

        .DESCRIPTION
        This script installs the Microsoft.WinGet.CommandNotFound module and
        enables the required experimental features in PowerShell 7.

        .EXAMPLE
        Install-CommandNotFoundUtility

        .NOTES
        Author: Sam Erde
        Version: 0.0.1
        Modified: 2024-10-14

        May not work with PowerShell installed from MSIX or the Microsoft Store: <https://github.com/microsoft/PowerToys/issues/30818>
    #>

    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Install-CommandNotFoundUtility')]

    param (

    )

    begin {

    } # end begin block

    process {
        # Can be installed independently of PowerToys now
        # Start-Process 'winget' -ArgumentList 'install --id Microsoft.PowerToys --source winget' -Wait -NoNewWindow

        # To Do: Check for installed module and module version
        Install-Module -Name Microsoft.WinGet.CommandNotFound -Scope CurrentUser -Force
        Import-Module -Name Microsoft.WinGet.CommandNotFound

        # To Do: Check if already enabled:
        Enable-ExperimentalFeature -Name 'PSFeedbackProvider'
        Enable-ExperimentalFeature -Name 'PSCommandNotFoundSuggestion'

        # Add to profile:
        # <https://github.com/microsoft/PowerToys/blob/main/src/settings-ui/Settings.UI/Assets/Settings/Scripts/EnableModule.ps1>

    } # end process block

    end {

    } # end end block

} # end function Install-CommandNotFoundUtility
