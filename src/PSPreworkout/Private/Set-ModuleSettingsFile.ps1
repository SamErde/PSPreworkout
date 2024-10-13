function Set-ModuleSettingsFile {
    <#
    .SYNOPSIS
    Set configuration items in a module configuration file.

    .DESCRIPTION
    This function sets configuration items in a module settings file.

    .EXAMPLE
    [System.Collections.IDictionary]$SettingsObject = [ordered]@{
        Name = 'Pat User'
        Email = 'pat.user@example.com'
        FavoriteColors = @('Blue','Green')
        Animal = 'Llama'
    }
    Set-ModuleSettingsFile -Settings $SettingsObject -Verbose
    
    VERBOSE: Settings written to '/Users/patuser/.config/PSPreworkout/settings.json'.
    VERBOSE: {
      "Name": "Pat User",
      "Animal": "Llama",
      "FavoriteColors": [
        "Blue",
        "Green"
      ],
      "Email": "pat.user@example.com"
    }

    .NOTES
    Author: Sam Erde
    Version: 0.0.1
    Modified: 2024-10-13
    #>

    [CmdletBinding(SupportsShouldProcess)]

    param (
        # A hash table containing the settings for the module
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [System.Collections.Hashtable]
        $SettingsObject
    )

    begin {
        if ( $($MyInvocation.MyCommand.ModuleName)) {
            $ModuleName = $($MyInvocation.MyCommand.ModuleName)
        } else {
            # Set the ModuleName for use while developing or debuging outside of an imported module.
            $ModuleName = 'PSPreworkout' # Can be changed for other modules.
        }

        $SettingsFile = Get-ModuleSettingsFilePath
        if (-not $SettingsFile.Exists) {
            New-ModuleSettingsFile
        }
    } # end begin block

    process {
        try {
            $SettingsJson = $SettingsObject | ConvertTo-Json
            $SettingsJson | ConvertTo-Json | Set-Content -Path $($SettingsFile.Path)
        } catch {
            $_
        }
    } # end process block

    end {
        Write-Verbose -Message "Settings written to `'$($SettingsFile.Path)`' for the `'$ModuleName`' module."
        Write-Verbose -Message $SettingsJson
    } # end end block

} # end function Set-ModuleSettingsFile
