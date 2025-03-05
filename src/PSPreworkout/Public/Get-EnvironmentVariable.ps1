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
    Version: 0.2.0
    Modified: 2025/03/05

    To Do: Return environment variables if -Target is used without either -Name or -Pattern.
    To Do: Do not allow name and pattern parameters to be used together.

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
    [OutputType('System.Object[]')]
    param (
        # The name of the environment variable to retrieve. If not specified, all environment variables are returned.
        [Parameter(Position = 0)]
        #[Parameter(Position = 0, ParameterSetName = 'LookupByName')]
        [string]$Name,

        # A regex pattern to search variable names by
        [Parameter()]
        #[Parameter(Position = 0, ParameterSetName = 'LookupByRegexPattern')]
        [string]
        $Pattern,

        # The target of the environment variable to retrieve: Process, User, or Machine. Default is all.
        [Parameter()]
        [System.EnvironmentVariableTarget[]]
        $Target = [System.EnvironmentVariableTarget].GetEnumValues(),

        # Switch to show environment variables in all target scopes.
        [Parameter()]
        [switch]
        $All
    )

    begin {
        # Initialize the collection of environment variables that will be returned to the pipeline at the end.
        [System.Collections.Generic.List[PSObject]]$EnvironmentVariables = @()

        # Get all environment variables from all targets if no parameters are specified
        if (
            $PSBoundParameters.ContainsKey('Name') -eq $false -and
            $PSBoundParameters.ContainsKey('Pattern') -eq $false -and
            $PSBoundParameters.ContainsKey('Target') -eq $false
        ) {
            $All = $true
            $Target = [System.EnvironmentVariableTarget].GetEnumValues()
        }

        Write-Debug -Message "Parameters: $($PSBoundParameters.GetEnumerator())`n`n`t   Name: $Name`n`tPattern: $Pattern`n`t Target: $Target`n`t    All: $All" -ErrorAction SilentlyContinue
    } # end begin block

    process {
        foreach ($thisTarget in $Target) {

            if ( $PSBoundParameters.ContainsKey('Name') -and -not $PSBoundParameters.ContainsKey('Pattern') ) {
                # If a variable name was specified, get that environment variable.
                # Temporarily using this -and -not condition because I couldn't get exclusive Name/Pattern parameter sets to work.
                $ThisEnvironmentVariable = [ordered]@{
                    Name        = $Name
                    Value       = [Environment]::GetEnvironmentVariable($Name, $thisTarget)
                    Target      = $thisTarget
                    PID         = if ($thisTarget -eq 'Process') { $PID } else { $null }
                    ProcessName = if ($thisTarget -eq 'Process') { (Get-Process -Id $PID).Name } else { $null }
                }
                $item = New-Object -TypeName PSObject -Property $ThisEnvironmentVariable
                $EnvironmentVariables.Add($item)

            } elseif ( $PSBoundParameters.ContainsKey('Pattern') ) {
                if ($Name) {
                    Write-Verbose -Message 'A value for the Name parameter was specified, but it is being ignored because a Pattern was also provided.'
                }
                # If a pattern is specified, get environment variables with names that match the pattern.
                $Result = [Environment]::GetEnvironmentVariables($thisTarget).GetEnumerator() | Where-Object { $_.Key -match $pattern }
                foreach ($PatternResult in $Result) {
                    $ThisEnvironmentVariable = [ordered]@{
                        Name        = $PatternResult.Name
                        Value       = $PatternResult.Value
                        Target      = $thisTarget
                        PID         = if ($thisTarget -eq 'Process') { $PID } else { $null }
                        ProcessName = if ($thisTarget -eq 'Process') { (Get-Process -Id $PID).Name } else { $null }
                    }
                    $item = New-Object -TypeName PSObject -Property $ThisEnvironmentVariable
                    $EnvironmentVariables.Add($item)
                }

            } elseif ( $PSBoundParameters.ContainsKey('Target') -and
                -not ( $PSBoundParameters.ContainsKey('Name') -or $PSBoundParameters.ContainsKey('Pattern') )
            ) {
                foreach ( $ev in ([Environment]::GetEnvironmentVariables($thisTarget)).GetEnumerator() ) {
                    $ThisEnvironmentVariable = [ordered]@{
                        Name        = $ev.Name
                        Value       = $ev.Value
                        Target      = $thisTarget
                        PID         = if ($thisTarget -eq 'Process') { $PID } else { $null }
                        ProcessName = if ($thisTarget -eq 'Process') { (Get-Process -Id $PID).Name } else { $null }
                    }
                    $item = New-Object -TypeName PSObject -Property $ThisEnvironmentVariable
                    $EnvironmentVariables.Add($item)
                }

            } else {
                # Get all environment variables.
                foreach ( $ev in ([Environment]::GetEnvironmentVariables($thisTarget).GetEnumerator()) ) {
                    $ThisEnvironmentVariable = [ordered]@{
                        Name        = $ev.Name
                        Value       = $ev.Value
                        Target      = $thisTarget[0]
                        PID         = if ($thisTarget -eq 'Process') { $PID } else { $null }
                        ProcessName = if ($thisTarget -eq 'Process') { (Get-Process -Id $PID).Name } else { $null }
                    }
                    $item = New-Object -TypeName PSObject -Property $ThisEnvironmentVariable
                    $EnvironmentVariables.Add($item)
                }
            }
        } # end foreach target
    } # end process block

    end {
        # Insert a custom type name for the output objects so custom formatting can be applied.
        foreach ($item in $EnvironmentVariables) {
            $item.PSTypeNames.Insert(0, 'PSPreworkout.EnvironmentVariable')
        }
        $EnvironmentVariables
    } # end end block
} # end function
