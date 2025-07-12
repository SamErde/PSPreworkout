---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Get-HashtableValueType

## SYNOPSIS
Get the object type of each value in a hashtable.

## SYNTAX

```
Get-HashtableValueType [-Hashtable] <Hashtable> [-Key <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This function retrieves the object type information of each value in a hashtable and returns
System.Reflection.TypeInfo objects with additional ItemKey properties for identification.
Results can be filtered to a specific key using the Key parameter.

## EXAMPLES

### EXAMPLE 1
```
Get-HashtableValueType -Hashtable @{ Key1 = 123; Key2 = "Hello"; Key3 = @(1, 2, 3) }
```

Returns type information for all keys in the hashtable, sorted by key name.

### EXAMPLE 2
```
Get-HashtableValueType -Hashtable @{ Key1 = 123; Key2 = "Hello"; Key3 = @(1, 2, 3) } -Key "Key2"
```

Returns type information only for the "Key2" entry (System.String).

### EXAMPLE 3
```
@{ Name = "John"; Age = 30; Active = $true } | Get-HashtableValueType
```

Demonstrates pipeline input usage to analyze hashtable value types.

### EXAMPLE 4
```
$config = @{ "Server Name" = "web01"; Port = 8080; SSL = $true }
Get-HashtableValueType $config -Key <TAB>
```

Shows tab completion for keys, including proper quoting for keys with spaces.

## PARAMETERS

### -Hashtable
The hashtable to inspect.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Key
Optional.
Specify a specific hashtable key to get the type information for only that key's value.
If not specified, type information for all keys will be returned.
Tab completion is available
for this parameter based on the keys in the provided hashtable.

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

### System.Reflection.TypeInfo
### Type information objects for each hashtable entry, enhanced with an ItemKey property
### and formatted using the PSPreworkout.HashtableValueType custom type.
## NOTES
This function is useful for debugging hashtables and understanding the data types of their values.
The output includes custom formatting via PSPreworkout.Format.ps1xml for improved readability.

## RELATED LINKS

[about_Hashtables]()
