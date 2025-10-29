---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Get-ModulesWithUpdate

## SYNOPSIS
Get a list of installed PowerShell modules that have updates available in their source repository.

## SYNTAX

```
Get-ModulesWithUpdate [[-Name] <System.Collections.Generic.List`1[System.String]>] [-PassThru]
 [<CommonParameters>]
```

## DESCRIPTION
This function retrieves a list of installed PowerShell modules and checks for updates available in their source
repository (e.g.: PowerShell Gallery or MAR).

If a pre-release version is installed, it checks the repository for a newer pre-release version or an equivalent
(or higher) stable version.
Otherwise, it only checks for stable updates.

## EXAMPLES

### EXAMPLE 1
```
Get-ModulesWithUpdate
This command retrieves all installed PowerShell modules and checks for updates in their source repository.
```

### EXAMPLE 2
```
Get-ModulesWithUpdate -PassThru
This command checks all installed modules for updates. It returns PSModuleInfo objects to the pipeline and displays
console output about available updates.
```

### EXAMPLE 3
```
Get-ModulesWithUpdate -Name 'Pester', 'PSScriptAnalyzer' -PassThru | Update-PSResource
This command checks specific modules for updates, displays console output about available updates, and pipes the
results to Update-PSResource.
```

## PARAMETERS

### -Name
The module name or list of module names to check for updates.
Wildcards and arrays are allowed.
All modules ('*') are checked by default.

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

### -PassThru
Display console output while returning module objects to the pipeline.
When specified, the function
will show available updates in the console and also return module objects for further processing.

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

### System.Management.Automation.PSObject
## NOTES
This function uses Microsoft.PowerShell.PSResourceGet cmdlets for improved performance and functionality over the
PowerShellGet module's cmdlets.
The required module will be automatically installed if not present.

Scope Priority: The function prioritizes CurrentUser scope modules over AllUsers scope modules, which matches
PowerShell's own behavior for importing or updating modules.
When a module is installed in both scopes, it checks
for updates against the CurrentUser version since that's what PowerShell would load by default.
Use -Verbose to see
which version and scope is being used for each module.

To Do:
- Batch and "paginate" online checks to speed up.
Find-PSResource can return multiple results in one request.
- Add parameter for specifying specific repositories to check.

## RELATED LINKS
