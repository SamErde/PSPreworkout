---
document type: cmdlet
external help file: PSPreworkout-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSPreworkout
ms.date: 01/23/2026
PlatyPS schema version: 2024-05-01
title: Get-ModulesWithUpdate
---

# Get-ModulesWithUpdate

## SYNOPSIS

Get a list of installed PowerShell modules that have updates available in their source repository.

## SYNTAX

### __AllParameterSets

```
Get-ModulesWithUpdate [[-Name] <List`1[string]>] [-PassThru] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

This function retrieves a list of installed PowerShell modules and checks for updates available in their source
repository (e.g.: PowerShell Gallery or MAR).

If a pre-release version is installed, it checks the repository for a newer pre-release version or an equivalent
(or higher) stable version.
Otherwise, it only checks for stable updates.

## EXAMPLES

### EXAMPLE 1

Get-ModulesWithUpdate
This command retrieves all installed PowerShell modules and checks for updates in their source repository.

### EXAMPLE 2

Get-ModulesWithUpdate -PassThru
This command checks all installed modules for updates. It returns PSModuleInfo objects to the pipeline and displays
console output about available updates.

### EXAMPLE 3

Get-ModulesWithUpdate -Name 'Pester', 'PSScriptAnalyzer' -PassThru | Update-PSResource
This command checks specific modules for updates, displays console output about available updates, and pipes the
results to Update-PSResource.

## PARAMETERS

### -Name

The module name or list of module names to check for updates.
Wildcards and arrays are allowed.
All modules ('*') are checked by default.

```yaml
Type: System.Collections.Generic.List`1[System.String]
DefaultValue: "@('*')"
SupportsWildcards: true
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: false
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -PassThru

Display console output while returning module objects to the pipeline.
When specified, the function
will show available updates in the console and also return module objects for further processing.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
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

### System.Collections.Generic.List`1[[System.String, System.Private.CoreLib, Version=9.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]

{{ Fill in the Description }}

## OUTPUTS

### System.Management.Automation.PSObject

{{ Fill in the Description }}

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

{{ Fill in the related links here }}

