<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
<!-- Show the history of all changes since the last release. -->
[*Full Changelog*](https://github.com/SamErde/PSPreworkout/compare/latest...HEAD)

## [1.7.3-rc] - 2025-2-24

A test of the release process. Some new Pester tests are also being built.

## What's Changed
* Dev general by @SamErde in https://github.com/SamErde/PSPreworkout/pull/61
* Repository Maintenance by @SamErde in https://github.com/SamErde/PSPreworkout/pull/62
* Add version 1.7.2 with improved error handling by @SamErde in https://github.com/SamErde/PSPreworkout/pull/63

**Full Changelog**: https://github.com/SamErde/PSPreworkout/compare/v1.7.2...v1.7.3-rc

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

- Add updatable and online [external] help.

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
- Remove `-Force` on module install scriptblock for `Initialize-PSEnvironmentConfiguration`

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
[1.7.3-rc]: https://github.com/SamErde/PSPreworkout/tag/v1.7.3-rc

