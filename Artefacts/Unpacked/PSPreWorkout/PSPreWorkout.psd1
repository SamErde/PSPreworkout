@{
    AliasesToExport      = @('gev', 'sev', 'UATT')
    Author               = 'Sam Erde'
    CmdletsToExport      = @()
    CompanyName          = 'Sam Erde'
    CompatiblePSEditions = @('Desktop', 'Core')
    Copyright            = '(c) 2024 Sam Erde. All rights reserved.'
    Description          = 'A special mix of tools (and experiments) to help jump start your PowerShell work session!'
    FunctionsToExport    = @('Get-MsShellsModules', 'Read-ModuleInfo', 'Get-EnvironmentVariable', 'Install-OhMyPosh', 'Install-PowerShellISE', 'New-ProfileWorkspace', 'Set-EnvironmentVariable', 'Update-AllTheThings')
    GUID                 = '3ea876cf-733d-4ac4-bd85-25503534c966'
    ModuleVersion        = '0.0.2'
    PowerShellVersion    = '5.1'
    PrivateData          = @{
        PSData = @{
            ExternalModuleDependencies = @('powershellget')
            Tags                       = @('Windows', 'MacOS', 'Linux', 'PowerShell', 'Utility')
        }
    }
    RequiredModules      = @(@{
            Guid          = '1da87e53-152b-403e-98dc-74d7b4d63d59'
            ModuleName    = 'Microsoft.PowerShell.Utility'
            ModuleVersion = '3.1.0.0'
        }, @{
            Guid          = 'eefcb906-b326-4e99-9f54-8b4bb6ef3c6d'
            ModuleName    = 'Microsoft.PowerShell.Management'
            ModuleVersion = '3.1.0.0'
        }, @{
            Guid          = 'a94c8c7e-9810-47c0-b8af-65089c13a35a'
            ModuleName    = 'Microsoft.PowerShell.Security'
            ModuleVersion = '3.0.0.0'
        }, 'powershellget')
    RootModule           = 'PSPreWorkout.psm1'
    ScriptsToProcess     = @()
}