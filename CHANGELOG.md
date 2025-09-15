<!-- markdownlint-disable MD004 -->
<!-- markdownlint-disable MD024 -->
<!-- markdownlint-disable MD034 -->
<!-- markdownlint-disable MD013 -->
# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
<!-- Show the history of all changes since the last release. -->

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/latest...HEAD)

---

## [2.0.0-preview] - 2025-09-15

### Removed

- Removed the redundant `New-Credential` function, which behaves the same as `Get-Credential`.

### Added

- **Telemetry System**: Added anonymous usage analytics to help improve the module.
  - New `Write-PSPreworkoutTelemetry` private function for statistics about how often functions are used.
  - Added usage statistics for all 24 functions except for `Get-EnvironmentVariable`.
  - Tracks function usage, parameter names (not values), PowerShell version details, and OS.
  - Privacy-focused design: no personally identifiable information or parameter values are collected.
  - Data sent to PostHog analytics service to understand usage patterns and guide development priorities.

## [1.9.11] - 2025-07-31

This release fixes a bug in `Get-ModulesWithUpdate`.

### Fixed

- Remove 'PSResourceInfo' from the OutputType property because of a bootstrap condition it creates if the Microsoft.PowerShell.PSResource module has not already been imported.

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.9.10...v1.9.11)

## [1.9.10] - 2025-07-29

This release includes a major refactor of `Get-ModulesWithUpdate` to better handle prerelease versions and improve performance.

### Changed

- Use Microsoft.PowerShell.PSResourceGet instead of PowerShellGet.
- Fix detection of prerelease versions that include a numerical suffix.
- Detect 'alpha' prerelease versions.
- Improve cross-platform support.
- Support update checks from the module's original source repository.
- Add PassThru parameter support.

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.9.7...v1.9.10)

## [1.9.7] - 2025-07-15

### Changed

* Added and improved unit tests
* Cleaned up unnecessary code
* Improved help content
* Clean up files and workflows
* Sync module, change log, and release version numbers

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.9.6...v1.9.7)

## [1.9.6] - 2025-07-12

In this release, @JakeHildreth contributed a slick new utility function for analyzing hashtable data types. Thanks, Jake! 💛👊

Some minor improvements were also made to other functions and documentation.

### Added

* **Get-HashtableValueType** - New function to inspect and analyze the data types of hashtable values, by @JakeHildreth.
  * Supports pipeline input for seamless integration with existing workflows, by @JakeHildreth.
  * Returns custom formatted `System.Reflection.TypeInfo` objects, by @SamErde.
  * Supports filtering to specific hashtable keys with the `-Key` parameter, by @SamErde.
  * Includes intelligent tab completion for the `-Key` parameter, by @SamErde.

### Enhanced

* **Test-IsAdmin** - Enhanced test for elevated (admin/root) privileges on Linux and macOS platforms, by @SamErde.

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.9.5...v1.9.6)

## [1.9.5] - 2025-07-02

This maintenance release fixes a syntax error in the module manifest, adds error handling to more operations, and enhances cross-platform compatibility.

### Fixed

* Missing comma in FunctionsToExport array in module manifest that could prevent proper module loading

### Enhanced

* Added comprehensive error handling for file operations, registry operations, and external command
* Improved cross-platform compatibility
* Enhanced extraction of default name value from Git config or currently logged on user

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.9.4...v1.9.5)

## [1.9.4] - 2025-06-23

This release fixes a bug in `Get-ModulesWithUpdate` in which it failed to check some prerelease module versions.

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.9.3...v1.9.4)

## [1.9.3] - 2025-06-09

This release fixes a problem in the `New-ScriptFromTemplate` function that occured when the template was moved from the Public folder to the Resources folder.

### Fixed

* Issue #81 in New-FunctionFromTemplate by @SamErde

### Added

