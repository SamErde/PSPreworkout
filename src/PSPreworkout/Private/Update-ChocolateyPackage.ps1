function Update-ChocolateyPackage {
    <#
    .SYNOPSIS
    Updates Chocolatey and installed Chocolatey packages.

    .DESCRIPTION
    Optionally configures Chocolatey features when elevated, then updates
    Chocolatey and all installed packages.

    .PARAMETER Include
    Enables Chocolatey package updates.

    .OUTPUTS
    None
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter()]
        [switch]$Include
    )

    if ((-not $Include) -or (-not (Test-PSPreworkoutCommand -Name 'choco'))) {
        Write-Information '[9] Skipping Chocolatey' -InformationAction Continue
        return
    }

    Write-UpdateAllTheThingsProgress -CurrentOperation 'Updating Chocolatey Packages' -PercentComplete 98
    Write-Information '[9] Updating Chocolatey Packages' -InformationAction Continue

    if (Test-IsElevated) {
        if ($PSCmdlet.ShouldProcess('Chocolatey features', 'Enable global confirmation and disable non-elevated warnings')) {
            Invoke-UpdateNativeCommand -Name 'choco' -ArgumentList @(
                'feature', 'enable', '-n=allowGlobalConfirmation'
            ) -FailureMessage 'Chocolatey global confirmation configuration'
            Invoke-UpdateNativeCommand -Name 'choco' -ArgumentList @(
                'feature', 'disable', '--name=showNonElevatedWarnings'
            ) -FailureMessage 'Chocolatey non-elevated warning configuration'
        }
    } else {
        Write-Verbose "Run once as an administrator to disable Chocolatey's showNonElevatedWarnings." -Verbose
    }

    if ($PSCmdlet.ShouldProcess('Chocolatey packages', 'Upgrade Chocolatey and all packages')) {
        $UpgradeArguments = @('-y', '--limit-output', '--accept-license', '--no-color')
        $SelfUpdateArguments = @('upgrade', 'chocolatey') + $UpgradeArguments
        $PackageUpdateArguments = @('upgrade', 'all') + $UpgradeArguments
        Invoke-UpdateNativeCommand -Name 'choco' -ArgumentList $SelfUpdateArguments -FailureMessage 'Chocolatey self-update'
        Invoke-UpdateNativeCommand -Name 'choco' -ArgumentList $PackageUpdateArguments -FailureMessage 'Chocolatey package update'
    }

    Write-Information ' ' -InformationAction Continue
}
