---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Get-EnvironmentVariable

## SYNOPSIS
Retrieves the value of an environment variable.

## SYNTAX

### LookupByName (Default)
```
Get-EnvironmentVariable [[-Name] <String>] [-Target <EnvironmentVariableTarget[]>] [-All]
 [<CommonParameters>]
```

### LookupByRegexPattern
```
Get-EnvironmentVariable [[-Pattern] <String>] [-Target <EnvironmentVariableTarget[]>] [-All]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-EnvironmentVariable function retrieves the value of the specified environment variable or displays all
environment variables.
It is capable of finding variables by an exact name match or by using a regex pattern match.
It can retrieve environment variables from the process, machine, and user targets.
If no parameters are specified,
all environment variables are returned from all targets.

## EXAMPLES

### EXAMPLE 1
```
Get-EnvironmentVariable -Name 'UserName' -Target 'User'
```

Retrieves the value of the "UserName" environment variable from the process target.

### EXAMPLE 2
```
Get-EnvironmentVariable -Name 'Path' -Target 'Machine'
```

Retrieves the value of the PATH environment variable from the machine target.

### EXAMPLE 3
```
Get-EnvironmentVariable -Pattern '^u'
```

Get environment variables with names that begin with the letter "u" in any target.

## PARAMETERS

### -Name
The name of the environment variable to retrieve.

```yaml
Type: String
Parameter Sets: LookupByName
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Pattern
A regex pattern to find matching environment variable names.

```yaml
Type: String
Parameter Sets: LookupByRegexPattern
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Target
The target (Process, Machine, User) to pull environment variables from.
Multiple targets may be specified.

```yaml
Type: EnvironmentVariableTarget[]
Parameter Sets: (All)
Aliases:
Accepted values: Process, User, Machine

Required: False
Position: Named
Default value: [System.EnvironmentVariableTarget].GetEnumValues()
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
Optionally get all environment variables from all targets or all environment variables from one specified target.
Process ID and process name will be included for process environment variables.

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

### System.Object[]
## NOTES
Author: Sam Erde
Version: 1.0.0
Modified: 2025/03/05

About Environment Variables:

Variable names are case-sensitive on Linux and macOS, but not on Windows.
PowerShell is case-insensitive by default
and compensates for case-sensitivity on Linux and macOS.
To make PowerShell case-sensitive, use the -CaseSensitive
parameter when starting PowerShell.

Why is 'Target' used by .NET instead of the familiar 'Scope' parameter name?
@IISResetMe (Mathias R.
Jessen) explains:
"Scope" would imply some sort of integrated hierarchy of env variables - that's not really the case.
Target=Process translates to kernel32!GetEnvironmentVariable (which then in turn reads the PEB from
the calling process), whereas Target={User,Machine} causes a registry lookup against environment
data in either HKCU or HKLM.

The relevant sources for the User and Machine targets are in the registry at:
- HKEY_CURRENT_USER\Environment
- HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment

See more at \<https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables\>.

## RELATED LINKS
