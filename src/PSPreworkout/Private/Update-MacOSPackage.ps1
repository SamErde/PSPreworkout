function Update-MacOSPackage {
    <#
    .SYNOPSIS
    Updates supported macOS software.

    .DESCRIPTION
    Lists macOS software updates and updates Homebrew packages when Homebrew is
    installed.

    .OUTPUTS
    None
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param()

    if ($PSCmdlet.ShouldProcess('macOS software updates', 'List available updates')) {
        Invoke-UpdateNativeCommand -Name 'softwareupdate' -ArgumentList '-l' -FailureMessage 'macOS software update query'
    }

    if (Test-PSPreworkoutCommand -Name 'brew') {
        Write-Information '[6] Updating brew packages.' -InformationAction Continue
        if ($PSCmdlet.ShouldProcess('Homebrew packages', 'Update and upgrade packages')) {
            Invoke-UpdateNativeCommand -Name 'brew' -ArgumentList 'update' -FailureMessage 'Homebrew update'
            Invoke-UpdateNativeCommand -Name 'brew' -ArgumentList 'upgrade' -FailureMessage 'Homebrew upgrade'
        }
    }
}
