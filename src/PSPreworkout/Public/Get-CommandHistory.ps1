function Get-CommandHistory {
    <#
        .SYNOPSIS
        Get a filtered list of commands from your history.

        .DESCRIPTION
        This function filters the output of Get-History to exclude a list of ignored commands and any commands that are
        less than 4 characters long. It can also be used to find all commands that match a given pattern. It is useful
        for quickly finding commands from your history that you want to document or re-invoke.

        .PARAMETER All
        Show all command history without filtering anything out.

        .PARAMETER FilterWords
        A string or array of strings to filter out (ignore) in the command history list. The default ignored commands
        are: Get-History|Invoke-CommandHistory|Get-CommandHistory|clear

        .PARAMETER Pattern
        A string or regex pattern to match against the command history. This is useful for finding specific commands
        that you have run in the past. The pattern is passed to the -match operator, so it can be a simple string or a
        more complex regex pattern. If this parameter is used, the FilterWords parameter is ignored.

        .EXAMPLE
        Get-CommandHistory -Pattern 'Disk'

        This will return all commands from your history that contain the word 'Disk'.

        .EXAMPLE
        Get-CommandHistory -FilterWords 'Get-Service', 'Get-Process'

        This will return all commands from your history that do not contain the words 'Get-Service' or 'Get-Process'
        (while also still filtering out the default ignore list).

        .EXAMPLE
        Get-CommandHistory -All

        This will return all commands from your history without any filtering.

        .NOTES
        Author: Sam Erde
        Version: 1.0.0
        Modified: 2025-03-25
    #>

    [CmdletBinding(DefaultParameterSetName = 'BasicFilter')]
    [Alias('gch')]
    [OutputType([Microsoft.PowerShell.Commands.HistoryInfo[]])]
    param (
        # Show all command history without filtering anything out.
        [Parameter(ParameterSetName = 'All')]
        [switch] $All,

        # A string or array of strings to filter out (ignore) in the command history list.
        [Parameter(ParameterSetName = 'BasicFilter')]
        [ValidateNotNullOrWhiteSpace()]
        [string[]] $FilterWords,

        # A string or regex pattern to search for matches in the command history.
        [Parameter(ParameterSetName = 'PatternSearch', Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Pattern
    )

    process {
        Get-History | Where-Object {
            $_.ExecutionStatus -eq 'Completed' -and ($_.CommandLine.Length -gt 3) -and $CommandFilter.Invoke()
        }
    }

    begin {
        # Set the filter to ignore a default list of command unless (-All is present).
        [string]$DefaultIgnoreCommands = 'Get-History|Invoke-CommandHistory|Get-CommandHistory|clear'

        # Add optional filter words to exclude per the FilterWords parameter.
        if ($FilterWords) {
            $FilterWords = '|' + $($FilterWords -join '|')
            [string]$IgnoreCommands = $DefaultIgnoreCommands + "$FilterWords"
        }

        # Create the filter. If the Pattern parameter is used, override the filter to match the pattern.
        if ($Pattern) {
            [string]$Pattern = ($Pattern -join '|').Trim()
            [scriptblock]$CommandFilter = { $_.CommandLine -match $Pattern }

        } elseif ($All) {
            [scriptblock]$CommandFilter = { $true }

        } else {
            [scriptblock]$CommandFilter = { $_.CommandLine -notmatch $IgnoreCommands }
        }
    }

    end {
        Remove-Variable DefaultIgnoreCommands, FilterWords, IgnoreCommands, CommandFilter -ErrorAction SilentlyContinue
    }
} # end function Get-CommandHistory
