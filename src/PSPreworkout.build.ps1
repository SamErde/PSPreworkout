<#
.SYNOPSIS
    An Invoke-Build Build file.
.DESCRIPTION
    Build steps can include:
        - ValidateRequirements
        - ImportModuleManifest
        - Clean
        - Analyze
        - FormattingCheck
        - Test
        - DevCC
        - CreateHelpStart
        - Build
        - IntegrationTest
        - Archive
.EXAMPLE
    Invoke-Build

    This will perform the default build Add-BuildTasks: see below for the default Add-BuildTask execution
.EXAMPLE
    Invoke-Build -Add-BuildTask Analyze,Test

    This will perform only the Analyze and Test Add-BuildTasks.
.NOTES
    This build file by Catesta will pull in configurations from the "<module>.Settings.ps1" file as well, where users can more easily customize the build process if required.
    https://github.com/nightroman/Invoke-Build
    https://github.com/nightroman/Invoke-Build/wiki/Build-Scripts-Guidelines
    If using VSCode you can use the generated tasks.json to execute the various tasks in this build file.
        Ctrl + P | then type task (add space) - you will then be presented with a list of available tasks to run
    The 'InstallDependencies' Add-BuildTask isn't present here.
        Module dependencies are installed at a previous step in the pipeline.
        If your manifest has module dependencies include all required modules in your CI/CD bootstrap file:
            AWS - install_modules.ps1
            Azure - actions_bootstrap.ps1
            GitHub Actions - actions_bootstrap.ps1
            AppVeyor  - actions_bootstrap.ps1
#>

#Include: Settings
$ModuleName = [regex]::Match((Get-Item $BuildFile).Name, '^(.*)\.build\.ps1$').Groups[1].Value
. "./$ModuleName.Settings.ps1"

function Test-ManifestBool ($Path) {
    Get-ChildItem $Path | Test-ModuleManifest -ErrorAction SilentlyContinue | Out-Null; $?
}

#Default Build
$str = @()
$str = 'Clean', 'ValidateRequirements', 'ImportModuleManifest'
$str += 'FormattingCheck'
$str += 'Analyze', 'Test'
$str += 'CreateHelpStart'
$str2 = $str
$str2 += 'Build', 'Archive'
$str += 'Build', 'IntegrationTest', 'Archive'
Add-BuildTask -Name . -Jobs $str

#Local testing build process
Add-BuildTask TestLocal Clean, ImportModuleManifest, Analyze, Test

#Local help file creation process
Add-BuildTask HelpLocal Clean, ImportModuleManifest, CreateHelpStart

#Full build sans integration tests
Add-BuildTask BuildNoIntegration -Jobs $str2

# Pre-build variables to be used by other portions of the script
Enter-Build {
    $script:ModuleName = [regex]::Match((Get-Item $BuildFile).Name, '^(.*)\.build\.ps1$').Groups[1].Value

    # Identify other required paths
    $script:ModuleSourcePath = Join-Path -Path $BuildRoot -ChildPath $script:ModuleName
    $script:ModuleFiles = Join-Path -Path $script:ModuleSourcePath -ChildPath '*'

    $script:ModuleManifestFile = Join-Path -Path $script:ModuleSourcePath -ChildPath "$($script:ModuleName).psd1"

    $manifestInfo = Import-PowerShellDataFile -Path $script:ModuleManifestFile
    $script:ModuleVersion = $manifestInfo.ModuleVersion
    $script:ModuleDescription = $manifestInfo.Description
    $script:FunctionsToExport = $manifestInfo.FunctionsToExport

    $script:TestsPath = Join-Path -Path $BuildRoot -ChildPath 'Tests'
    $script:UnitTestsPath = Join-Path -Path $script:TestsPath -ChildPath 'Unit'
    $script:IntegrationTestsPath = Join-Path -Path $script:TestsPath -ChildPath 'Integration'

    $script:ArtifactsPath = Join-Path -Path $BuildRoot -ChildPath 'Artifacts'
    $script:ArchivePath = Join-Path -Path $BuildRoot -ChildPath 'Archive'

    $script:BuildModuleRootFile = Join-Path -Path $script:ArtifactsPath -ChildPath "$($script:ModuleName).psm1"

    # Ensure our builds fail until if below a minimum defined code test coverage threshold
    $script:coverageThreshold = 2 # Default 30

    [version]$script:MinPesterVersion = '5.2.2'
    [version]$script:MaxPesterVersion = '5.99.99'
    $script:testOutputFormat = 'NUnitXML'
} #Enter-Build

