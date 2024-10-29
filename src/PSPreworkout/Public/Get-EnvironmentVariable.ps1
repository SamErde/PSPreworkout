function Get-EnvironmentVariable {
    <#
    .SYNOPSIS
    Retrieves the value of an environment variable.

    .DESCRIPTION
    The Get-EnvironmentVariable function retrieves the value of the specified environment variable or displays all environment variables.

    .PARAMETER Name
    The name of the environment variable to retrieve.

    .PARAMETER Pattern
    A regex pattern to match environment variable names against.

    .PARAMETER Target
    The target (Process, Machine, User) to pull environment variables from. The default is process. Multiple targets may be specified.

    .PARAMETER All
    Optionally get all environment variables from all targets. Process ID and process name will be included for process environment variables.

    .EXAMPLE
    Get-EnvironmentVariable -Name 'UserName'
    Retrieves the value of the "UserName" environment variable from the process target.

    .EXAMPLE
    Get-EnvironmentVariable -Name 'Path' -Target 'Machine'
    Retrieves the value of the PATH environment variable from the machine target.

    .EXAMPLE
    Get-EnvironmentVariable -Pattern '^u'
    Get environment variables with names that begin with the letter "u" in any target.

    .EXAMPLE
    Get-EnvironmentVariable -Pattern 'git' | Format-Table Name,Target,PID,ProcessName,Value

    Get all process environment variables that match the pattern "git" and return the results as a table.

    .EXAMPLE
    Get-EnvironmentVariable -Pattern 'path' -Target Machine,Process,User | Format-Table Name,Target,PID,ProcessName,Value

    Return all environment variables that match the pattern "path" from all targets and format the results as a table.

    .NOTES
    Author: Sam Erde
    Version: 0.1.0
    Modified: 2024/10/8

    To Do: Return environment variables if -Target is used without either -Name or -Pattern.


    About Environment Variables:

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
        [Parameter(Position = 0, ParameterSetName = 'LookupByName')]
        [string]$Name,

        # A regex pattern to search variable names by
        [Parameter(Position = 0, ParameterSetName = 'LookupByRegexPattern')]
        [string]
        $Pattern,

        # The target of the environment variable to retrieve: Process (default), User, or Machine.
        [Parameter(Position = 1)]
        [System.EnvironmentVariableTarget[]]
        $Target = @([System.EnvironmentVariableTarget]::Process),

        # Switch to show environment variables in all target scopes.
        [Parameter(ParameterSetName = 'ListAll')]
        [switch]
        $All
    )

    begin {
        [System.Collections.Generic.List[PSObject]]$EnvironmentVariables = @()

        if ($All.IsPresent -or $PSBoundParameters.Count -eq 0) {
            $All = $true
        }

        if ($All) {
            $Target = @('Process', 'User', 'Machine')
        }
    } # end begin block

    process {
        foreach ($thisTarget in $Target) {

            if ( $PSBoundParameters.ContainsKey('Name') ) {
                # If a variable name was specified, get that environment variable.
                $ThisEnvironmentVariable = [ordered]@{
                    Name   = $Name
                    Value  = [Environment]::GetEnvironmentVariable($Name, $thisTarget)
                    Target = $thisTarget[0]
                }
                $item = New-Object -TypeName psobject -Property $ThisEnvironmentVariable
                $EnvironmentVariables.Add($item)
                Write-Debug "Name: $Name`nTarget: $Target`n`n$ThisEnvironmentVariable`n`n$item"

            } elseif ( $PSBoundParameters.ContainsKey('Pattern') ) {
                # If a pattern is specified, get environment variables with names that match the pattern.
                $Result = [Environment]::GetEnvironmentVariables($thisTarget).GetEnumerator() | Where-Object { $_.Key -match $pattern }
                foreach ($PatternResult in $Result) {
                    $ThisEnvironmentVariable = [ordered]@{
                        Name        = $PatternResult.Name
                        Value       = $PatternResult.Value
                        Target      = $thisTarget[0]
                        PID         = if ($thisTarget -eq 'Process') { $PID } else { $null }
                        ProcessName = if ($thisTarget -eq 'Process') { (Get-Process -Id $PID).Name } else { $null }
                    }
                    $item = New-Object -TypeName psobject -Property $ThisEnvironmentVariable
                    $EnvironmentVariables.Add($item)
                    Write-Debug "Name: $Name`nTarget: $Target`n`n$ThisEnvironmentVariable`n`n$item"
                }

            } else {
                # If only the target is specified, get all environment variables from that target (or targets);
                # if All, get all environment variables in all targets.
                foreach ( $ev in ([Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::$thisTarget).GetEnumerator()) ) {
                    $ThisEnvironmentVariable = [ordered]@{
                        Name        = $ev.Name
                        Value       = $ev.Value
                        Target      = $thisTarget[0]
                        PID         = if ($thisTarget -eq 'Process') { $PID } else { $null }
                        ProcessName = if ($thisTarget -eq 'Process') { (Get-Process -Id $PID).Name } else { $null }
                    }
                    $item = New-Object -TypeName psobject -Property $ThisEnvironmentVariable
                    $EnvironmentVariables.Add($item)
                }
            }
        } # end foreach target
    } # end process block

    end {
        $EnvironmentVariables
    } # end end block
} # end function
