<!-- markdownlint-disable first-line-heading -->
<!-- markdownlint-disable blanks-around-headings -->
<!-- markdownlint-disable no-inline-html -->
<a name='top'></a><div id='top' />
# PowerShell Preworkout (PSPreworkout)

A special mix of tools to help jump start your PowerShell session!

<!-- badges-start -->
[![GitHub stars](https://img.shields.io/github/stars/samerde/PSPreworkout?cacheSeconds=3600)](https://github.com/samerde/PSPreworkout/stargazers/)
![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/PSPreworkout?include_prereleases)
![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/PSPreworkout)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)
[![GitHub contributors](https://img.shields.io/github/contributors/samerde/PSPreworkout.svg)](https://github.com/samerde/PSPreworkout/graphs/contributors/)

![GitHub top language](https://img.shields.io/github/languages/top/SamErde/PSPreworkout)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/ae92f0d929de494690e712b68fb3b52c)](https://app.codacy.com/gh/SamErde/PSPreworkout/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/SamErde/PSPreworkout/.github%2Fworkflows%2FBuild%20Module.yml)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/SamErde/PSPreworkout/.github%2Fworkflows%2FDeploy%20MkDocs.yml?label=MkDocs)
<!-- badges-end -->

&nbsp;
<img src="https://raw.githubusercontent.com/SamErde/PSPreworkout/main/media/PSPreworkout-Animated-Logo-170.png" alt="PSPreworkout Logo (Image generated by Microsoft Designer)" width="400" />
&nbsp;

## Inspiration

Why **PSPreworkout**? Whether you are developing PowerShell code or performing daily tasks, the goal of PSPreworkout is to start working efficiently as quickly as possible. The idea for the name was inspired by the pre-workout mix that I sometimes drink for an extra kick of energy and focus before working out.

The **PSPreworkout** module contains shortcuts for setting up a PowerShell environment, configuring Git, customizing the shell, working with environment variables, creating new script files from a template, updating packages, and more!

## Getting Started

```powershell
Install-Module -Name PSPreworkout -Scope CurrentUser
Get-Command -Module PSPreworkout
```

## Contributing

Please feel free to use the issues or a PR to report bugs, suggest improvements, or add new ideas to the module!

## PSPreworkout Cmdlets
### [Edit-WingetSettingsFile](./docs/Edit-WingetSettingsFile.md)
Edit the WinGet settings file.

### [Get-EnvironmentVariable](./docs/Get-EnvironmentVariable.md)
Retrieves the value of an environment variable.

### [Get-LoadedAssembly](./docs/Get-LoadedAssembly.md)
Get all assemblies loaded in PowerShell.

### [Get-PowerShellPortable](./docs/Get-PowerShellPortable.md)
Download a portable version of PowerShell to run anywhere on demand.

### [Get-TypeAccelerator](./docs/Get-TypeAccelerator.md)
Get available type accelerators.

### [Initialize-PSEnvironmentConfiguration](./docs/Initialize-PSEnvironmentConfiguration.md)
Initialize configuration your PowerShell environment and git.

### [Install-OhMyPosh](./docs/Install-OhMyPosh.md)
Install Oh My Posh and add it to your profile.

### [Install-PowerShellISE](./docs/Install-PowerShellISE.md)
Install the Windows PowerShell ISE if you removed it after installing VS Code.

### [Install-WinGet](./docs/Install-WinGet.md)
Install Winget

### [New-Credential](./docs/New-Credential.md)
Create a new secure credential.

### [New-ScriptFromTemplate](./docs/New-ScriptFromTemplate.md)
Create a new advanced function from a template.

### [Set-ConsoleFont](./docs/Set-ConsoleFont.md)
Set the font for your consoles.

### [Set-EnvironmentVariable](./docs/Set-EnvironmentVariable.md)
Set environment variables.

### [Show-LoadedAssembly](./docs/Show-LoadedAssembly.md)
Show all assemblies loaded in PowerShell.

### [Test-IsElevated](./docs/Test-IsElevated.md)
Check if you are running an elevated shell with administrator or root privileges.

### [Update-AllTheThings](./docs/Update-AllTheThings.md)
Update all the things!


