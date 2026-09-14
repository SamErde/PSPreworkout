function Get-PSPreworkoutPlatform {
    <#
    .SYNOPSIS
    Gets the current operating-system platform.

    .DESCRIPTION
    Returns a stable platform name across Windows PowerShell 5.1 and PowerShell 7.

    .OUTPUTS
    System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param()

    if ($PSVersionTable.PSEdition -eq 'Desktop') {
        return 'Windows'
    }
    if (Get-Variable -Name IsWindows -ValueOnly -ErrorAction SilentlyContinue) {
        return 'Windows'
    }

    if (Get-Variable -Name IsLinux -ValueOnly -ErrorAction SilentlyContinue) {
        return 'Linux'
    }

    if (Get-Variable -Name IsMacOS -ValueOnly -ErrorAction SilentlyContinue) {
        return 'macOS'
    }

    return 'Unknown'
}
