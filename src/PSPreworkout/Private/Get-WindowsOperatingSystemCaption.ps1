function Get-WindowsOperatingSystemCaption {
    <#
    .SYNOPSIS
    Gets the Windows operating-system caption.

    .DESCRIPTION
    Uses CIM when available and falls back to WMI for Windows PowerShell 5.1
    environments where the CimCmdlets module is unavailable.

    .OUTPUTS
    System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param()

    if (Test-PSPreworkoutCommand -Name 'Get-CimInstance') {
        try {
            return Get-CimOperatingSystemCaption
        } catch {
            Write-Verbose 'Get-CimInstance failed while checking the Windows operating system caption.'
        }
    }

    if (Test-PSPreworkoutCommand -Name 'Get-WmiObject') {
        try {
            return Get-WmiOperatingSystemCaption
        } catch {
            Write-Verbose 'Get-WmiObject failed while checking the Windows operating system caption.'
        }
    }
}
