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
Get-TypeAccelerator [[-Name] <String>] [-GridView] [<CommonParameters>]
```

## DESCRIPTION
Get available type accelerators.
These can be useful when trying to find or remember the different type accellerators that are available to use in PowerShell.

## EXAMPLES

### EXAMPLE 1
```
Get-TypeAccelerator -Name ADSI
```

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

### -GridView
Show the output in a grid view.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction. 
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Array
## NOTES
Thanks to Jeff Hicks (@JDHITSolutions) for helpful suggestions and improvements on this output!

## RELATED LINKS
