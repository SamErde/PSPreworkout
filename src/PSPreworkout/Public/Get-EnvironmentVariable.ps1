function Get-EnvironmentVariable {
    <#
    .SYNOPSIS
    Retrieves the value of an environment variable.

    .DESCRIPTION
    The Get-EnvironmentVariable function retrieves the value of the specified environment variable or displays all
    environment variables. It is capable of finding variables by an exact name match or by using a regex pattern match.
    It can retrieve environment variables from the process, machine, and user targets. If no parameters are specified,
    all environment variables are returned from all targets.

    .PARAMETER Name
    The name of the environment variable to retrieve.

    .PARAMETER Pattern
    A regex pattern to find matching environment variable names.

    .PARAMETER Target
    The target (Process, Machine, User) to pull environment variables from. Multiple targets may be specified.

    .PARAMETER All
    Optionally get all environment variables from all targets or all environment variables from one specified target.
    Process ID and process name will be included for process environment variables.

    .EXAMPLE
    Get-EnvironmentVariable -Name 'UserName' -Target 'User'

    Retrieves the value of the "UserName" environment variable from the process target.

    .EXAMPLE
    Get-EnvironmentVariable -Name 'Path' -Target 'Machine'

    Retrieves the value of the PATH environment variable from the machine target.

    .EXAMPLE
    Get-EnvironmentVariable -Pattern '^u'

    Get environment variables with names that begin with the letter "u" in any target.

    .NOTES
    Author: Sam Erde
    Version: 1.0.0
    Modified: 2025/03/05

    About Environment Variables:

    Variable names are case-sensitive on Linux and macOS, but not on Windows. PowerShell is case-insensitive by default
    and compensates for case-sensitivity on Linux and macOS. To make PowerShell case-sensitive, use the -CaseSensitive
    parameter when starting PowerShell.

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
    [CmdletBinding(DefaultParameterSetName = 'LookupByName', HelpUri = 'https://day3bits.com/PSPreworkout/Get-EnvironmentVariable')]
    [OutputType('System.Object[]')]
    param (
        # The name of the environment variable to retrieve. If no name or pattern is specified, all environment variables are returned.
        [Parameter(Position = 0, ParameterSetName = 'LookupByName')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # A regex pattern to match environment variable names against. If no name or pattern is specified, all environment variables are returned.
        [Parameter(Position = 0, ParameterSetName = 'LookupByRegexPattern')]
        [ValidateNotNullOrEmpty()]
        [string]$Pattern,

        # The target of the environment variable to retrieve: Process, User, or Machine. Default is all.
        [Parameter(ParameterSetName = 'LookupByName')]
        [Parameter(ParameterSetName = 'LookupByRegexPattern')]
        [System.EnvironmentVariableTarget[]]
        $Target = [System.EnvironmentVariableTarget].GetEnumValues(),

        # Switch to show environment variables in all target scopes.
        [Parameter(ParameterSetName = 'LookupByName')]
        [Parameter(ParameterSetName = 'LookupByRegexPattern')]
        [switch]
        $All
    )

    begin {
        # Initialize the collection of environment variables that will be returned to the pipeline at the end.
        [System.Collections.Generic.List[PSObject]]$EnvironmentVariables = @()

        # Convert the name to an escaped regex pattern if the name parameter is specified.
        if ($PSBoundParameters.ContainsKey('Name')) {
            $Pattern = "^$([regex]::Escape($Name))$"
        }

        # If no name or pattern is specified, get all environment variables.
        if ( !($Pattern) -or ($Pattern.Length -eq 0) ) {
            $Pattern = '.*'
        }

        Write-Verbose -Message "Parameters: $($PSBoundParameters.GetEnumerator())`n`n`t   Name: $Name`n`tPattern: $Pattern`n`t Target: $Target`n`t    All: $All" -ErrorAction SilentlyContinue
    } # end begin block

    process {

        # Get the environment variables from the specified target(s).
        foreach ($thisTarget in $Target) {

            $Result = [Environment]::GetEnvironmentVariables($thisTarget).GetEnumerator() | Where-Object { $_.Key -match $pattern }
            foreach ($PatternResult in $Result) {
                $ThisEnvironmentVariable = [ordered]@{
                    PSTypeName  = 'PSPreworkout.EnvironmentVariable'
                    Name        = $PatternResult.Name
                    Value       = $PatternResult.Value
                    Target      = $thisTarget
                    PID         = if ($thisTarget -eq 'Process') { $PID } else { $null }
                    ProcessName = if ($thisTarget -eq 'Process') { (Get-Process -Id $PID).Name } else { $null }
                }
                $item = New-Object -TypeName PSObject -Property $ThisEnvironmentVariable
                $EnvironmentVariables.Add($item)
            } # end foreach PatternResult

        } # end foreach target

    } # end process block

    end {
        $EnvironmentVariables
    } # end end block

} # end function
