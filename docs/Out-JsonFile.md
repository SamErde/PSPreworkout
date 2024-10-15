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
Out-JsonFile [-Object] <Object> [[-FilePath] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This function converts an object to JSON and writes the output to the specified file.
By default, it saves the
file with the name of the object that you provided to the function.

## EXAMPLES

### EXAMPLE 1
```
Out-JsonFile -Object $TestObject -FilePath $HOME
```

Writes $TestObject as JSON to "$HOME/TestObject.json".

### EXAMPLE 2
```
Out-JsonFile -Object $TestObject -FilePath C:\Temp\report.json
```

Writes $TestObject as JSON to C:\Temp\report.json.

### EXAMPLE 3
```
Out-JsonFile -Object $TestObject
```

Writes $TestObject as JSON to TestObject.json in the current working directory of the file system.

## PARAMETERS

### -Object
Object to convert to JSON and save it to a file.
Check for empty objects here or in the function body?
\[ValidateScript({ if (-not \[string\]::IsNullOrWhiteSpace($_) -and -not \[string\]::IsNullOrEmpty($_)) { $true } })\]

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -FilePath
Full path and filename to save the JSON to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
Author: Sam Erde
Version: 0.2.0
Modified: 2024/10/15

## RELATED LINKS
