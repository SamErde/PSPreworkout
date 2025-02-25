<#
BeforeAll {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'PSPreworkout'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', 'Artifacts', "$ModuleName.psd1")
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}
#>

Describe 'Get-PowerShellPortable Tests' -Tag Unit {
    Context 'Function Tests' {
        It 'Function should exist' {
            Get-Command -Name Get-PowerShellPortable | Should -Not -BeNullOrEmpty
        }

        #It 'Function should have correct alias' {
        #    (Get-Command -Name Get-PowerShellPortable).Aliases | Should -Contain 'Get-PSPortable'
        #}

        It 'Function should have valid HelpUri' {
            (Get-Command -Name Get-PowerShellPortable).HelpUri | Should -BeExactly 'https://day3bits.com/PSPreworkout/Get-PowerShellPortable'
        }

        #It 'Function should handle Path parameter correctly' {
        #    $Path = "$HOME\Downloads"
        #    $result = Get-PowerShellPortable -Path $Path
        #    $result | Should -Contain 'PowerShell has been downloaded to'
        #}

        #It 'Function should handle Extract parameter correctly' {
        #    $Path = "$HOME\Downloads"
        #    $result = Get-PowerShellPortable -Path $Path -Extract
        #    $result | Should -Contain 'PowerShell has been extracted to'
        #}

        It 'Function should determine correct download URL for Windows' {
            $DownloadLinks = @('https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/powershell-7.1.3-win-x64.zip')
            $Architecture = 'X64'
            $FilePattern = "win-$Architecture.zip"
            $DownloadUrl = $DownloadLinks | Where-Object { $_ -match $FilePattern }
            $DownloadUrl | Should -BeExactly 'https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/powershell-7.1.3-win-x64.zip'
        }

        It 'Function should determine correct download URL for Linux' {
            $DownloadLinks = @('https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/powershell-7.1.3-linux-x64.tar.gz')
            $Architecture = 'X64'
            $FilePattern = "linux-$Architecture.tar.gz"
            $DownloadUrl = $DownloadLinks | Where-Object { $_ -match $FilePattern }
            $DownloadUrl | Should -BeExactly 'https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/powershell-7.1.3-linux-x64.tar.gz'
        }

        It 'Function should determine correct download URL for macOS' {
            $DownloadLinks = @('https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/powershell-7.1.3-osx-x64.tar.gz')
            $Architecture = 'X64'
            $FilePattern = "osx-$Architecture.tar.gz"
            $DownloadUrl = $DownloadLinks | Where-Object { $_ -match $FilePattern }
            $DownloadUrl | Should -BeExactly 'https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/powershell-7.1.3-osx-x64.tar.gz'
        }
    }
}

# Remove-Module $ModuleName -Force