# Define headers as separator, task path, synopsis, and location, e.g. for Ctrl+Click in VSCode.
# Also change the default color to Green. If you need task start times, use `$Task.Started`.
Set-BuildHeader {
    param($Path)
    # separator line
    Write-Build DarkMagenta ('=' * 79)
    # default header + synopsis
    Write-Build DarkGray "Task $Path : $(Get-BuildSynopsis $Task)"
    # task location in a script
    Write-Build DarkGray "At $($Task.InvocationInfo.ScriptName):$($Task.InvocationInfo.ScriptLineNumber)"
    Write-Build Yellow "Manifest File: $script:ModuleManifestFile"
    Write-Build Yellow "Manifest Version: $($manifestInfo.ModuleVersion)"
} #Set-BuildHeader

# Define footers similar to default but change the color to DarkGray.
Set-BuildFooter {
    param($Path)
    Write-Build DarkGray "Done $Path, $($Task.Elapsed)"
    # # separator line
    # Write-Build Gray ('=' * 79)
} #Set-BuildFooter

#Synopsis: Validate system requirements are met
Add-BuildTask ValidateRequirements {
    # this setting comes from the *.Settings.ps1
    Write-Build White "      Verifying at least PowerShell $script:requiredPSVersion..."
    Assert-Build ($PSVersionTable.PSVersion -ge $script:requiredPSVersion) "At least Powershell $script:requiredPSVersion is required for this build to function properly"
    Write-Build Green '      ...Verification Complete!'
} #ValidateRequirements

# Updates the array for FunctionsToExport in the module manifest
# <https://github.com/techthoughts2/Catesta/issues/97>

# Synopsis: Update module manifest with public functions and aliases
Add-BuildTask UpdateManifest -Before TestModuleManifest {
    Write-Build White '      Updating module manifest with public functions and aliases...'

    # Get all public functions
    $publicFunctions = Get-ChildItem -Path "$script:ModuleSourcePath\Public\*.ps1" -ErrorAction SilentlyContinue | 
        ForEach-Object {
            $content = Get-Content -Path $_.FullName -Raw
            # Extract function name from 'function FunctionName {' pattern
            if ($content -match 'function\s+([a-zA-Z][\w-]*)\s*\{') {
                $matches[1]
            }
        } | Sort-Object

    if (-not $publicFunctions) {
        Write-Build Yellow '      No public functions found in Public folder.'
        return
    }

    Write-Build Gray "      Found $($publicFunctions.Count) public functions"

    # Get all aliases from public functions - improved detection
    $aliases = Get-ChildItem -Path "$script:ModuleSourcePath\Public\*.ps1" -ErrorAction SilentlyContinue | 
        ForEach-Object {
            # Read line by line to better understand context and avoid string literals
            $lines = Get-Content -Path $_.FullName
            $foundAliases = @()
            
            foreach ($line in $lines) {
                # Skip lines that are clearly in strings or variable assignments
                if ($line -match '^\s*#' -or $line -match '=.*\[Alias') {
                    continue
                }
                
                # Match [Alias(...)] attribute declarations
                if ($line -match '^\s*\[Alias\((.*?)\)\]') {
                    $aliasString = $matches[1]
                    # Split by comma and clean up each alias
                    $lineAliases = $aliasString -split ',' | ForEach-Object {
                        $cleaned = $_.Trim().Trim("'").Trim('"').Trim()
                        # Filter out variables, template placeholders, and empty strings
                        if ($cleaned -and $cleaned -notmatch '^\$' -and $cleaned -notmatch '__') {
                            $cleaned
                        }
                    } | Where-Object { $_ }
                    
                    $foundAliases += $lineAliases
                }
            }
            
            $foundAliases
        } | Sort-Object -Unique

    Write-Build Gray "      Found $($aliases.Count) unique aliases in public functions"

    # Read the manifest file
    $manifestPath = $script:ModuleManifestFile
    $manifestContent = Get-Content -Path $manifestPath -Raw
    
    # Update FunctionsToExport
    $functionsArray = ($publicFunctions | ForEach-Object { "'$_'" }) -join ",`n        "
    $functionsToExportPattern = '(?ms)(FunctionsToExport\s*=\s*@\().*?(\s*\))'
    
    # Build complete export list: functions first, then aliases that should be exported as functions
    $allExports = @($publicFunctions)
    if ($aliases) {
        $allExports += $aliases
    }
    $allExportsArray = ($allExports | Sort-Object -Unique | ForEach-Object { "'$_'" }) -join ",`n        "
    
    $newFunctionsToExport = "`$1`n        $allExportsArray`n    `$2"
    $manifestContent = $manifestContent -replace $functionsToExportPattern, $newFunctionsToExport

    # Update AliasesToExport
    if ($aliases) {
        $aliasesArray = ($aliases | ForEach-Object { "'$_'" }) -join ",`n        "
        $aliasesToExportPattern = '(?ms)(AliasesToExport\s*=\s*@\().*?(\s*\))'
        $newAliasesToExport = "`$1`n        $aliasesArray`n    `$2"
        $manifestContent = $manifestContent -replace $aliasesToExportPattern, $newAliasesToExport
    }

    # Write the updated manifest
    $manifestContent | Out-File -FilePath $manifestPath -Encoding utf8 -NoNewline

    Write-Build Green '      ...Module manifest updated successfully!'
}