* PSScriptAnalyzer script validation for `New-ScriptFromTemplate` by @SamErde in [#82](https://github.com/SamErde/PSPreworkout/pull/82)

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.9.2...v1.9.3)

## [1.9.2] - 2025-06-03

### Fixed

This release fixes two code quality issues that caused `New-Credential` and `Get-ModulesWithUpdate` to return generic objects instead of the desired object types.

* Get-ModulesWithUpdate by @SamErde in [#78](https://github.com/SamErde/PSPreworkout/pull/78)
* New-Credential by @SamErde in [#77](https://github.com/SamErde/PSPreworkout/pull/78)

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.9.0...v1.9.2)

## [1.9.0] - 2025-06-03

### Added

This release adds a new function with custom formatting to show updates that available for installed modules.

* Get-ModulesWithUpdate by @SamErde in [#74](https://github.com/SamErde/PSPreworkout/pull/74)

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.8.3...v1.9.0)

## [1.8.3] - 2025-02-26

### Fixed

* Fixed an issue that resulted in the default parameter set returning no output in `Get-CommandHistory`.
* Added missing AliasesToExport value for 'gch' in manifest.
* Fixed string type declaration on array for `Get-CommandHistory`.
* Fixed an issue that was preventing PSPreworkout from being imported in Windows PowerShell.

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.8.0...v1.8.3)

## [1.8.0] - 2025-02-24

This release adds improved error handling to several functions, a new `Get-CommandHistory` function, and improvements to project workflows.

### Changed

* Improved error handling by @SamErde in https://github.com/SamErde/PSPreworkout/pull/63

### Added

* Get-CommandHistory by @SamErde in https://github.com/SamErde/PSPreworkout/pull/68
* Build script now creates a new release artifact.
* New Pester tests.

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.7.2...v1.8.0)

## [1.7.2] - 2025-02-19

### Fixed

- Add better error handling in `Install-CommandNotFoundUtility`.
- Fix bug in `Install-CommandNotFoundUtility`.

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.7.1...v1.7.2)

## [1.7.1] - 2025-01-31

### Changed

- Move inline script template from `New-ScriptFromTemplate` to separate `ScriptTemplate.txt` file.
- Add `ScriptTemplate.txt` to module manifest.
- Repository workflow and project scaffolding improvements.
- Enable first basic integration test (more to come).

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.6.0...v1.7.1)

## [1.6.0] - 2024-11-15

This release is focused on enhancements that make the existing functions more usable and flexible.

### Changed

- Add **Depth** parameter to `Out-JsonFile` to specify how deeply to serialize objects as JSON.
- Set WinGet as the default terminal and console application in `Initialize-PSEnvironmentConfiguration`.

### Added

- Add `Set-DefaultTerminal` function for Windows.

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.6.0...v1.5.0)

## [1.5.0] - 2024-11-04

This release is focused on enhancements that make the existing functions more usable and flexible. The main changes are refactoring Get-EnvironmentVariable and Out-JsonFile.

### Changed

- Improve `Get-EnvironmentVariable`. Return rich objects to pipeline and test more usage scenarios.
- Remove requirement for ".json" extension in `Out-JsonFile`.
- Accept input from pipeline in `Out-JsonFile`.
- Ensure file is created in file system provider with `Out-JsonFile`.
- Remove **GridView** parameters from `Get-TypeAccelerator` to give user control of output and display.

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.5.0...v1.4.9)

## [1.4.9] - 2024-10-25

### Fixed

- Fix [#22](https://github.com/SamErde/PSPreworkout/issues/22) in `Edit-WinGetSettingsFile` by temporarily removing the **EditorPath** parameter. It will be back! (@SamErde, @JDHITSolutions)

### Added

- Add basic support for DNF on Linux to `Update-AllTheThings`. (@x1101)

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.4.9...v1.4.8)

## [1.4.8] - 2024-10-24

### Fixed

