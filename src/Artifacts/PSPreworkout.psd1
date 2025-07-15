@{

    # Script module or binary module file associated with this manifest.
    RootModule           = 'PSPreworkout.psm1'

    # Version number of this module.
    ModuleVersion        = '1.9.6.10'

    # Supported PSEditions = @('Desktop', 'Core')
    CompatiblePSEditions = @('Core', 'Desktop')

    # ID used to uniquely identify this module
    GUID                 = '378339de-a0df-4d44-873b-4fd32c388e06'

    # Author of this module
    Author               = 'Sam Erde'

    # Company or vendor of this module
    CompanyName          = 'Sam Erde'

    # Copyright statement for this module
    Copyright            = '(c) 2025, Sam Erde. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'A special mix of tools to help jump start your PowerShell session!'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion    = '5.1'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = @(
        'Edit-PSReadLineHistoryFile',
        'Edit-WinGetSettingsFile',
        'Get-CommandHistory',
        'Get-EnvironmentVariable',
        'Get-HashtableValueType',
        'Get-LoadedAssembly',
        'Get-ModulesWithUpdate',
        'Get-PowerShellPortable',
        'Get-TypeAccelerator',
        'Initialize-PSEnvironmentConfiguration',
        'Install-CommandNotFoundUtility',
        'Install-OhMyPosh',
        'Install-PowerShellISE',
        'Install-WinGet',
        'New-Credential',
        'New-ScriptFromTemplate',
        'Out-JsonFile',
        'Set-ConsoleFont',
        'Set-DefaultTerminal',
        'Set-EnvironmentVariable',
        'Show-LoadedAssembly',
        'Show-WithoutEmptyProperty',
        'Test-IsElevated',
        'Update-AllTheThings',
        # Aliases
        'Edit-HistoryFile',
        'Get-Assembly',
        'Get-PSPortable',
        'Init-PSEnvConfig',
        'New-Script',
        'Show-LoadedAssemblies'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport      = @(
        'IsAdmin',
        'IsRoot',
        'UaTT',
        'Skip-Choco',
        'Edit-HistoryFile',
        'gch',
        'gev',
        'Get-Assembly',
        'Get-PSPortable',
        'Init-PSEnvConfig',
        'New-Script',
        'sev',
        'Show-LoadedAssemblies'
    )

    # List of all files packaged with this module
    FileList             = @(
        'Resources/ScriptTemplate.txt',
        'PSPreworkout.Format.ps1xml'
    )

    # Formats to process when this module is imported
    FormatsToProcess     = @(
        'PSPreworkout.Format.ps1xml'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = 'PowerShell', 'Utilities', 'Tools', 'Windows', 'Linux', 'macOS'

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/SamErde/PSPreworkout/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/SamErde/PSPreworkout'

            # A URL to an icon representing this module.
            IconUri      = 'https://raw.githubusercontent.com/SamErde/PSPreworkout/main/media/PSPreworkout-Animated-Logo-170.png'

            # ReleaseNotes of this module
            ReleaseNotes = 'See <https://github.com/SamErde/PSPreworkout/CHANGELOG.md> for more information.'

            # Prerelease string of this module
            # Prerelease   = ''

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    HelpInfoURI          = 'https://raw.githubusercontent.com/SamErde/PSPreworkout/main/docs'

}
