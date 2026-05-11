<#
.SYNOPSIS
    Updates the navigation section in mkdocs.yml based on functions exported from the PowerShell module manifest.

.DESCRIPTION
    This script reads FunctionsToExport from the PowerShell module manifest, categorizes them
    into three groups (Customize, Develop, Daily Functions), and updates the nav section in mkdocs.yml.
    It preserves all other content in mkdocs.yml while only updating the navigation structure.

.PARAMETER ManifestPath
    Path to the PowerShell module manifest file (.psd1).

.PARAMETER MkDocsPath
    Path to the mkdocs.yml configuration file.

.EXAMPLE
    .\.github\cicd-scripts\Update-MkDocsNavigation.ps1

.EXAMPLE
    .\.github\cicd-scripts\Update-MkDocsNavigation.ps1 -ManifestPath "./src/PSPreworkout/PSPreworkout.psd1" -MkDocsPath "./mkdocs.yml"
#>

[CmdletBinding()]
param (
    [Parameter()]
    [ValidateNotNullOrWhiteSpace()]
    [string]$ManifestPath = "./src/PSPreworkout/PSPreworkout.psd1",

    [Parameter()]
    [ValidateNotNullOrWhiteSpace()]
    [string]$MkDocsPath = "./mkdocs.yml"
)

#region Helper Functions

function Get-FunctionCategory {
    <#
    .SYNOPSIS
        Determines the category for a given function name.

    .DESCRIPTION
        Categorizes functions based on their naming patterns and purpose:

        - Customize: Functions for customizing your PowerShell environment
        - Develop: Functions for PowerShell development tasks
        - Daily Functions: General utility functions for everyday use
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$FunctionName
    )

    # Develop category functions
    $developFunctions = @(
        'New-ScriptFromTemplate',
        'Get-TypeAccelerator',
        'Get-LoadedAssembly',
        'Show-LoadedAssembly'
    )

    # Customize category functions (environment configuration)
    $customizeFunctions = @(
        'Initialize-PSEnvironmentConfiguration',
        'Install-CommandNotFoundUtility',
        'Install-OhMyPosh',
        'Install-PowerShellISE',
        'Install-WinGet',
        'Set-ConsoleFont',
        'Set-DefaultTerminal',
        'Edit-WinGetSettingsFile',
        'Edit-PSReadLineHistoryFile'
    )

    if ($developFunctions -contains $FunctionName) {
        return 'Develop'
    } elseif ($customizeFunctions -contains $FunctionName) {
        return 'Customize'
    } else {
        return 'Daily Functions'
    }
}

function Get-CategorizedFunction {
    <#
    .SYNOPSIS
        Reads functions from manifest and categorizes them.

    .DESCRIPTION
        Imports the PowerShell module manifest and categorizes exported functions into
        their respective groups. Aliases are expected to be exported only through
        AliasesToExport and are not included in FunctionsToExport.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ManifestPath
    )

    if (-not (Test-Path $ManifestPath)) {
        throw "Manifest file not found at: $ManifestPath"
    }

    Write-Verbose "Reading manifest from: $ManifestPath"
    $manifest = Import-PowerShellDataFile -Path $ManifestPath

    $functions = $manifest.FunctionsToExport | Sort-Object

    $categorized = @{
        Customize       = @()
        Develop         = @()
        'Daily Functions' = @()
    }

    foreach ($function in $functions) {
        $category = Get-FunctionCategory -FunctionName $function
        $categorized[$category] += $function
        Write-Verbose "Categorized '$function' as '$category'"
    }

    return $categorized
}

