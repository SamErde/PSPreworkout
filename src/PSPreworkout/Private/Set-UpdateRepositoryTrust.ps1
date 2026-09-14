function Set-UpdateRepositoryTrust {
    <#
    .SYNOPSIS
    Trusts supported PowerShell Gallery repositories.

    .DESCRIPTION
    Configures PSGallery as trusted for the installed PowerShellGet and
    PSResourceGet clients.

    .OUTPUTS
    None
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param()

    Write-Verbose 'Set the PowerShell Gallery as a trusted installation source.'

    if (
        (Test-PSPreworkoutCommand -Name 'Set-PSRepository') -and
        $PSCmdlet.ShouldProcess('PSGallery', 'Set PowerShellGet repository as trusted')
    ) {
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    }

    if (
        (Test-PSPreworkoutCommand -Name 'Set-PSResourceRepository') -and
        $PSCmdlet.ShouldProcess('PSGallery', 'Set PSResourceGet repository as trusted')
    ) {
        Set-PSResourceRepository -Name 'PSGallery' -Trusted
    }
}
