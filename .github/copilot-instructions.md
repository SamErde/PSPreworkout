# PowerShell Coding Standards
- Always use approved PowerShell verbs for function names (get, set, new, start, remove, update, etc.)
- Use Pascal case for all function names, variables, and parameters
- Follow OTBS (One True Brace Style) formatting
- Include one blank line at the end of every script
- Remove all trailing spaces
- Use proper cmdlet binding and parameter validation
- Always include comment-based help for functions
- Prefer explicit error handling over silent failures
- Use try/catch blocks for file operations, registry operations, and external commands
- Validate file paths and registry keys before operations

# Cross-Platform Considerations
- Test platform compatibility using $IsWindows, $IsLinux, $IsMacOS variables
- Provide graceful fallbacks for platform-specific features
- Use .NET methods over Windows-specific cmdlets when possible

# Response Preferences
- Include brief explanations of why a particular approach is recommended
- When suggesting refactoring, explain the benefits
- Provide both the solution and alternative approaches when applicable

# Security Guidelines
- Never hardcode credentials or API keys
- Always validate input parameters
- Implement proper authentication and authorization checks

# Commit Message Template for PowerShell Projects
Generate commit messages for PowerShell projects using this format:
`<emoji><type>: <description>`

## Commit Types for PowerShell Projects
- **feat**: ✨ New cmdlet, function, or module feature
- **fix**: 🐛 Bug fix in PowerShell code
- **docs**: 📚 Help documentation, comment-based help
- **style**: 🎨 Code formatting, OTBS compliance, Pascal case fixes
- **refactor**: ♻️ Code restructuring, approved verb compliance
- **test**: ✅ Pester tests, unit tests
- **build**: 🛠️ Module manifest, build scripts
- **ci**: 🤖 Azure DevOps, GitHub Actions for PowerShell
- **chore**: 🧹 Module organization, file cleanup
- **perf**: ⚡ Performance improvements in cmdlets or functions
- **revert**: ⏪ Reverting changes in PowerShell scripts or modules
- **packaging**: 📦 Packaging changes, module version updates
- **security**: 🔒 Security-related changes, input validation, authentication

## Commit Message Examples:
✨feat: add Get-UserProfile with parameter validation
🐛fix: resolve Invoke-ApiCall error handling
📚docs: update comment-based help for Set-Configuration
🎨style: apply OTBS formatting and Pascal case
✅test: add Pester tests for Get-SystemInfo
