function Get-ModuleSettingsFilePath {
    <#
        .SYNOPSIS
        Get the path to a module's settings file.

        .DESCRIPTION
        This function will get the path to a module's settings file, if one exists.

        .EXAMPLE
        Get-ModuleSettingsFilePath -Module 'PSPreworkout'

        .NOTES
        Author: Sam Erde
        Version: 0.0.1
        Modified: 2024-10-13
    #>

    [CmdletBinding()]
    [OutputType('System.String')]
    param (

    )

    begin {

    } # end begin block

    process {
        if ( $($MyInvocation.MyCommand.ModuleName)) {
            $ModuleName = $($MyInvocation.MyCommand.ModuleName)
        } else {
            # Set the ModuleName for use while developing or debuging outside of an imported module.
            $ModuleName = 'PSPreworkout' # Can be changed for other modules.
        }

        $SettingsFilePath = [System.IO.Path]::Join($HOME, '.config', $ModuleName, 'settings.json')
        $PathDetails = @{
            Path   = $SettingsFilePath
            Exists = (Test-Path -Path $SettingsFilePath -PathType Leaf)
        }
    } # end process block

    end {
        $PathDetails
    } # end end block

} # end function Get-ModuleSettingsFile
