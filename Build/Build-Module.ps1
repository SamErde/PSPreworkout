Build-Module -ModuleName 'PSPreWorkout' {
    # Usual defaults as per standard module
    $Manifest = [ordered] @{
        ModuleVersion          = '0.0.3'
        CompatiblePSEditions   = @('Desktop', 'Core')
        GUID                   = '3ea876cf-733d-4ac4-bd85-25503534c966'
        Author                 = 'Sam Erde'
        CompanyName            = 'Sam Erde'
        Copyright              = "(c) $((Get-Date).Year) Sam Erde. All rights reserved."
        Description            = 'A special mix of tools (and experiments) to help jump start your PowerShell work session!'
        PowerShellVersion      = '5.1'
        Tags                   = @('Windows','MacOS','Linux','PowerShell','Utility')
    }
    New-ConfigurationManifest @Manifest

    # Add standard module dependencies (directly, but can be used with loop as well)
    foreach ($Module in @('Microsoft.PowerShell.Utility', 'Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Security')) {
        New-ConfigurationModule -Type RequiredModule -Name $Module -Guid 'Auto' -Version 'Latest'
    }

    # Add external module dependencies, using loop for simplicity
    foreach ($Module in @('PowerShellGet')) {
         New-ConfigurationModule -Type ExternalModule -Name $Module
    }

    # Add approved modules, that can be used as a dependency, but only when specific function from those modules
    # is used, and on that time only that function and dependant functions will be copied over. Keep in mind it
    # has its limits when "copying" functions such as, it should not depend on DLLs or other external files.
    New-ConfigurationModule -Type ApprovedModule -Name @('AppX','Dism','powershell-yaml')

    # ExchangeOnlineManagement: Get-PSImplicitRemotingClientSideParameters and Get-PSImplicitRemotingSession
    New-ConfigurationModuleSkip -IgnoreFunctionName 'brew','scoop','softwareupdate','sudo','ConvertFrom-yaml' -IgnoreModuleName 'ExchangeOnlineManagement','powershell-yaml'

    $ConfigurationFormat = [ordered] @{
        RemoveComments                              = $false

        PlaceOpenBraceEnable                        = $true
        PlaceOpenBraceOnSameLine                    = $true
        PlaceOpenBraceNewLineAfter                  = $true
        PlaceOpenBraceIgnoreOneLineBlock            = $false

        PlaceCloseBraceEnable                       = $true
        PlaceCloseBraceNewLineAfter                 = $true
        PlaceCloseBraceIgnoreOneLineBlock           = $false
        PlaceCloseBraceNoEmptyLineBefore            = $true

        UseConsistentIndentationEnable              = $true
        UseConsistentIndentationKind                = 'space'
        UseConsistentIndentationPipelineIndentation = 'IncreaseIndentationAfterEveryPipeline'
        UseConsistentIndentationIndentationSize     = 4

        UseConsistentWhitespaceEnable               = $true
        UseConsistentWhitespaceCheckInnerBrace      = $true
        UseConsistentWhitespaceCheckOpenBrace       = $true
        UseConsistentWhitespaceCheckOpenParen       = $true
        UseConsistentWhitespaceCheckOperator        = $true
        UseConsistentWhitespaceCheckPipe            = $true
        UseConsistentWhitespaceCheckSeparator       = $true

        AlignAssignmentStatementEnable              = $true
        AlignAssignmentStatementCheckHashtable      = $true

        UseCorrectCasingEnable                      = $true
    }

    # Format PSD1 and PSM1 files when merging into a single file.
    # Enable formatting is not required as Configuration is provided
    New-ConfigurationFormat -ApplyTo 'OnMergePSM1', 'OnMergePSD1' -Sort None @ConfigurationFormat

    # Format PSD1 and PSM1 files within the module.
    # Enable formatting is required to make sure that formatting is applied (with default settings).
    New-ConfigurationFormat -ApplyTo 'DefaultPSD1', 'DefaultPSM1' -EnableFormatting -Sort None

    # When creating PSD1, use special style without comments, and with only required parameters.
    New-ConfigurationFormat -ApplyTo 'DefaultPSD1', 'OnMergePSD1' -PSD1Style 'Minimal'

    # Configuration for documentation. Also enables documentation processing.
    New-ConfigurationDocumentation -Enable:$false -StartClean -UpdateWhenNew -PathReadme 'Docs\Readme.md' -Path 'Docs'

    New-ConfigurationImportModule -ImportSelf -ImportRequiredModules

    New-ConfigurationBuild -Enable:$true -SignModule:$false -DeleteTargetModuleBeforeBuild -MergeModuleOnBuild -MergeFunctionsFromApprovedModules -DoNotAttemptToFixRelativePaths

    New-ConfigurationArtefact -Type Unpacked -Enable -Path "$PSScriptRoot\..\Artefacts\Unpacked" #-RequiredModulesPath "$PSScriptRoot\..\Artefacts\Modules"
    New-ConfigurationArtefact -Type Packed -Enable -Path "$PSScriptRoot\..\Artefacts\Packed" -IncludeTagName

    # Global options for publishing to GitHub / PSGallery:
    # New-ConfigurationPublish -Type PowerShellGallery -FilePath 'C:\Support\Important\PowerShellGalleryAPI.txt' -Enabled:$false
    # New-ConfigurationPublish -Type GitHub -FilePath 'C:\Support\Important\GitHubAPI.txt' -UserName 'CompanyName' -Enabled:$false
}
