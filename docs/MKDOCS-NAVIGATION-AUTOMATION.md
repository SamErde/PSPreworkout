# MkDocs Navigation Automation

## Overview

This document describes the automated solution for keeping the MkDocs navigation synchronized with the PowerShell module's exported functions.

## Problem Statement

Previously, the `nav` section in `mkdocs.yml` had to be manually maintained whenever new functions were added to the module. This led to:
- Missing functions in documentation navigation
- Duplicate entries
- Typos in file paths
- Inconsistent organization

## Solution

An automated system that:
1. Reads the `FunctionsToExport` from the module manifest (`PSPreworkout.psd1`)
2. Filters out aliases to include only actual functions
3. Categorizes functions into three logical groups
4. Updates the `mkdocs.yml` navigation section automatically
5. Triggers whenever the module manifest is updated on the main branch

## Components

### 1. PowerShell Script (`Scripts/Update-MkDocsNavigation.ps1`)

**Purpose**: Updates the navigation section in mkdocs.yml based on the module manifest.

**Key Functions**:
- `Get-FunctionCategory`: Determines which category a function belongs to
- `Get-CategorizedFunctions`: Reads and categorizes all exported functions
- `New-NavigationYaml`: Generates the YAML structure for the nav section
- `Update-MkDocsYaml`: Updates the mkdocs.yml file while preserving other content

**Function Categories**:
- **Customize**: Functions for configuring PowerShell environment
  - `Initialize-PSEnvironmentConfiguration`
  - `Install-*` cmdlets
  - `Set-*` cmdlets  
  - `Edit-*` cmdlets for environment files
  
- **Develop**: Functions for PowerShell development tasks
  - `New-ScriptFromTemplate`
  - `Get-TypeAccelerator`
  - `Get-LoadedAssembly`
  - `Show-LoadedAssembly`

- **Daily Functions**: General utility functions for daily operations
  - All other functions (Get-*, Test-*, Update-*, Out-*, Show-*)

### 2. GitHub Actions Workflow (`.github/workflows/Update MkDocs Navigation.yml`)

**Triggers**:
- Push to `main` branch with changes to `src/PSPreworkout/PSPreworkout.psd1`
- Manual workflow dispatch

**Steps**:
1. Checkout repository
2. Run `Update-MkDocsNavigation.ps1`
3. Check if mkdocs.yml was modified
4. Commit and push changes if mkdocs.yml was updated

**Permissions**:
- `contents: write` - to commit changes
- `pull-requests: write` - for PR operations if needed

### 3. Pester Tests (`src/Tests/Unit/Update-MkDocsNavigation.Tests.ps1`)

**Test Coverage**:
- Script file validation (existence, syntax, help)
- Function categorization logic (12 tests)
- Navigation YAML generation (7 tests)
- Integration tests (5 tests)

**Results**: 27 tests passed, 0 failed

## Usage

### Automatic (Recommended)

The workflow automatically runs when you:
1. Update `FunctionsToExport` in `src/PSPreworkout/PSPreworkout.psd1`
2. Push changes to the `main` branch
3. The workflow updates `mkdocs.yml` and commits it back

### Manual

Run the script directly:

```powershell
# From repository root
.\Scripts\Update-MkDocsNavigation.ps1

# With verbose output
.\Scripts\Update-MkDocsNavigation.ps1 -Verbose

# With custom paths
.\Scripts\Update-MkDocsNavigation.ps1 -ManifestPath "path/to/manifest.psd1" -MkDocsPath "path/to/mkdocs.yml"
```

## Benefits

1. **Automation**: No manual maintenance of navigation structure
2. **Consistency**: Functions always appear in the same order (alphabetical within categories)
3. **Accuracy**: Prevents typos, duplicates, and missing entries
4. **Time Savings**: Eliminates manual updates to mkdocs.yml
5. **Documentation Quality**: Ensures documentation is always in sync with code

## Maintenance

### Adding New Functions

1. Add the function to `src/PSPreworkout/Public/`
2. Add the function name to `FunctionsToExport` in the manifest
3. Push to main branch
4. The workflow automatically updates mkdocs.yml

### Modifying Categories

To change which category a function belongs to:

1. Edit the `Get-FunctionCategory` function in `Scripts/Update-MkDocsNavigation.ps1`
2. Update the `$developFunctions` or `$customizeFunctions` arrays
3. Run the script manually or push changes to trigger the workflow

### Testing Changes

```powershell
# Run the Pester tests
Import-Module Pester
Invoke-Pester -Path ./src/Tests/Unit/Update-MkDocsNavigation.Tests.ps1
```

## Files Modified

- ✅ `Scripts/Update-MkDocsNavigation.ps1` - Created
- ✅ `.github/workflows/Update MkDocs Navigation.yml` - Created
- ✅ `src/Tests/Unit/Update-MkDocsNavigation.Tests.ps1` - Created
- ✅ `Scripts/README.md` - Updated with documentation
- ✅ `mkdocs.yml` - Fixed navigation (removed duplicates, corrected typos, added missing functions)

## Example: Before and After

### Before
- Manual updates required
- Had duplicate "Install-CommandNotFoundUtility" entry
- Had typo "Install-CommandNoteFoundUtility"
- Missing "Get-HashtableValueType" and other functions
- "New-Credential" was listed but doesn't exist in manifest

### After
- Automatic updates
- No duplicates
- All typos corrected
- All exported functions included
- Non-existent functions removed
- Consistent alphabetical ordering

## Future Enhancements

Possible improvements:
- Add metadata tags in function files to specify categories
- Support for multiple documentation levels (beginner/advanced)
- Auto-generate function index page
- Support for versioned documentation

## Troubleshooting

### Workflow doesn't trigger
- Check that changes were pushed to `main` branch
- Verify `src/PSPreworkout/PSPreworkout.psd1` was modified
- Check workflow permissions in repository settings

### Script fails locally
- Ensure you're running from repository root
- Check PowerShell version (requires 5.1+)
- Verify manifest file exists at expected path

### Tests fail
- Some tests may skip if running outside the repository structure
- Check that Pester 5.0+ is installed
- Verify test file paths are correct

## References

- [MkDocs Documentation](https://www.mkdocs.org/)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Pester Testing Framework](https://pester.dev/)
