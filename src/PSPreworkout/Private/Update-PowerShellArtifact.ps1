function Update-PowerShellArtifact {
    <#
    .SYNOPSIS
    Updates installed PowerShell modules, scripts, and help.

    .DESCRIPTION
    Handles PowerShell-native update operations and their progress reporting.

    .PARAMETER SkipModules
    Skips installed module updates.

    .PARAMETER SkipScripts
    Skips installed script updates.

    .PARAMETER SkipHelp
    Skips PowerShell help updates.

    .OUTPUTS
    None
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter()]
        [switch]$SkipModules,

        [Parameter()]
        [switch]$SkipScripts,

        [Parameter()]
        [switch]$SkipHelp
    )

    Write-UpdateAllTheThingsProgress -CurrentOperation 'Getting Installed PowerShell Modules' -PercentComplete 1

    if ($SkipModules) {
        Write-Information '[1] Skipping PowerShell Modules' -InformationAction Continue
    } elseif (-not (Test-PSPreworkoutCommand -Name 'Get-InstalledModule')) {
        Write-Warning 'Get-InstalledModule was not found. Skipping PowerShell module updates.'
    } else {
        Write-Information '[1] Getting Installed PowerShell Modules' -InformationAction Continue
        $Modules = @(Get-InstalledModule)
        Write-Information "[2] Updating $($Modules.Count) PowerShell Modules" -InformationAction Continue

        $ModuleIndex = 0
        foreach ($Module in $Modules) {
            ++$ModuleIndex
            $ModulePercent = [math]::Ceiling(($ModuleIndex / $Modules.Count) * 100)
            $OverallPercent = [math]::Ceiling(10 + (60 * ($ModulePercent / 100)))

            Write-UpdateAllTheThingsProgress -CurrentOperation "Updating PowerShell module $($Module.Name)" -PercentComplete $OverallPercent
            Write-Progress -Id 1 -ParentId 0 -Activity 'Updating PowerShell Modules' `
                -CurrentOperation $Module.Name -Status "Progress: $ModulePercent`% Complete" `
                -PercentComplete $ModulePercent

            if ($Module.Version -match 'alpha|beta|prerelease|preview') {
                Write-Information "`t`tSkipping $($Module.Name) because a prerelease version is currently installed." -InformationAction Continue
                continue
            }

            try {
                if ($PSCmdlet.ShouldProcess($Module.Name, 'Update PowerShell module')) {
                    Update-Module -Name $Module.Name
                }
            } catch [Microsoft.PowerShell.Commands.WriteErrorException] {
                Write-Warning "Unable to update PowerShell module '$($Module.Name)': $($_.Exception.Message)"
            }
        }
    }

    Write-Progress -Id 1 -Activity 'Updating PowerShell Modules' -Completed

    if ($SkipScripts) {
        Write-Information '[2] Skipping PowerShell Scripts' -InformationAction Continue
    } elseif (-not (Test-PSPreworkoutCommand -Name 'Update-Script')) {
        Write-Warning 'Update-Script was not found. Skipping PowerShell script updates.'
    } else {
        Write-Information '[2] Updating PowerShell Scripts' -InformationAction Continue
        if ($PSCmdlet.ShouldProcess('Installed PowerShell scripts', 'Update scripts')) {
            Update-Script
        }
    }

    Write-UpdateAllTheThingsProgress -CurrentOperation 'Updating PowerShell Help' -PercentComplete 70

    if ($SkipHelp) {
        Write-Information '[3] Skipping PowerShell Help' -InformationAction Continue
    } else {
        Write-Information '[3] Updating PowerShell Help' -InformationAction Continue
        if ($PSCmdlet.ShouldProcess('PowerShell help files', 'Update help')) {
            if ((Get-Culture).LCID -eq 127) {
                Update-Help -UICulture en-US -ErrorAction SilentlyContinue
            } else {
                Update-Help -ErrorAction SilentlyContinue
            }
        }
    }
}
