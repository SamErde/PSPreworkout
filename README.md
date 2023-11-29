# PowerShell Pre-Workout

My little collection of tools and scripts to help jump start your PowerShell session!

## New-ProfileWorkspace

### Synopsis

Setup a folder and VS Code Workspace for maintaining your PowerShell profiles, VS Code settings, and Windows Terminal settings.

### Description

I wanted an easy way to maintain all of my CurrentUser PowerShell profiles and settings for Visual Studio Code and Windows Terminal. There are probably easier ways to accomplish this, but my basic goal was to not have to hunt for these files across the file system in order to edit them. This script creates a folder that contains:

  - Junction points to the locations of your CurrentUser PowerShell and Windows PowerShell folders
  - Junction points to the locations of your settings for VS Code and Windows Terminal
  - Structural artifacts in case you want to save this as a repository
    - A Visual Studio Code workspace file that opens this new folder
    - EditorConfig and Visual Studio Code settings files for consistent editing
    - A .gitignore file in case you want to use this as a git repository (test?)

## New-DotSourcedProfile

I need to automate this one still, but it will be a script that creates one central profile script and then sets each CurrentUser profile to dot source that central profile for easier sync across all of your profiles for PowerShell, PowerShell ISE, Visual Studio Code, Windows PowerShell, etc.
