function Install-PowerShellISE {
    <#
    .SYNOPSIS
        Install the Windows PowerShell ISE

    .DESCRIPTION
        This script installs Windows PowerShell ISE if it was previously removed. It includes a step that temporarily
        resets the Windows Automatic Update server source in the registry, which may resolve errors that some people
        experience while trying to add Windows Capabilities.

    .EXAMPLE
        Install-PowerShellISE

    .NOTES
        Author: Sam Erde
        Version: 0.1.0
        Modified: 2025-01-07

        To Do:
            - Add support for Windows Server OS features
            - Add parameter to make the Windows Update registry change optional

        Requires running as admin but adding the `requires` tag forces the entire build to validate admin rights.
    #>

    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Install-PowerShellISE')]
    param ()

    # Check if running a Windows client or Windows Server OS
    if ((Get-CimInstance -ClassName Win32_OperatingSystem).Caption -match 'Windows Server') {

        # Windows Server OS
        Write-Information 'Support for [re-]installing the Windows PowerShell ISE on Windows Server is not yet fully implemented.' -InformationAction Continue
        if ((Get-WindowsFeature -Name PowerShell-ISE -ErrorAction SilentlyContinue).Installed) {
            Write-Output 'The Windows PowerShell ISE is already installed on this Windows Server.'
        } else {
            Write-Output 'The Windows PowerShell ISE is not installed on this Windows Server.'
        }

    } else {

        # Windows client OS
        if ((Get-WindowsCapability -Name 'Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0' -Online).State -eq 'Installed') {
            Write-Output 'The Windows PowerShell ISE is already installed.'
        } else {
            # Resetting the Windows Update source sometimes resolves errors when trying to add Windows capabilities
            $CurrentWUServer = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'UseWUServer' | Select-Object -ExpandProperty UseWUServer
            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'UseWUServer' -Value 0
            Restart-Service wuauserv

            try {
                Get-WindowsCapability -Name Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0 -Online | Add-WindowsCapability -Online -Verbose
            } catch {
                Write-Error "There was a problem adding the Windows PowerShell ISE: $error"
            }

            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'UseWUServer' -Value $CurrentWUServer
            Restart-Service wuauserv
        }
    } # end OS type check

} # end function Install-PowerShellISE
