---
document type: cmdlet
external help file: PSPreworkout-Help.xml
HelpUri: https://day3bits.com/PSPreworkout/Get-TypeAccelerator
Locale: en-US
Module Name: PSPreworkout
ms.date: 01/23/2026
PlatyPS schema version: 2024-05-01
title: Get-TypeAccelerator
---

# Get-TypeAccelerator

## SYNOPSIS

Get available type accelerators.

## SYNTAX

### __AllParameterSets

```
Get-TypeAccelerator [[-Name] <string>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Get available type accelerators.
These can be useful when trying to find or remember the different type accelerators
that are available to use in PowerShell.

## EXAMPLES

### EXAMPLE 1

Get-TypeAccelerator -Name ADSI

### EXAMPLE 2

Get-TypeAccelerator -Name ps*

Get all type accelerators that begin with the string "ps".

## PARAMETERS

### -Name

The name of a specific type accelerator to get.

```yaml
Type: System.String
DefaultValue: '*'
SupportsWildcards: true
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
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

### Object

{{ Fill in the Description }}

## NOTES

Thanks to Jeff Hicks (@JDHITSolutions) for helpful suggestions and improvements on this output!


## RELATED LINKS

{{ Fill in the related links here }}

