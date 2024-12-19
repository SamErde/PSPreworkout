---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Get-TypeAccelerator

## SYNOPSIS
Get available type accelerators.

## SYNTAX

```
Get-TypeAccelerator [[-Name] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get available type accelerators.
These can be useful when trying to find or remember the different type accellerators that are available to use in PowerShell.

## EXAMPLES

### EXAMPLE 1
```
Get-TypeAccelerator -Name ADSI
```

### EXAMPLE 2
```
Get-TypeAccelerator -Name ps*
```

Get all type accelerators that begin with the string "ps".

## PARAMETERS

### -Name
The name of a specific type accelerator to get.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: *
Accept pipeline input: False
Accept wildcard characters: True
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction. 
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Array
## NOTES
Author: Sam Erde
Version: 0.0.3
Modified: 2024/10/29

Thanks to Jeff Hicks (@JDHITSolutions) for helpful suggestions and improvements on this output!

Change Log: Removed the grid view option to allow user flexibility in how they want to output the results.
To Do: Add a way to filter/search the 'type' property.

## RELATED LINKS