- Fix [#26](https://github.com/SamErde/PSPreworkout/issues/26) Windows/Linux detection in `Update-AllTheThings`. (@x1101)

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.4.8...v1.4.7)

## [1.4.7] - 2024-10-23

### Changed

- Fix HelpUri to open help pages to each specific function when `-Online` help is requested.

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.4.7...v1.4.6)

## [1.4.6] - 2024-10-22

### Added

- Add updatable and online (external) help.

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.4.6...v1.4.3)

## [1.4.3] - 2024-10-16

### Fixed

- Fix object creation example for comment-based help in `Show-WithoutEmptyProperty`

*Full Changelog*: [v1.4.2...v1.4.3](https://github.com/SamErde/PSPreworkout/compare/v1.4.2...v1.4.3)

## [1.4.2] - 2024-10-15

### Changed

- Refactor `Show-WithoutEmptyProperty` and test with more examples
- Enhance `Out-JsonFile` with better validation and provider handling

*Full Changelog*: [v1.4.1...v1.4.2](https://github.com/SamErde/PSPreworkout/compare/v1.4.1...v1.4.2)

## [1.4.1] - 2024-10-14

### Fixed

- Fix [#16](https://github.com/SamErde/PSPreworkout/issues/16)
- Fix [#15](https://github.com/SamErde/PSPreworkout/issues/15)

*Full Changelog*: [v1.4.0...v1.4.1](https://github.com/SamErde/PSPreworkout/compare/v1.4.0...v1.4.1)

## [1.4.0] - 2024-10-14

### Added

- Add `Install-CommandNotFoundUtility`
- Add preferred `EditorPath` parameter to `Edit-WinGetSettingsFile`

### Fixed

- Fix download links for `Get-PowerShellPortable`
- Optimize `Get-PowerShellPortable` version check and download

*Full Changelog*: [v1.3.1...v1.4.0](https://github.com/SamErde/PSPreworkout/compare/v1.3.1...v1.4.0)

## [1.3.1] - 2024-10-10

### Added

- Add `Edit-PSReadLineHistoryFile`
- Add `Out-JsonFile`
- Add `Show-WithoutEmptyProperty`

### Fixed

- Fix broken build output due to corrupt formatter 🤷‍♂️
- Comment out incomplete parameters in `Initialize-PSEnvironmentConfiguration`
- Remove `-Force` on module install script block for `Initialize-PSEnvironmentConfiguration`

### Removed

- Remove user installation of PowerShell, which no longer provides user installation packages after 7.2.6

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.3.1...v1.2.5)

## [1.2.5] - 2024-09-16

### Changed

- Set ~/Downloads as the default download location for all OSes

### Fixed

- Fix some minor errors in path processing

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.2.5...v1.2.4)

## [1.2.4] - 2024-09-13

### Fixed

- Fix extraction of PowerShell .tar.gz file on macOS
- Fix references to location of the extracted PowerShell files

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.2.4...v1.2.2)

## [1.2.2] - 2024-09-13

### Added

- Add `Get-PowerShellPortable` - a function to download and extract a ZIP file of the latest release of PowerShell, which can be run without installing.
- Add some default PowerShell preferences to `Initialize-PSEnvironmentConfiguration`
- Add PSReadLine preferences and history handler to `Initialize-PSEnvironmentConfiguration`

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.2.2...v1.1.2)

## [1.1.2] - 2024-09-12

### Changed

- Get Author name from the currently logged-in user profile (if Windows) in `New-ScriptFromTemplate`
- Add parameter validation in `New-ScriptFromTemplate`

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v1.1.2...v1.1.1)

## [1.1.0] - 2024-09-11

### Changed

- Use singular nouns for Get-Types\TypeAccelerators\Assemblies
- Don't show grid or formatted view in `Get-LoadedAssembly`. Use `Show` function to present objects.
- Rename `Edit-WinGetSettings` to `Edit-WinGetSettingsFile`
- Use direct reference to WinGet settings file path instead of Get-WinGetSettings.
- Rename `Initialize-Configuration` to `Initialize-PSEnvironmentConfiguration`

### Added

- Add `Show-LoadedAssembly`
- Add `Set-ConsoleFont`

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v0.4.1...v1.1.1)

