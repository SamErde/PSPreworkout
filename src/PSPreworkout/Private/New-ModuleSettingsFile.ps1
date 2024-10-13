function New-ModuleSettingsFile {
    <#
    .SYNOPSIS
    Create a new module settings file.

    .DESCRIPTION
    This function creates a new module settings file for the current user in their
    $HOME/.config/{ModuleName} directory.

    .EXAMPLE
    New-ModuleSettingsFile

    .NOTES
    Author: Sam Erde
    Version: 0.0.1
    Modified: 2024-10-12
    #>

    [CmdletBinding(SupportsShouldProcess)]
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

        $DirectoryPath = [System.IO.Path]::Join($HOME, '.config', $ModuleName)
        if (-not (Test-Path -Path $DirectoryPath)) {
            try {
                New-Item -ItemType Directory -Path $DirectoryPath -Verbose
            } catch {
                $_
                return
            }
        }

        $FilePath = [System.IO.Path]::Join($DirectoryPath, 'settings.json')
        if (-not (Test-Path -Path $FilePath)) {
            try {
                New-Item -Path $FilePath -ItemType File
            } catch {
                $_
                return
            }
        }

    } # end process block

    end {

    } # end end block

} # end function New-ModuleConfigurationFile
