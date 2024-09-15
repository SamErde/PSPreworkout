# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
&nbsp;
&nbsp;
## [Unreleased]

### Added

- Add `Get-VSCodePortable`
- Add `Remove-OldModule`
&nbsp;
&nbsp;

## [1.2.4] - 2024-09-13

### Fixed
- Fix extraction of PowerShell .tar.gz file on macOS
- Fix/improve references to location of the extracted PowerShell files
&nbsp;
&nbsp;

## [1.2.2] - 2024-09-13

### Added

- Add `Get-PowerShellPortable` - a function to download and extract a ZIP file of the latest release of PowerShell, which can be run without installing.
- Add some default PowerShell preferences to `Initialize-PSEnvironmentConfiguration`
- Add PSReadLine preferences and history handler to `Initialize-PSEnvironmentConfiguration`
&nbsp;
&nbsp;
## [1.1.2] - 2024-09-12

### Changed

- Get Author name from the currently logged-in user profile (if Windows) in `New-ScriptFromTemplate`
- Add parameter validation in `New-ScriptFromTemplate`
&nbsp;
&nbsp;
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
&nbsp;
&nbsp;
## [0.4.1] - 2024-09-09

### Changed

- Export aliases when importing module
&nbsp;
&nbsp;
## [0.3.2] - 2024-09-06

### Changed

- Temporarily exclude Chocolatey from the default execution of `Update-AllTheThings`
- Improve server and OS detection in `Update-AllTheThings`

### Added

- Add `Install-WinGet`
- Add `Edit-WinGetSettings`
- Add `Initialize-Configuration`
&nbsp;
&nbsp;

_Initial release._

[Unreleased]: https://github.com/SamErde/PSPreworkout/compare/v1.2.2...HEAD
[1.2.4]: https://github.com/SamErde/PSPreworkout/tag/v1.2.4
[1.2.3]: https://github.com/SamErde/PSPreworkout/tag/v1.2.3
[1.2.2]: https://github.com/SamErde/PSPreworkout/tag/v1.2.2
[1.1.2]: https://github.com/SamErde/PSPreworkout/tag/v1.1.2
[1.1.0]: https://github.com/SamErde/PSPreworkout/tag/v1.1.0
[0.4.1]: https://github.com/SamErde/PSPreworkout/tag/v0.4.1
[0.3.2]: https://github.com/SamErde/PSPreworkout/tag/v0.3.2
