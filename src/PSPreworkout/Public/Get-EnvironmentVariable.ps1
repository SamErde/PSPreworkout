function Get-EnvironmentVariable {
    <#
    .SYNOPSIS
    Retrieves the value of an environment variable.

    .DESCRIPTION
    The Get-EnvironmentVariable function retrieves the value of the specified environment variable
    or displays all environment variables.

    .PARAMETER Name
    The name of the environment variable to retrieve.

    .EXAMPLE
    Get-EnvironmentVariable -Name "PATH"
    Retrieves the value of the "PATH" environment variable.

    .NOTES
    Author: Sam Erde
    Version: 0.0.2
    Modified: 2024/10/12

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
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
    [OutputType('System.String')]
    param (
        # The name of the environment variable to retrieve. If not specified, all environment variables are returned.
        [Parameter(Position = 0)]
        [string]$Name,

        # The target of the environment variable to retrieve. Defaults to User. (Process, User, or Machine)
        [Parameter(Position = 1)]
        [System.EnvironmentVariableTarget]
        $Target = [System.EnvironmentVariableTarget]::User,

        # Switch to show environment variables in all target scopes.
        [Parameter()]
        [switch]
        $All
    )

    # If a variable name was specified, get that environment variable from the default target or specified target.
    if ( $PSBoundParameters.Keys.Contains('Name') ) {
        [Environment]::GetEnvironmentVariable($Name, $Target)
    } elseif (-not $PSBoundParameters.Keys.Contains('All') ) {
        [Environment]::GetEnvironmentVariables()
    }

    # If only the target is specified, get all environment variables from that target.
    if ( $PSBoundParameters.Keys.Contains('Target') -and -not $PSBoundParameters.ContainsKey('Name') ) {
        [System.Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::$Target)
    }

    # Get all environment variables from all targets.
    # To Do: Get the specified variable name from all targets if a name and -All are specified.
    if ($All) {
        Write-Output 'Process Environment Variables:'
        [Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::Process)
        Write-Output 'User Environment Variables:'
        [Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::User)
        Write-Output 'Machine Environment Variables:'
        [Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::Machine)
    }
}