# Synopsis: Import the current module manifest file for processing
Add-BuildTask TestModuleManifest -Before ImportModuleManifest {
    Write-Build White '      Running module manifest tests...'
    Assert-Build (Test-Path $script:ModuleManifestFile) 'Unable to locate the module manifest file.'
    Assert-Build (Test-ManifestBool -Path $script:ModuleManifestFile) 'Module Manifest test did not pass verification.'
    Write-Build Green '      ...Module Manifest Verification Complete!'
} #f5b33218-bde4-4028-b2a1-9c206f089503

# Synopsis: Load the module project
Add-BuildTask ImportModuleManifest {
    Write-Build White '      Attempting to load the project module.'
    try {
        Import-Module $script:ModuleManifestFile -Force -PassThru -ErrorAction Stop
    } catch {
        Write-Build Red "      ...$_`n"
        throw 'Unable to load the project module.'
    }
    Write-Build Green "      ...$script:ModuleName imported successfully"
}

#Synopsis: Clean and reset Artifacts/Archive Directory
Add-BuildTask Clean {
    Write-Build White '      Clean up our Artifacts/Archive directory...'

    $null = Remove-Item $script:ArtifactsPath -Force -Recurse -ErrorAction 0
    $null = New-Item $script:ArtifactsPath -ItemType:Directory
    $null = Remove-Item $script:ArchivePath -Force -Recurse -ErrorAction 0
    $null = New-Item $script:ArchivePath -ItemType:Directory

    Write-Build Green '      ...Clean Complete!'
} #Clean

#Synopsis: Invokes PSScriptAnalyzer against the Module source path
Add-BuildTask Analyze {

    $scriptAnalyzerParams = @{
        Path        = $script:ModuleSourcePath
        Setting     = 'PSScriptAnalyzerSettings.psd1'
        ExcludeRule = @('PSUseDeclaredVarsMoreThanAssignments', 'PSAvoidUsingWriteHost')
        Recurse     = $true
        Verbose     = $false
    }

    Write-Build White '      Performing Module ScriptAnalyzer checks...'
    $scriptAnalyzerResults = Invoke-ScriptAnalyzer @scriptAnalyzerParams

    if ($scriptAnalyzerResults) {
        $scriptAnalyzerResults | Format-Table
        throw '      One or more PSScriptAnalyzer errors/warnings where found.'
    } else {
        Write-Build Green '      ...Module Analyze Complete!'
    }
} #Analyze

