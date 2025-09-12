function Get-CommandHistory {
    <#
        .SYNOPSIS
        Get a filtered and de-duplicated list of commands from your history.

        .DESCRIPTION
        This function filters the output of Get-History to exclude a list of ignored commands and any commands that are
        less than 4 characters long. It can also be used to find all commands that match a given pattern. It is useful
        for quickly finding things from your history that you want to document or re-invoke.

        .PARAMETER All
        Show all command history without filtering anything out.

        .PARAMETER Exclude
        A string or array of strings to exclude. Commands that have these words in them will be excluded from the
        history output. The default ignored commands are: Get-History, Invoke-CommandHistory, Get-CommandHistory, clear.

        .PARAMETER Filter
        A string or regex pattern to find in the command history. Commands that contain this pattern will be returned.

        The Filter is passed to the -match operator, so it can be a simple string or a more complex regex pattern.

        .EXAMPLE
        Get-CommandHistory -Filter 'Disk'

        This will return all commands from your history that contain the word 'Disk'.

        .EXAMPLE
        Get-CommandHistory -Exclude 'Get-Service', 'Get-Process'

        This will return all commands from your history that do not contain the words 'Get-Service' or 'Get-Process'
        (while also still filtering out the default ignore list).

        .EXAMPLE
        Get-CommandHistory -All

        This will return all commands from your history without any filtering.

        .NOTES
        Author: Sam Erde
        Version: 2.0.0
        Modified: 2025-09-08
    #>

    [CmdletBinding(DefaultParameterSetName = 'BasicFilter')]
    [Alias('gch')]
    [OutputType([Microsoft.PowerShell.Commands.HistoryInfo[]])]
    param (
        # Show all command history without filtering anything out.
        [Parameter(ParameterSetName = 'NoFilter')]
        [switch] $All,

        # A string or array of strings to exclude from the command history list.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]] $Exclude,

        # A string or regex Filter to search for matches in the command history.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]] $Filter
    )

    begin {
        # Initialize variables.
        [string[]]$IgnoreCommands = @()
        [string]$CommandFilter = $null

        if (-not $All.IsPresent) {
            # Set the default list of commands to ignore as a regex pattern of strings.
            [string]$DefaultIgnoreCommands = 'Get-History|Invoke-CommandHistory|Get-CommandHistory|clear'

            # Add the default ignore commands to the list of ignored commands as long as the All switch is not present.
            $IgnoreCommands = $DefaultIgnoreCommands.Clone()

            # Filter words to exclude.
            if ($Exclude.Length -gt 0) {
                $IgnoreCommands = "$DefaultIgnoreCommands|$($Exclude -join '|')"
                [scriptblock]$CommandExclude = { -and $_.CommandLine -notmatch $IgnoreCommands }
            }

            # Filter words to include.
            if ($Filter -and $Filter.Length -gt 0) {
                # Additional check to ensure we have non-empty filter strings.
                [string[]]$NonEmptyFilters = $Filter | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
                if ($NonEmptyFilters.Length -gt 0) {
                    # Create the regex string pattern and add it to the CommandFilter.
                    [string]$MatchFilter = ($NonEmptyFilters -join '|').Trim()
                    [scriptblock]$CommandFilter = { -and $_.CommandLine -match $MatchFilter }
                }
            }

            # Combine the include and exclude filters.
            [scriptblock]$DefaultFilter = { $_.ExecutionStatus -eq 'Completed' }
            $WhereFilter = [scriptblock]::Create("$DefaultFilter $CommandFilter $CommandExclude")
        } else {
            # If the All switch is present, do not filter anything out.
            [scriptblock]$WhereFilter = { $true }
        }
    }

    process {
        Get-History | Where-Object { $WhereFilter } |
            Sort-Object -Property CommandLine -Unique | Sort-Object -Property Id
    }

} # end function Get-CommandHistory
