function Update-LinuxPackage {
    <#
    .SYNOPSIS
    Updates packages with supported Linux package managers.

    .DESCRIPTION
    Updates apt and dnf packages, using sudo only when the current process is
    not elevated.

    .PARAMETER AcceptPrompts
    Passes the non-interactive acceptance argument to package managers.

    .OUTPUTS
    None
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter()]
        [switch]$AcceptPrompts
    )

    $AptAvailable = Test-PSPreworkoutCommand -Name 'apt'
    $DnfAvailable = Test-PSPreworkoutCommand -Name 'dnf'
    if ((-not $AptAvailable) -and (-not $DnfAvailable)) {
        return
    }

    $NeedsSudo = -not (Test-IsElevated)

    if ($AptAvailable) {
        Write-Information '[5] Updating apt packages.' -InformationAction Continue
        if ($PSCmdlet.ShouldProcess('apt packages', 'Update and upgrade packages')) {
            $CommandName = if ($NeedsSudo) { 'sudo' } else { 'apt' }
            $UpdateArguments = if ($NeedsSudo) { @('apt', 'update') } else { @('update') }
            [string[]]$UpgradeArguments = if ($NeedsSudo) { @('apt', 'upgrade') } else { @('upgrade') }
            if ($AcceptPrompts) {
                $UpgradeArguments += '-y'
            }

            Invoke-UpdateNativeCommand -Name $CommandName -ArgumentList $UpdateArguments -FailureMessage 'apt package index update'
            Invoke-UpdateNativeCommand -Name $CommandName -ArgumentList $UpgradeArguments -FailureMessage 'apt package upgrade'
        }
    }

    if ($DnfAvailable) {
        Write-Information '[5] Updating dnf packages.' -InformationAction Continue
        if ($PSCmdlet.ShouldProcess('dnf packages', 'Update packages')) {
            $CommandName = if ($NeedsSudo) { 'sudo' } else { 'dnf' }
            [string[]]$Arguments = if ($NeedsSudo) { @('dnf', 'update') } else { @('update') }
            if ($AcceptPrompts) {
                $Arguments += '-y'
            }

            Invoke-UpdateNativeCommand -Name $CommandName -ArgumentList $Arguments -FailureMessage 'dnf package update'
        }
    }
}
