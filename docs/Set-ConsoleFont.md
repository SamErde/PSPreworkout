---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Set-ConsoleFont

## SYNOPSIS
Set the font for your consoles.

## SYNTAX

```
Set-ConsoleFont [-Font] <String> [<CommonParameters>]
```

## DESCRIPTION
Set-ConsoleFont allows you to set the font for all of your registered consoles (PowerShell, Windows PowerShell,
Windows Terminal, or Command Prompt).
It provides tab-autocomplete for the font parameter, listing all of the Nerd
Fonts and monospace fonts installed on your system.

## EXAMPLES

### EXAMPLE 1
```
Set-ConsoleFont -Font 'FiraCode Nerd Font'
```

## PARAMETERS

### -Font
The name of the font to set for your consoles.

```yaml
Type: String
Parameter Sets: (All)
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

## NOTES

## RELATED LINKS
