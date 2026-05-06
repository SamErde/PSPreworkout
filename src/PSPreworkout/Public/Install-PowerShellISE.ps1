function Install-PowerShellISE {
    <#
    .SYNOPSIS
    Install the Windows PowerShell ISE

    .DESCRIPTION
    This script installs Windows PowerShell ISE if it was not installed or previously removed. It includes a step that
    temporarily resets the Windows Automatic Update server source in the registry, which may resolve errors that some
    systems experience while trying to add Windows Capabilities.

    .EXAMPLE
    Install-PowerShellISE
    #>

    [CmdletBinding(SupportsShouldProcess, HelpUri = 'https://day3bits.com/PSPreworkout/Install-PowerShellISE')]
    param ()

    # Send non-identifying usage statistics to PostHog.
    Write-PSPreworkoutTelemetry -EventName $MyInvocation.MyCommand.Name -ParameterNamesOnly $MyInvocation.BoundParameters.Keys

    if ($IsLinux -or $IsMacOS) {
        throw 'Install-PowerShellISE is only supported on Windows.'
    }

    # Check if running as admin
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        Write-Error 'This script must be run as an administrator.'
        return
    }

    $OSCaption = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption

    # Quick check to see if running on Windows.
    if (-not $OSCaption -match 'Windows') {
        Write-Error 'This script is only for Windows OS.'
        return
    }

    # Check if running a Windows client or Windows Server OS
    if ($OSCaption -match 'Windows Server') {

        # Windows Server OS
        if ((Get-WindowsFeature -Name PowerShell-ISE -ErrorAction SilentlyContinue).Installed) {
            Write-Output 'The Windows PowerShell ISE is already installed on this Windows Server.'
        } else {
            if ($PSCmdlet.ShouldProcess('Windows Server', 'Install PowerShell ISE Windows feature')) {
                Import-Module ServerManager
                Add-WindowsFeature PowerShell-ISE
            }
        }

    } else {

        # Windows client OS
        if ((Get-WindowsCapability -Name 'Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0' -Online).State -eq 'Installed') {
            Write-Output 'The Windows PowerShell ISE is already installed.'
        } else {
            # Resetting the Windows Update source sometimes resolves errors when trying to add Windows capabilities
            $RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
            $CurrentWUServer = Get-ItemProperty -Path $RegistryPath -Name 'UseWUServer' | Select-Object -ExpandProperty UseWUServer

            try {
                if ($PSCmdlet.ShouldProcess($RegistryPath, 'Temporarily use Windows Update as capability source')) {
                    Set-ItemProperty -Path $RegistryPath -Name 'UseWUServer' -Value 0
                    Restart-Service wuauserv
                }

                if ($PSCmdlet.ShouldProcess('Windows client', 'Install PowerShell ISE Windows capability')) {
                    Get-WindowsCapability -Name Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0 -Online | Add-WindowsCapability -Online -Verbose
                }
            } catch {
                Write-Error "There was a problem adding the Windows PowerShell ISE: $error"
            } finally {
                if ($null -ne $CurrentWUServer -and $PSCmdlet.ShouldProcess($RegistryPath, 'Restore Windows Update server source')) {
                    Set-ItemProperty -Path $RegistryPath -Name 'UseWUServer' -Value $CurrentWUServer
                    Restart-Service wuauserv
                }
            }
        }
    } # end OS type check

} # end function Install-PowerShellISE
