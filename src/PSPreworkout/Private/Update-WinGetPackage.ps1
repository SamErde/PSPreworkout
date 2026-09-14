function Update-WinGetPackage {
    <#
    .SYNOPSIS
    Updates user-scoped WinGet packages.

    .DESCRIPTION
    Applies Windows Server safeguards before invoking WinGet.

    .PARAMETER Skip
    Skips WinGet package updates.

    .PARAMETER AcceptPrompts
    Bypasses the additional Windows Server confirmation prompt.

    .OUTPUTS
    None
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter()]
        [switch]$Skip,

        [Parameter()]
        [switch]$AcceptPrompts
    )

    if ($Skip) {
        Write-Information '[4] Skipping WinGet' -InformationAction Continue
        return
    }

    if (-not (Test-PSPreworkoutCommand -Name 'winget')) {
        Write-Information '[4] WinGet was not found. Skipping WinGet update.' -InformationAction Continue
        return
    }

    $ShouldUpdate = $PSCmdlet.ShouldProcess('WinGet packages', 'Upgrade all user-scoped packages')
    $SkipServerPrompt = $AcceptPrompts -or $WhatIfPreference -or (
        $PSBoundParameters.ContainsKey('Confirm') -and (-not $Confirm)
    )
    $ShouldProcessHandlesConsent = ($PSBoundParameters.ContainsKey('Confirm') -and $Confirm) -or (
        ($ConfirmPreference -ne [System.Management.Automation.ConfirmImpact]::None) -and
        (([System.Management.Automation.ConfirmImpact]$ConfirmPreference) -le [System.Management.Automation.ConfirmImpact]::Medium)
    )
    $NeedServerPrompt = (-not $SkipServerPrompt) -and (-not $ShouldProcessHandlesConsent)

    if ($NeedServerPrompt) {
        $WindowsOsCaption = Get-WindowsOperatingSystemCaption
        if ([string]::IsNullOrWhiteSpace($WindowsOsCaption)) {
            Write-Warning -Message 'Unable to determine the Windows operating system caption. Skipping WinGet updates as a safety precaution.'
            return
        }

        if ($ShouldUpdate -and ($WindowsOsCaption -match 'Server')) {
            Write-Warning -Message 'This is a server and updates could affect production systems. Do you want to continue with updating packages?'
            if ((Read-WinGetServerChoice) -ne 0) {
                return
            }
            Write-Verbose 'Continuing with WinGet package updates.'
        }
    }

    if ($ShouldUpdate -or $WhatIfPreference) {
        Write-Information '[4] Updating WinGet Packages' -InformationAction Continue
        Write-UpdateAllTheThingsProgress -CurrentOperation 'Updating WinGet Packages' -PercentComplete 80
    }

    if ($ShouldUpdate) {
        Invoke-WinGetUpgrade
    }
}
