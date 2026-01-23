---
document type: cmdlet
external help file: PSPreworkout-Help.xml
HelpUri: https://day3bits.com/PSPreworkout/Set-ConsoleFont
Locale: en-US
Module Name: PSPreworkout
ms.date: 01/23/2026
PlatyPS schema version: 2024-05-01
title: Set-ConsoleFont
---

# Set-ConsoleFont

## SYNOPSIS

Set the font for your consoles in Windows.

## SYNTAX

### __AllParameterSets

```
Set-ConsoleFont [-Font] <string> [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Set-ConsoleFont allows you to set the font for all of your registered Windows consoles (Windows PowerShell,
Windows Terminal, PowerShell, or Command Prompt).
It provides tab-autocomplete for the font parameter, listing
all of the Nerd Fonts and monospace fonts installed in Windows.

## EXAMPLES

### EXAMPLE 1

Set-ConsoleFont -Font 'FiraCode Nerd Font'

## PARAMETERS

### -Font

The name of the font to set for your consoles in Windows.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}

