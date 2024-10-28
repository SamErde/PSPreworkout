function Get-EnvironmentVariable {
    <#
    .SYNOPSIS
    Retrieves the value of an environment variable.

    .DESCRIPTION
    The Get-EnvironmentVariable function retrieves the value of the specified environment variable
    or displays all environment variables.

    .PARAMETER Name
    The name of the environment variable to retrieve.

    .PARAMETER Target
    The target (Process, Machine, User) to pull environment variables from. The default is process.

    .PARAMETER All
    Optionally get all environment variables from all targets. Process ID and process name will be included for process environment variables.

    .EXAMPLE
    Get-EnvironmentVariable -Name 'UserName'
    Retrieves the value of the "UserName" environment variable from the process target.

    .EXAMPLE
    Get-EnvironmentVariable -Name 'Path' -Target 'Machine'
    Retrieves the value of the PATH environment variable from the machine target.

    .NOTES
    Author: Sam Erde
    Version: 0.1.0
    Modified: 2024/10/26

    To Do: Get the specified variable name from all targets if a name and -All are specified.

    ---

    Variable names are case-sensitive on Linux and macOS, but not on Windows.

    Why is 'Target' used by .NET instead of the familiar 'Scope' parameter name? @IISResetMe (Mathias R. Jessen) explains:
    "Scope" would imply some sort of integrated hierarchy of env variables - that's not really the case.
    Target=Process translates to kernel32!GetEnvironmentVariable (which then in turn reads the PEB from
    the calling process), whereas Target={User,Machine} causes a registry lookup against environment
    data in either HKCU or HKLM.

    The relevant sources for the User and Machine targets are in the registry at:
    - HKEY_CURRENT_USER\Environment
    - HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment

    See more at <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables>.

    #>
    [Alias('gev')]
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Get-EnvironmentVariable')]
    [OutputType('PSObject')]
    param (
        # The name of the environment variable to retrieve. If not specified, all environment variables are returned.
        [Parameter(Position = 0, ParameterSetName = 'Named')]
        [string]$Name,

        # The target of the environment variable to retrieve. Defaults to Process. (Process, User, or Machine)
        [Parameter(Position = 1, ParameterSetName = 'Named', 'Targeted')]
        [System.EnvironmentVariableTarget[]]
        $Target = [System.EnvironmentVariableTarget]::Process,

        # Switch to show environment variables in all target scopes.
        [Parameter(ParameterSetName = 'All')]
        [switch]
        $All
    )

    # If a variable name was specified, get that environment variable from the default target or specified target.
    if ( $PSBoundParameters.ContainsKey('Name') ) {
        [Environment]::GetEnvironmentVariable($Name, $Target)
    } else {
        # If only the target is specified, get all environment variables from that target (or targets).
        [System.Collections.Generic.List[PSObject]]$AllEnvironmentVariables = @()

        foreach ($target in @('Process', 'User', 'Machine')) {
            foreach ($ev in ([Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::$target)).GetEnumerator()) {
                $EnvironmentVariable = [ordered]@{
                    Name        = $ev.Name
                    Value       = $ev.Value
                    Target      = $target
                    PID         = if ($target -eq 'Process') { $PID } else { $null }
                    ProcessName = if ($target -eq 'Process') { (Get-Process -Id $PID).Name } else { $null }
                }
                $item = New-Object -TypeName psobject -Property $EnvironmentVariable
                $AllEnvironmentVariables.Add($item)
            }
        }
    }
    $AllEnvironmentVariables
}
