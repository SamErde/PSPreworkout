function Test-IsElevated {
    <#
    .SYNOPSIS
    Check if you are running an elevated shell with administrator or root privileges.

    .DESCRIPTION
    Check if you are running an elevated shell with administrator or root privileges.

    .EXAMPLE
    Test-IsElevated

    .OUTPUTS
    Boolean
    #>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
    [Alias('isadmin', 'isroot')]
    param ()

    if (($PSVersionTable.PSVersion.Major -le 5) -or $IsWindows) {
        $CurrentUser = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
        return $CurrentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } else {
        # Must be Linux or OSX, so use the id util. Root has userid of 0.
        return 0 -eq (id -u)
    }
}
