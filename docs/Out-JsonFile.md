---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Out-JsonFile

## SYNOPSIS
Convert an object to JSON and write to a file.

## SYNTAX

```
Out-JsonFile [-Object] <Object> [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function converts an object to JSON and writes the output to the specified file.
By default, it saves the
file with the name of the object that you provided to the function.

## EXAMPLES

### EXAMPLE 1
```
Out-JsonFile -Object $TestObject
```

Writes the $TestObject as JSON to 'TestObject.json'.

## PARAMETERS

### -Object
Object to convert to JSON and save to a file

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path to save files in

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $PWD
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction. 
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Sam Erde
Version: 0.0.1
Modified: 2024/10/10

To-Do:
    Add error handling for objects that cannot be converted to JSON.
    Validate JSON?

## RELATED LINKS
