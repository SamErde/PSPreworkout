---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Get-ModulesWithUpdate

## SYNOPSIS
Get a list of installed PowerShell modules that have updates available in the PowerShell Gallery.

## SYNTAX

```
Get-ModulesWithUpdate [[-Name] <System.Collections.Generic.List`1[System.String]>]
 [<CommonParameters>]
```

## DESCRIPTION
This function retrieves a list of installed PowerShell modules and checks for updates available in the source repository.

## EXAMPLES

### EXAMPLE 1
```
Get-ModulesWithUpdate
This command retrieves all installed PowerShell modules and checks for updates available in the PowerShell Gallery.
```

## PARAMETERS

### -Name
The module name or list of module names to check for updates.
Wildcards are allowed, and all modules are checked by default.

```yaml
Type: System.Collections.Generic.List`1[System.String]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: @('*')
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: True
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction. 
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSPreworkout.ModuleInfo
## NOTES
To Do:
- Batch and "paginate" online checks to speed up.
Find-Module can return up to 63 results in one request.
- Add support for checking other repositories.

## RELATED LINKS