#Synopsis: Invokes Script Analyzer against the Tests path if it exists
Add-BuildTask AnalyzeTests -After Analyze {
    if (Test-Path -Path $script:TestsPath) {

        $scriptAnalyzerParams = @{
            Path        = $script:TestsPath
            Setting     = 'PSScriptAnalyzerSettings.psd1'
            ExcludeRule = @('PSUseDeclaredVarsMoreThanAssignments')
            Recurse     = $true
            Verbose     = $false
        }

        Write-Build White '      Performing Test ScriptAnalyzer checks...'
        $scriptAnalyzerResults = Invoke-ScriptAnalyzer @scriptAnalyzerParams

        if ($scriptAnalyzerResults) {
            $scriptAnalyzerResults | Format-Table
            throw '      One or more PSScriptAnalyzer errors/warnings where found.'
        } else {
            Write-Build Green '      ...Test Analyze Complete!'
        }
    }
} #AnalyzeTests

#Synopsis: Analyze scripts to verify if they adhere to desired coding format (Stroustrup / OTBS / Allman)
Add-BuildTask FormattingCheck {

    $scriptAnalyzerParams = @{
        Setting     = 'CodeFormattingOTBS'
        ExcludeRule = 'PSUseConsistentWhitespace'
        Recurse     = $true
        Verbose     = $false
    }

    Write-Build White '      Performing script formatting checks...'
    $scriptAnalyzerResults = Get-ChildItem -Path $script:ModuleSourcePath -Exclude '*.psd1' | Invoke-ScriptAnalyzer @scriptAnalyzerParams

    if ($scriptAnalyzerResults) {
        $scriptAnalyzerResults | Format-Table
        throw '      PSScriptAnalyzer code formatting check did not adhere to {0} standards' -f $scriptAnalyzerParams.Setting
    } else {
        Write-Build Green '      ...Formatting Analyze Complete!'
    }
} #FormattingCheck

#Synopsis: Invokes all Pester Unit Tests in the Tests\Unit folder (if it exists)
Add-BuildTask Test {

    Write-Build White "      Importing desired Pester version. Min: $script:MinPesterVersion Max: $script:MaxPesterVersion"
    Remove-Module -Name Pester -Force -ErrorAction SilentlyContinue # there are instances where some containers have Pester already in the session
    Import-Module -Name Pester -MinimumVersion $script:MinPesterVersion -MaximumVersion $script:MaxPesterVersion -ErrorAction 'Stop'

    $codeCovPath = "$script:ArtifactsPath\ccReport\"
    $testOutPutPath = "$script:ArtifactsPath\testOutput\"
    if (-not(Test-Path $codeCovPath)) {
        New-Item -Path $codeCovPath -ItemType Directory | Out-Null
    }
    if (-not(Test-Path $testOutPutPath)) {
        New-Item -Path $testOutPutPath -ItemType Directory | Out-Null
    }
    if (Test-Path -Path $script:UnitTestsPath) {
        $pesterConfiguration = New-PesterConfiguration
        $pesterConfiguration.run.Path = $script:UnitTestsPath
        $pesterConfiguration.Run.PassThru = $true
        $pesterConfiguration.Run.Exit = $false
        $pesterConfiguration.CodeCoverage.Enabled = $true
        # Fixed by inserting "\src" in front of \$ModuleName
        $pesterConfiguration.CodeCoverage.Path = "..\..\..\src\$ModuleName\*\*.ps1"
        $pesterConfiguration.CodeCoverage.CoveragePercentTarget = $script:coverageThreshold
        $pesterConfiguration.CodeCoverage.OutputPath = "$codeCovPath\CodeCoverage.xml"
        $pesterConfiguration.CodeCoverage.OutputFormat = 'JaCoCo'
        $pesterConfiguration.TestResult.Enabled = $true
        $pesterConfiguration.TestResult.OutputPath = "$testOutPutPath\PesterTests.xml"
        $pesterConfiguration.TestResult.OutputFormat = $script:testOutputFormat
        $pesterConfiguration.Output.Verbosity = 'Detailed'

        Write-Build White '      Performing Pester Unit Tests...'
        # Publish Test Results
        $testResults = Invoke-Pester -Configuration $pesterConfiguration

        # This will output a nice json for each failed test (if running in CodeBuild)
        if ($env:CODEBUILD_BUILD_ARN) {
            $testResults.TestResult | ForEach-Object {
                if ($_.Result -ne 'Passed') {
                    ConvertTo-Json -InputObject $_ -Compress
                }
            }
        }

        $numberFails = $testResults.FailedCount
        Assert-Build($numberFails -eq 0) ('Failed "{0}" unit tests.' -f $numberFails)

        Write-Build Gray ('      ...CODE COVERAGE - CommandsExecutedCount: {0}' -f $testResults.CodeCoverage.CommandsExecutedCount)
        Write-Build Gray ('      ...CODE COVERAGE - CommandsAnalyzedCount: {0}' -f $testResults.CodeCoverage.CommandsAnalyzedCount)

        if ($testResults.CodeCoverage.NumberOfCommandsExecuted -ne 0) {
            $coveragePercent = '{0:N2}' -f ($testResults.CodeCoverage.CommandsExecutedCount / $testResults.CodeCoverage.CommandsAnalyzedCount * 100)

            if ([Int]$coveragePercent -lt $coverageThreshold) {
                throw ('Failed to meet code coverage threshold of {0}% with only {1}% coverage' -f $coverageThreshold, $coveragePercent)
            } else {
                Write-Build Cyan "      $('Covered {0}% of {1} analyzed commands in {2} files.' -f $coveragePercent,$testResults.CodeCoverage.CommandsAnalyzedCount,$testResults.CodeCoverage.FilesAnalyzedCount)"
                Write-Build Green '      ...Pester Unit Tests Complete!'
            }
        } else {
            # account for new module build condition
            Write-Build Yellow '      Code coverage check skipped. No commands to execute...'
        }

    }
} #Test

