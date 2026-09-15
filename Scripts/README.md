# Scripts

This directory contains public scripts from **PSPreworkout** that may also be published separately to the PowerShell Gallery.

## Update-AllTheThings

- Build: Run `Update-AllTheThings_Build.ps1`
- Script Metadata: `Update-AllTheThings_ScriptInfo.ps1`
- Script to Publish: **Update-AllTheThings.ps1**
- Publish: Pushing a `script-v*.*.*` tag triggers the GitHub Actions workflow that validates
  and publishes `Update-AllTheThings.ps1` to the PowerShell Gallery.
