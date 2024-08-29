<!-- markdownlint-disable first-line-heading -->
<!-- markdownlint-disable blanks-around-headings -->
<!-- markdownlint-disable no-inline-html -->
<a name='top'></a><div id='top' />
# PowerShell Pre-Workout (PSPreworkout)

A special mix of tools (and experiments) to help jump start your PowerShell session!

<!-- badges-start -->
[![GitHub stars](https://img.shields.io/github/stars/samerde/powershell?cacheSeconds=3600)](https://github.com/samerde/PSPreworkout/stargazers/)
[![GitHub contributors](https://img.shields.io/github/contributors/samerde/powershell.svg)](https://github.com/samerde/PSPreworkout/graphs/contributors/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/ae92f0d929de494690e712b68fb3b52c)](https://app.codacy.com/gh/SamErde/PSPreworkout/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/PSPreworkout?include_prereleases)
![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/PSPreworkout)
<!-- badges-end -->

<img src="https://raw.githubusercontent.com/SamErde/PSPreworkout/main/media/PSPreWorkout-Droid-1.jpg" alt="An image generated by Bing Image Creator. Prompt: hooded robot hacker wearing a PowerShell shirt, drinking a powerful energy drink with energy swirling around the cup, surrounded by swirling energy, floating in the air, cinematic, hacker professional photography, studio lighting, studio background, advertising photography, intricate details, hyper-detailed, ultra realistic, 8K UHD, PowerShell" width="400" />

## Functions

  | Script | Description |
  | :---   | :---         |
  | [Update-AllTheThings](#updateallthethings) | All-in-one script to update PowerShell modules, PowerShell help, and multiple types of packages (apt, brew, Chocolatey, and winget). |
  | [Install-PowerShellISE](#installpowershellise) | Reinstall the PowerShell ISE for compatibility testing. :wink: |
  | [Get-EnvironmentVariable](#getenvironmentvariable) | Easily get one or all environment variables. |
  | [Set-EnvironmentVariable](#setenvironmentvariable) | Easily set an environment variable. |

## Experimental and Incomplete Functions

  | Script | Description |
  | :---   | :---         |
  | [New-ProfileWorkspace](#newprofileworkspace) | Setup a folder and VS Code Workspace for maintaining your PowerShell profiles, VS Code settings, and Windows Terminal settings. |
  | [New-DotSourcedProfile](#newdotsourcedprofile) | Point all of your CurrentUserHost PowerShell profiles to a central dot sourced profile. |
  | [Install-OhMyPosh](#installohmyposh) | Install Oh My Posh with Nerd Fonts to make your shell beautiful and functional. |
  | [Get-RecommendedModules](#getrecommendedmodules) | Get a list of community recommended modules. |
  | [Install-RecommendedModules](#installrecommendedmodules) | Easily install optional recommended modules. |

&nbsp;

## Script Details

&nbsp;

<a name="updateallthethings"></a><div id='updateallthethings' />
## Update-AllTheThings

### Synopsis

Run one command to update all of the things!

### Description

A script that works on Windows, Linux, and macOS to update PowerShell modules, PowerShell help, and packages with apt, brew, Chocolately, and winget.

&nbsp;

<a name="newdotsourcedprofile"></a><div id='newdotsourcedprofile' />
## New-DotSourcedProfile

I need to automate this one still, but it will be a script that creates one central profile script and then sets each CurrentUser profile to dot source that central profile for easier sync across all of your profiles for PowerShell, PowerShell ISE, Visual Studio Code, Windows PowerShell, etc.

&nbsp;

<a name='installohmyposh'></a><div id='installohmyposh' />
## Install-OhMyPosh

<!-- markdownlint-disable no-duplicate-heading -->
### Synopsis
<!-- markdownlint-enable no-duplicate-heading -->

Install Oh My Posh, or update it if already installed.

- Script: [Install-OhMyPosh.ps1](Install-OhMyPosh.ps1)
- Status: Working :runner:

<!-- markdownlint-disable no-duplicate-heading -->
### Description
<!-- markdownlint-enable no-duplicate-heading -->

This is a quick installer for Oh My Posh. It's almost unnecessary because of how easy OMP is to install, but may be helpful to people who are brand new to it and want to save time. Includes steps to install Nerd Fonts. Nerd Fonts are required to get the most out of Oh My Posh and some great modules like Posh-Git, and Terminal Icons.

&nbsp;

<a name="installpowershellise"></a><div id='installpowershellise' />
## Install-PowerShellISE

Install the PowerShell ISE if it was removed. It can be helpful to keep the ISE installed for compatibility testing.

- Script: [Install-PowerShellISE.ps1](Install-PowerShellISE.ps1)
- Status: Working :runner:

&nbsp;

<a name="getenvironmentvariable"></a><div id='getenvironmentvariable' />
## Get-EnvironmentVariable

Easily get a specific environment variable or list all of them.

- Script: [Get-EnvironmentVariable.ps1](Get-EnvironmentVariable.ps1)
- Status: Working :runner:

&nbsp;

<a name="setenvironmentvariable"></a><div id='setenvironmentvariable' />
## Set-EnvironmentVariable

Set an environment variable.

- Script: [Set-EnvironmentVariable.ps1](Set-EnvironmentVariable.ps1)
- Status: Working :runner:
