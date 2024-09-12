---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# New-ScriptFromTemplate

## SYNOPSIS
Create a new advanced function from a template.

## SYNTAX

### Named
```
New-ScriptFromTemplate -Name <String> [-SkipValidation] [-Synopsis <String>] [-Description <String>]
 [-Alias <String>] [-Path <String>] [<CommonParameters>]
```

### VerbNoun
```
New-ScriptFromTemplate -Verb <String> -Noun <String> [-SkipValidation] [-Synopsis <String>]
 [-Description <String>] [-Alias <String>] [-Path <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This function creates a new function from a template and saves it to a file with the name of the function.
It takes values for the function's synopsis, description, and alias as parameters and populates comment-
based help for the new function automatically.

## EXAMPLES

### EXAMPLE 1
```
New-ScriptFromTemplate -Name "Get-Demo" -Synopsis "Get a demo." -Description "This function gets a demo." -Alias "Get-Sample"
```

## PARAMETERS

### -Name
The name of the new function to create.
It is recommended to use ApprovedVerb-Noun for names.

```yaml
Type: String
Parameter Sets: Named
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Verb
The verb to use for the function name.

```yaml
Type: String
Parameter Sets: VerbNoun
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Noun
The noun to use for the function name.

```yaml
Type: String
Parameter Sets: VerbNoun
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipValidation
Optionally skip validation of the script name.
This will not check for use of approved verbs or restricted characters.

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

### -Synopsis
A synopsis of the new function.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
A description of the new function.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Alias
Optionally define an alias for the new function.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
The path of the directory to save the new script in.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
