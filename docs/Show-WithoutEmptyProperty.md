---
document type: cmdlet
external help file: PSPreworkout-Help.xml
HelpUri: https://day3bits.com/PSPreworkout/Show-WithoutEmptyProperty
Locale: en-US
Module Name: PSPreworkout
ms.date: 01/23/2026
PlatyPS schema version: 2024-05-01
title: Show-WithoutEmptyProperty
---

# Show-WithoutEmptyProperty

## SYNOPSIS

Show an object without its empty properties.

## SYNTAX

### __AllParameterSets

```
Show-WithoutEmptyProperty [-Object] <Object> [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

This function shows the properties of an object with all of its empty properties filtered out.

## EXAMPLES

### EXAMPLE 1

Show-WithoutEmptyProperty -Object $Object

### EXAMPLE 2

$Desk = [PSCustomObject]@{
    Model = 'PSDesk'
    Height = $null
    Width = $null
    Colors = @('Black', 'Gray')
    Adjustable = $true
}
$Object = New-Object -TypeName PSObject -Property $Desk
Show-WithoutEmptyProperty -Object $Object

This example creates an object from a hash table and then shows that object's properties that have values.

### EXAMPLE 3

Show-WithoutEmptyProperty -Object (Get-Item $HOME)

This example gets the home folder object while invoking the function.

### EXAMPLE 4

$Object | Show-WithoutEmptyProperty

This example shows how an object can be piped to the function.

### EXAMPLE 5

Get-ChildItem $HOME | Select-Object -First 1 | Show-WithoutEmptyProperty

This example gets the home folder object and pipes it to the Show-WithoutEmptyProperty function.

## PARAMETERS

### -Object

The object to show.

```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: true
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

### System.Object

{{ Fill in the Description }}

## OUTPUTS

### PSCustomObject

{{ Fill in the Description }}

## NOTES

I am grateful to Jeffrey Hicks for guiding me towards an understanding of how to complete this function and for
providing even nicer code than I started with.
I encourage you to reach out to him for PowerShell training and
subscribe to his newsletter! 🙏

    https://jdhitsolutions.github.io/
    https://www.linkedin.com/in/jefferyhicks/
    https://twitter.com/JeffHicks


## RELATED LINKS

{{ Fill in the related links here }}