#Synopsis: Used primarily during active development to generate xml file to graphically display code coverage in VSCode using Coverage Gutters
Add-BuildTask DevCC {
    Write-Build White '      Generating code coverage report at root...'
    Write-Build White "      Importing desired Pester version. Min: $script:MinPesterVersion Max: $script:MaxPesterVersion"
    Remove-Module -Name Pester -Force -ErrorAction SilentlyContinue # there are instances where some containers have Pester already in the session
    Import-Module -Name Pester -MinimumVersion $script:MinPesterVersion -MaximumVersion $script:MaxPesterVersion -ErrorAction 'Stop'
    $pesterConfiguration = New-PesterConfiguration
    $pesterConfiguration.run.Path = $script:UnitTestsPath
    $pesterConfiguration.CodeCoverage.Enabled = $true
    $pesterConfiguration.CodeCoverage.Path = "$PSScriptRoot\$ModuleName\*\*.ps1"
    $pesterConfiguration.CodeCoverage.CoveragePercentTarget = $script:coverageThreshold
    $pesterConfiguration.CodeCoverage.OutputPath = '..\..\..\cov.xml'
    $pesterConfiguration.CodeCoverage.OutputFormat = 'CoverageGutters'

    Invoke-Pester -Configuration $pesterConfiguration
    Write-Build Green '      ...Code Coverage report generated!'
} #DevCC

# Synopsis: Build help for module
Add-BuildTask CreateHelpStart {
    Write-Build White '      Performing all help related actions.'

    Write-Build Gray '           Importing platyPS v0.12.0 ...'
    Import-Module platyPS -RequiredVersion 0.12.0 -Force -ErrorAction Stop
    Write-Build Gray '           ...platyPS imported successfully.'
} #CreateHelpStart

