function Install-CommandNotFoundUtility {
    <#
    .SYNOPSIS
    Install and setup the WinGetCommandNotFound utility from Microsoft PowerToys.

    .DESCRIPTION
    This script installs the Microsoft.WinGet.CommandNotFound module and enables the required PowerShell features.

    .EXAMPLE
    Install-CommandNotFoundUtility

    .NOTES
    Author: Sam Erde
    Version: 0.1.1
    Modified: 2025-02-08
    #>
    #requires -version 7.4
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Install-CommandNotFoundUtility')]
    param (
    )

    begin {
    } # end begin block

    process {
        try {
            Install-Module -Name Microsoft.WinGet.CommandNotFound -Scope CurrentUser -Force
        catch {
            throw $_
        }
        try {
            # Might need to  remove this to avoid errors during PSPreworkout installation.
            Import-Module -Name Microsoft.WinGet.CommandNotFound -ErrorAction SilentlyContinue
        } catch [System.InvalidOperationException] {
            Write-Warning -Message "Received the error `"$_`" while importing the 'Microsoft.WinGet.CommandNotFound module. The module may have already been installed and imported in the current session. This can usually be ignored.`n"
        } # end try/catch block

        # To Do: Check if already enabled:
        Enable-ExperimentalFeature -Name 'PSFeedbackProvider'
        Enable-ExperimentalFeature -Name 'PSCommandNotFoundSuggestion'
    } # end process block

    end {
        Write-Information -MessageData "`nThe WinGetCommandNotFound utility has been installed. Be sure to add it to your PowerShell profile with `Import-Module Microsoft.WinGet.CommandNotFound`.`n`nYou may also run <https://github.com/microsoft/PowerToys/blob/main/src/settings-ui/Settings.UI/Assets/Settings/Scripts/EnableModule.ps1> to perform this step automatically.`n" -InformationAction Continue
    } # end end block

} # end function Install-CommandNotFoundUtility