function ConvertTo-NavigationYaml {
    <#
    .SYNOPSIS
        Generates the nav section YAML content.

    .DESCRIPTION
        Converts categorized functions into YAML structure for the nav section.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [hashtable]$CategorizedFunctions
    )

    $nav = @()
    $nav += 'nav:'
    $nav += '  - Home: "index.md"'

    # Customize category
    if ($CategorizedFunctions['Customize'].Count -gt 0) {
        $nav += '  - Customize:'
        foreach ($func in $CategorizedFunctions['Customize']) {
            $nav += "      - $func`: `"$func.md`""
        }
    }

    # Develop category
    if ($CategorizedFunctions['Develop'].Count -gt 0) {
        $nav += '  - Develop:'
        foreach ($func in $CategorizedFunctions['Develop']) {
            $nav += "      - $func`: `"$func.md`""
        }
    }

    # Daily Functions category
    if ($CategorizedFunctions['Daily Functions'].Count -gt 0) {
        $nav += '  - Daily Functions:'
        foreach ($func in $CategorizedFunctions['Daily Functions']) {
            $nav += "      - $func`: `"$func.md`""
        }
    }

    return $nav
}

function Update-MkDocsYaml {
    <#
    .SYNOPSIS
        Updates the mkdocs.yml file with new navigation.

    .DESCRIPTION
        Reads the existing mkdocs.yml, replaces the nav section with the updated version,
        and writes it back to the file.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory)]
        [string]$MkDocsPath,

        [Parameter(Mandatory)]
        [string[]]$NewNavLines
    )

    if (-not (Test-Path $MkDocsPath)) {
        throw "MkDocs configuration file not found at: $MkDocsPath"
    }

    Write-Verbose "Reading mkdocs.yml from: $MkDocsPath"
    $lines = Get-Content -Path $MkDocsPath

    # Find the start of the nav section
    $navStartIndex = -1
    $navEndIndex = -1

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^nav:') {
            $navStartIndex = $i
            Write-Verbose "Found nav section at line $($i + 1)"
        } elseif ($navStartIndex -ge 0 -and $lines[$i] -match '^[a-z_]+:') {
            # Found the start of the next top-level section
            $navEndIndex = $i - 1
            Write-Verbose "Found end of nav section at line $($i)"
            break
        }
    }

    # If we found nav section but no end marker, nav goes to end of file
    if ($navStartIndex -ge 0 -and $navEndIndex -eq -1) {
        $navEndIndex = $lines.Count - 1
        Write-Verbose "Nav section extends to end of file"
    }

    if ($navStartIndex -eq -1) {
        Write-Warning "Could not find nav section in mkdocs.yml"
        return $false
    }

    # Build the new content
    $newContent = @()

    # Add everything before nav
    if ($navStartIndex -gt 0) {
        $newContent += $lines[0..($navStartIndex - 1)]
    }

    # Add the new nav section
    $newContent += $NewNavLines

    # Add everything after nav (if there is anything)
    if ($navEndIndex -lt ($lines.Count - 1)) {
        $newContent += ""  # Add blank line before next section
        $newContent += $lines[($navEndIndex + 1)..($lines.Count - 1)]
    }

    if ($PSCmdlet.ShouldProcess($MkDocsPath, 'Update MkDocs navigation')) {
        Write-Verbose "Writing updated mkdocs.yml with $($newContent.Count) lines"
        $newContent | Set-Content -Path $MkDocsPath
        return $true
    }

    return $false
}

#endregion Helper Functions

if ($MyInvocation.InvocationName -ne '.') {
    #region Main Script

    try {
        Write-Information "Analyzing PowerShell module manifest..." -InformationAction Continue

        # Get categorized functions from manifest
        $categorizedFunctions = Get-CategorizedFunction -ManifestPath $ManifestPath

        Write-Information "Function counts:" -InformationAction Continue
        Write-Information "   Customize: $($categorizedFunctions['Customize'].Count)" -InformationAction Continue
        Write-Information "   Develop: $($categorizedFunctions['Develop'].Count)" -InformationAction Continue
        Write-Information "   Daily Functions: $($categorizedFunctions['Daily Functions'].Count)" -InformationAction Continue

        # Generate new navigation YAML
        Write-Information "`nGenerating navigation structure..." -InformationAction Continue
        $newNavLines = ConvertTo-NavigationYaml -CategorizedFunctions $categorizedFunctions

        # Update mkdocs.yml
        Write-Information "Updating mkdocs.yml..." -InformationAction Continue
        $updated = Update-MkDocsYaml -MkDocsPath $MkDocsPath -NewNavLines $newNavLines

        if ($updated) {
            Write-Information "Successfully updated mkdocs.yml navigation." -InformationAction Continue
            exit 0
        } else {
            Write-Error "Failed to update mkdocs.yml."
            exit 1
        }
    } catch {
        Write-Error "Error: $_"
        Write-Error $_.ScriptStackTrace
        exit 1
    }

    #endregion Main Script
}