# Synopsis: Build markdown help files for module and fail if help information is missing
Add-BuildTask CreateMarkdownHelp -After CreateHelpStart {
    $ModulePage = "$script:ArtifactsPath\docs\$($ModuleName).md"

    $markdownParams = @{
        Module         = $ModuleName
        OutputFolder   = "$script:ArtifactsPath\docs\"
        Force          = $true
        WithModulePage = $true
        Locale         = 'en-US'
        FwLink         = 'NA'
        HelpVersion    = $script:ModuleVersion
    }

    Write-Build Gray '           Generating markdown files...'
    $null = New-MarkdownHelp @markdownParams
    Write-Build Gray '           ...Markdown generation completed.'

    Write-Build Gray '           Replacing markdown elements...'
    # Replace multi-line EXAMPLES
    $OutputDir = "$script:ArtifactsPath\docs\"
    $OutputDir | Get-ChildItem -File | ForEach-Object {
        # fix formatting in multiline examples
        $content = Get-Content $_.FullName -Raw
        $newContent = $content -replace '(## EXAMPLE [^`]+?```\r\n[^`\r\n]+?\r\n)(```\r\n\r\n)([^#]+?\r\n)(\r\n)([^#]+)(#)', '$1$3$2$4$5$6'
        if ($newContent -ne $content) {
            Set-Content -Path $_.FullName -Value $newContent -Force
        }
    }
    # Replace each missing element we need for a proper generic module page .md file
    $ModulePageFileContent = Get-Content -Raw $ModulePage
    $ModulePageFileContent = $ModulePageFileContent -replace '{{Manually Enter Description Here}}', $script:ModuleDescription
    $script:FunctionsToExport | ForEach-Object {
        Write-Build DarkGray "             Updating definition for the following function: $($_)"
        $TextToReplace = "{{Manually Enter $($_) Description Here}}"
        $ReplacementText = (Get-Help -Detailed $_).Synopsis
        $ModulePageFileContent = $ModulePageFileContent -replace $TextToReplace, $ReplacementText
    }

    $ModulePageFileContent | Out-File $ModulePage -Force -Encoding:utf8
    Write-Build Gray '           ...Markdown replacements complete.'

    Write-Build Gray '           Verifying GUID...'
    $MissingGUID = Select-String -Path "$script:ArtifactsPath\docs\*.md" -Pattern '(00000000-0000-0000-0000-000000000000)'
    if ($MissingGUID.Count -gt 0) {
        Write-Build Yellow '             The documentation that got generated resulted in a generic GUID. Check the GUID entry of your module manifest.'
        throw 'Missing GUID. Please review and rebuild.'
    }

    Write-Build Gray '           Evaluating if running 7.4.0 or higher...'
    # https://github.com/PowerShell/platyPS/issues/595
    if ($PSVersionTable.PSVersion -ge [version]'7.4.0') {
        Write-Build Gray '               Performing Markdown repair'
        # dot source markdown repair
        . $BuildRoot\MarkdownRepair.ps1
        $OutputDir | Get-ChildItem -File | ForEach-Object {
            Repair-PlatyPSMarkdown -Path $_.FullName
        }
    }

    Write-Build Gray '           Checking for missing documentation in md files...'
    $MissingDocumentation = Select-String -Path "$script:ArtifactsPath\docs\*.md" -Pattern '({{.*}})'
    if ($MissingDocumentation.Count -gt 0) {
        Write-Build Yellow '             The documentation that got generated resulted in missing sections which should be filled out.'
        Write-Build Yellow '             Please review the following sections in your comment based help, fill out missing information and rerun this build:'
        Write-Build Yellow '             (Note: This can happen if the .EXTERNALHELP CBH is defined for a function before running this build.)'
        Write-Build Yellow "             Path of files with issues: $script:ArtifactsPath\docs\"
        $MissingDocumentation | Select-Object FileName, LineNumber, Line | Format-Table -AutoSize
        throw 'Missing documentation. Please review and rebuild.'
    }

    Write-Build Gray '           Checking for missing SYNOPSIS in md files...'
    $fSynopsisOutput = @()
    $synopsisEval = Select-String -Path "$script:ArtifactsPath\docs\*.md" -Pattern '^## SYNOPSIS$' -Context 0, 1
    $synopsisEval | ForEach-Object {
        $chAC = $_.Context.DisplayPostContext.ToCharArray()
        if ($null -eq $chAC) {
            $fSynopsisOutput += $_.FileName
        }
    }
    if ($fSynopsisOutput) {
        Write-Build Yellow '             The following files are missing SYNOPSIS:'
        $fSynopsisOutput
        throw 'SYNOPSIS information missing. Please review.'
    }

    Write-Build Gray '           ...Markdown generation complete.'
} #CreateMarkdownHelp

# Synopsis: Build the external xml help file from markdown help files with PlatyPS
Add-BuildTask CreateExternalHelp -After CreateMarkdownHelp {
    Write-Build Gray '           Creating external xml help file...'
    $null = New-ExternalHelp "$script:ArtifactsPath\docs" -OutputPath "$script:ArtifactsPath\en-US\" -Force
    Write-Build Gray '           ...External xml help file created!'
} #CreateExternalHelp

