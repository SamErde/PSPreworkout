---
document type: cmdlet
external help file: PSPreworkout-Help.xml
HelpUri: https://day3bits.com/PSPreworkout/Install-OhMyPosh
Locale: en-US
Module Name: PSPreworkout
ms.date: 01/23/2026
PlatyPS schema version: 2024-05-01
title: Install-OhMyPosh
---

# Install-OhMyPosh

## SYNOPSIS

Install Oh My Posh and add it to your profile.

## SYNTAX

### Font

```
Install-OhMyPosh [-WingetSource <string>] [-Method <string>] [-InstallNerdFont] [-Font <string>]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

An over-engineered script to install Oh My Posh.
This script exists as an exercise and is not intended for production use.

## EXAMPLES

### EXAMPLE 1

Install-OhMyPosh

## PARAMETERS

### -Font

Choose a nerd font to install.

- Default - Installs "Meslo" as the default nerd font.
- Select  - Lets you choose a nerd font from the list.

```yaml
Type: System.String
DefaultValue: Default
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Font
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -InstallNerdFont

Use this switch if you want to install a nerd font for full glyph capabilities in your prompt.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Font
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Method

Specify which tool to install Oh My Posh with.

- chocolatey
- direct (default)
- scoop
- winget

```yaml
Type: System.String
DefaultValue: direct
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -WingetSource

Specify which source to install from.

    - winget  - Install from winget (default).
    - msstore - Install from the Microsoft Store.

```yaml
Type: System.String
DefaultValue: winget
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
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

Author: Sam Erde
Version: 0.1.0
Modified: 2024-10-23


## RELATED LINKS

{{ Fill in the related links here }}