## [0.4.1] - 2024-09-09

### Changed

- Export aliases when importing module

[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/v0.3.2...v0.4.1)

## [0.3.2] - 2024-09-06

### Changed

- Temporarily exclude Chocolatey from the default execution of `Update-AllTheThings`
- Improve server and OS detection in `Update-AllTheThings`

### Added

- Add `Install-WinGet`
- Add `Edit-WinGetSettings`
- Add `Initialize-Configuration`

*Initial release.*

[Unreleased]: https://github.com/SamErde/PSPreworkout/compare/latest...HEAD
[0.3.2]: https://github.com/SamErde/PSPreworkout/tag/v0.3.2
[0.4.1]: https://github.com/SamErde/PSPreworkout/tag/v0.4.1
[1.1.0]: https://github.com/SamErde/PSPreworkout/tag/v1.1.0
[1.1.2]: https://github.com/SamErde/PSPreworkout/tag/v1.1.2
[1.2.2]: https://github.com/SamErde/PSPreworkout/tag/v1.2.2
[1.2.4]: https://github.com/SamErde/PSPreworkout/tag/v1.2.4
[1.2.5]: https://github.com/SamErde/PSPreworkout/tag/v1.2.5
[1.3.1]: https://github.com/SamErde/PSPreworkout/tag/v1.3.1
[1.4.0]: https://github.com/SamErde/PSPreworkout/tag/v1.4.0
[1.4.1]: https://github.com/SamErde/PSPreworkout/tag/v1.4.1
[1.4.2]: https://github.com/SamErde/PSPreworkout/tag/v1.4.2
[1.4.3]: https://github.com/SamErde/PSPreworkout/tag/v1.4.3
[1.4.6]: https://github.com/SamErde/PSPreworkout/tag/v1.4.6
[1.4.7]: https://github.com/SamErde/PSPreworkout/tag/v1.4.7
[1.4.8]: https://github.com/SamErde/PSPreworkout/tag/v1.4.8
[1.4.9]: https://github.com/SamErde/PSPreworkout/tag/v1.4.9
[1.5.0]: https://github.com/SamErde/PSPreworkout/tag/v1.5.0
[1.6.0]: https://github.com/SamErde/PSPreworkout/tag/v1.6.0
[1.7.1]: https://github.com/SamErde/PSPreworkout/tag/v1.7.1
[1.7.2]: https://github.com/SamErde/PSPreworkout/tag/v1.7.2
[1.8.0]: https://github.com/SamErde/PSPreworkout/tag/v1.8.0
[1.8.3]: https://github.com/SamErde/PSPreworkout/tag/v1.8.3
[1.9.0]: https://github.com/SamErde/PSPreworkout/tag/v1.9.0
[1.9.2]: https://github.com/SamErde/PSPreworkout/tag/v1.9.2
[1.9.3]: https://github.com/SamErde/PSPreworkout/tag/v1.9.3
[1.9.4]: https://github.com/SamErde/PSPreworkout/tag/v1.9.4
[1.9.5]: https://github.com/SamErde/PSPreworkout/tag/v1.9.5
[1.9.6]: https://github.com/SamErde/PSPreworkout/tag/v1.9.6
[1.9.7]: https://github.com/SamErde/PSPreworkout/tag/v1.9.7
[1.9.10]: https://github.com/SamErde/PSPreworkout/tag/v1.9.10
[1.9.11]: https://github.com/SamErde/PSPreworkout/tag/v1.9.11
[2.0.0-preview]: https://github.com/SamErde/PSPreworkout/tag/v2.0.0-preview