Add-BuildTask CreateHelpComplete -After CreateExternalHelp {
    Write-Build Green '      ...CreateHelp Complete!'
} #CreateHelpStart

# Synopsis: Replace comment based help (CBH) with external help in all public functions for this project
Add-BuildTask UpdateCBH -After AssetCopy {
    $ExternalHelp = @"
<#
.EXTERNALHELP $($ModuleName)-help.xml
#>
"@

    $CBHPattern = '(?ms)(\<#.*\.SYNOPSIS.*?#>)'
    Get-ChildItem -Path "$script:ArtifactsPath\Public\*.ps1" -File | ForEach-Object {
        $FormattedOutFile = $_.FullName
        Write-Output "      Replacing CBH in file: $($FormattedOutFile)"
        $UpdatedFile = (Get-Content $FormattedOutFile -Raw) -replace $CBHPattern, $ExternalHelp
        $UpdatedFile | Out-File -FilePath $FormattedOutFile -Force -Encoding:utf8
    }
} #UpdateCBH

# Synopsis: Copies module assets to Artifacts folder
Add-BuildTask AssetCopy -Before Build {
    Write-Build Gray '        Copying assets to Artifacts...'
    Copy-Item -Path "$script:ModuleSourcePath\*" -Destination $script:ArtifactsPath -Exclude *.psd1, *.psm1 -Recurse -ErrorAction Stop
    Write-Build Gray '        ...Assets copy complete.'
} #AssetCopy

