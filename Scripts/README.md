# Scripts

This directory contains scripts from **PSPreworkout** that may also be published separately to the PowerShell Gallery, as well as automation scripts for repository maintenance.

## Update-AllTheThings

- Build: Run `Update-AllTheThings_Build.ps1`
- Script Metadata: `Update-AllTheThings_ScriptInfo.ps1`
- Script to Publish: **Update-AllTheThings.ps1**

## Update-MkDocsNavigation.ps1

A PowerShell script that automatically updates the navigation section in `mkdocs.yml` based on the functions exported in the PowerShell module manifest (`PSPreworkout.psd1`).

### Features

- Reads `FunctionsToExport` from the module manifest
- Filters out aliases to include only actual functions
- Categorizes functions into three groups:
  - **Customize**: Functions for configuring PowerShell environment
  - **Develop**: Functions for PowerShell development tasks
  - **Daily Functions**: General utility functions for daily operations
- Updates the `nav:` section in mkdocs.yml while preserving all other content
- Sorts functions alphabetically within each category

### Usage

```powershell
# Run from repository root
.\Scripts\Update-MkDocsNavigation.ps1

# With verbose output
.\Scripts\Update-MkDocsNavigation.ps1 -Verbose

# Specify custom paths
.\Scripts\Update-MkDocsNavigation.ps1 -ManifestPath "./src/PSPreworkout/PSPreworkout.psd1" -MkDocsPath "./mkdocs.yml"
```

### Automation

This script is automatically executed by the **Update MkDocs Navigation** GitHub Actions workflow whenever changes are pushed to the module manifest (`PSPreworkout.psd1`) on the main branch. The workflow:

1. Runs the script to update mkdocs.yml
2. Checks if any changes were made
3. Commits and pushes the updated mkdocs.yml back to the repository

This ensures that the documentation navigation always stays in sync with the exported functions.
