# Contributing

Thanks for your interest in contributing to the **PSPreworkout** module!

Whether it's a bug report, new feature, correction, or additional documentation, your feedback and contributions are appreciated.

Please read through this document before submitting any issues or pull requests to ensure all the necessary information is provided to effectively respond to your bug report or contribution.

Please note there is a code of conduct, please follow it in all your interactions with the project.

## Code Style and Standards Conventions

This repository follows best practices and style guidelines that are commonly accepted by the core PowerShell project and by the community at large. We follow the "One True Brace Style" (OTBS) and other practices thare are spelled out in detail in [The PowerShell Best Practices and Style Guide](https://github.com/PoshCode/PowerShellPracticeAndStyle). You may also refer to the PowerShell team's [guide to contributing](https://learn.microsoft.com/en-us/powershell/scripting/community/contributing/overview).

Additional details are described well in this project's [PowerShell instructions](instructions/powershell.instructions.md) file.

## Automated Module Manifest Updates

When you add a new public function to the module, the build process and GitHub Actions workflows will automatically update the module manifest (`PSPreworkout.psd1`) to include:

- The function name in `FunctionsToExport`
- Any aliases defined with `[Alias()]` attributes in `AliasesToExport`
- Aliases are also added to `FunctionsToExport` per this module's convention

### How It Works

1. **During Build**: The `UpdateManifest` task in `PSPreworkout.build.ps1` scans all `.ps1` files in the `Public` folder and automatically updates the manifest before testing and building.

2. **On Pull Requests**: The "Validate Module Manifest" GitHub Actions workflow checks if any new functions or aliases are missing from the manifest. If any are found, it will automatically commit an update to your PR.

### Adding a New Function

1. Create your function file in `src/PSPreworkout/Public/YourFunction.ps1`
2. Include any aliases using the `[Alias('alias1', 'alias2')]` attribute
3. Commit and push your changes - the manifest will be updated automatically!

Example:
```powershell
function Get-MyNewFunction {
    [CmdletBinding()]
    [Alias('gmf', 'Get-MyFunc')]
    param()
    
    # Your function code here
}
```

No manual manifest editing required! The automation will detect `Get-MyNewFunction`, `gmf`, and `Get-MyFunc` and add them to the appropriate sections of the manifest.

## Contributing via Pull Requests

Please do not submit changes directly to the main branch. Create a fork of the project and use the `prerelease` branch as your target when submitting a pull request. If you have questions about how to do that, I would be more than happy to walk you through the steps over in the [discussions](https://github.com/SamErde/PSPreworkout/discussions)!

## Code of Conduct

This project has a [Code of Conduct](CODE_OF_CONDUCT.md).

## Licensing

See the [LICENSE](LICENSE) file for our project's licensing.
