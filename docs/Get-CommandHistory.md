---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Get-CommandHistory

## SYNOPSIS

Get a filtered list of commands from your history.

## SYNTAX

### BasicFilter (Default)

```
Get-CommandHistory [-FilterWords <String[]>] [<CommonParameters>]
```

### All

```
Get-CommandHistory [-All] [<CommonParameters>]
```

### PatternSearch

```
Get-CommandHistory [-Pattern] <String> [<CommonParameters>]
```

## DESCRIPTION

This function filters the output of Get-History to exclude a list of ignored commands and any commands that are
less than 4 characters long.
It can also be used to find all commands that match a given pattern.
It is useful
for quickly finding commands from your history that you want to document or re-invoke.

## EXAMPLES

### EXAMPLE 1

```
Get-CommandHistory -Pattern 'Disk'
```

This will return all commands from your history that contain the word 'Disk'.

### EXAMPLE 2

```
Get-CommandHistory -FilterWords 'Get-Service', 'Get-Process'
```

This will return all commands from your history that do not contain the words 'Get-Service' or 'Get-Process'
(while also still filtering out the default ignore list).

### EXAMPLE 3

```
Get-CommandHistory -All
```

This will return all commands from your history without any filtering.

## PARAMETERS

### -All

Show all command history without filtering anything out.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterWords

A string or array of strings to filter out (ignore) in the command history list.
The default ignored commands
are: Get-History|Invoke-CommandHistory|Get-CommandHistory|clear

```yaml
Type: String[]
Parameter Sets: BasicFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Pattern

A string or regex pattern to match against the command history.
This is useful for finding specific commands
that you have run in the past.
The pattern is passed to the -match operator, so it can be a simple string or a
more complex regex pattern.
If this parameter is used, the FilterWords parameter is ignored.

```yaml
Type: String
Parameter Sets: PatternSearch
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Microsoft.PowerShell.Commands.HistoryInfo[]

## NOTES

Author: Sam Erde
Version: 1.0.0
Modified: 2025-03-25

## RELATED LINKS