# Synopsis: Builds the Module to the Artifacts folder
Add-BuildTask Build {
    Write-Build White '      Performing Module Build'

    Write-Build Gray '        Copying manifest file to Artifacts...'
    Copy-Item -Path $script:ModuleManifestFile -Destination $script:ArtifactsPath -Recurse -ErrorAction Stop
    #Copy-Item -Path $script:ModuleSourcePath\bin -Destination $script:ArtifactsPath -Recurse -ErrorAction Stop
    Write-Build Gray '        ...manifest copy complete.'

    Write-Build Gray '        Merging Public and Private functions to one module file...'
    $scriptContent = [System.Text.StringBuilder]::new()
    $powerShellScripts = Get-ChildItem -Path $script:ArtifactsPath -Recurse | Where-Object { $_.Name -match '^*.ps1$' }
    foreach ($script in $powerShellScripts) {
        $null = $scriptContent.Append((Get-Content -Path $script.FullName -Raw))
        $null = $scriptContent.AppendLine('')
        $null = $scriptContent.AppendLine('')
        # This is adding extra blank lines.
    }
    $scriptContent.ToString() | Out-File -FilePath $script:BuildModuleRootFile -Encoding:utf8 -Force
    # Add here: Invoke-Formatter -ScriptDefinition $script:BuildModuleRootFile -ErrorAction Stop
    Write-Build Gray '        ...Module creation complete.'

    Write-Build Gray '        Cleaning up leftover artifacts...'
    #cleanup artifacts that are no longer required
    if (Test-Path "$script:ArtifactsPath\Public") {
        Remove-Item "$script:ArtifactsPath\Public" -Recurse -Force -ErrorAction Stop
    }
    if (Test-Path "$script:ArtifactsPath\Private") {
        Remove-Item "$script:ArtifactsPath\Private" -Recurse -Force -ErrorAction Stop
    }
    if (Test-Path "$script:ArtifactsPath\Imports.ps1") {
        Remove-Item "$script:ArtifactsPath\Imports.ps1" -Force -ErrorAction SilentlyContinue
    }

    if (Test-Path "$script:ArtifactsPath\docs") {
        #here we update the parent level docs. If you would prefer not to update them, comment out this section.
        Write-Build Gray '        Overwriting docs output...'
        if (-not (Test-Path '..\docs\')) {
            New-Item -Path '..\docs\' -ItemType Directory -Force | Out-Null
        }
        Move-Item "$script:ArtifactsPath\docs\*.md" -Destination '..\docs\' -Force
        Remove-Item "$script:ArtifactsPath\docs" -Recurse -Force -ErrorAction Stop
        Write-Build Gray '        ...Docs output completed.'
    }

    Write-Build Green '      ...Build Complete!'
} #Build

#Synopsis: Invokes all Pester Integration Tests in the Tests\Integration folder (if it exists)
Add-BuildTask IntegrationTest {
    if (Test-Path -Path $script:IntegrationTestsPath) {
        Write-Build White "      Importing desired Pester version. Min: $script:MinPesterVersion Max: $script:MaxPesterVersion"
        Remove-Module -Name Pester -Force -ErrorAction SilentlyContinue # there are instances where some containers have Pester already in the session
        Import-Module -Name Pester -MinimumVersion $script:MinPesterVersion -MaximumVersion $script:MaxPesterVersion -ErrorAction 'Stop'

        Write-Build White "      Performing Pester Integration Tests in $($invokePesterParams.path)"

        $pesterConfiguration = New-PesterConfiguration
        $pesterConfiguration.run.Path = $script:IntegrationTestsPath
        $pesterConfiguration.Run.PassThru = $true
        $pesterConfiguration.Run.Exit = $false
        $pesterConfiguration.CodeCoverage.Enabled = $false
        $pesterConfiguration.TestResult.Enabled = $false
        $pesterConfiguration.Output.Verbosity = 'Detailed'

        $testResults = Invoke-Pester -Configuration $pesterConfiguration
        # This will output a nice json for each failed test (if running in CodeBuild)
        if ($env:CODEBUILD_BUILD_ARN) {
            $testResults.TestResult | ForEach-Object {
                if ($_.Result -ne 'Passed') {
                    ConvertTo-Json -InputObject $_ -Compress
                }
            }
        }

        $numberFails = $testResults.FailedCount
        Assert-Build($numberFails -eq 0) ('Failed "{0}" unit tests.' -f $numberFails)
        Write-Build Green '      ...Pester Integration Tests Complete!'
    }
} #IntegrationTest

#Synopsis: Creates an archive of the built Module
Add-BuildTask Archive {
    Write-Build White '        Performing Archive...'

    $archivePath = Join-Path -Path $BuildRoot -ChildPath 'Archive'
    if (Test-Path -Path $archivePath) {
        $null = Remove-Item -Path $archivePath -Recurse -Force
    }

    $null = New-Item -Path $archivePath -ItemType Directory -Force

    $zipFileNameArchive = '{0}_{1}_{2}.{3}.zip' -f $script:ModuleName, $script:ModuleVersion, ([DateTime]::UtcNow.ToString('yyyyMMdd')), ([DateTime]::UtcNow.ToString('hhmmss'))
    $zipFileArchive = Join-Path -Path $archivePath -ChildPath $zipFileNameArchive


    if ($PSEdition -eq 'Desktop' -or $IsWindows) {
        Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
    }
    [System.IO.Compression.ZipFile]::CreateFromDirectory($script:ArtifactsPath, $zipFileArchive)
    Write-Build Green '        ...Archive Complete!'


    Write-Build White '        Creating release artifacts...'
    $releasePath = Join-Path -Path $BuildRoot -ChildPath 'Release' ; [void]$releasePath
    #$zipFileNameRelease = '{0}.zip' -f $script:ModuleName
    #$zipFileRelease = Join-Path -Path $script:ArtifactsPath -ChildPath $zipFileNameRelease

    #region SDE
    #$ReleaseFolder = Join-Path -Path $PSScriptRoot -ChildPath '..\Release'
    #$ArtifactsFolder = Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath 'Artifacts')
    #$ExternalHelpFolder = Get-ChildItem -Directory -Path (Join-Path -Path $PSScriptRoot -ChildPath '..\docs') | Select-Object -ExpandProperty FullName

    #Copy-Item -Path $ArtifactsFolder\* -Destination "$ReleaseFolder" -Recurse -Exclude @('ccReport', 'en-US', 'testOutput', 'Release', 'PSPreworkout.zip') -Force
    #Copy-Item -Path $ExternalHelpFolder -Destination $ReleaseFolder -Recurse -Force
    #[System.IO.Compression.ZipFile]::CreateFromDirectory($ReleaseFolder, $zipFileRelease)
    Write-Build Green '        ...Archive Complete!'
    #endregion SDE
} #Archive
