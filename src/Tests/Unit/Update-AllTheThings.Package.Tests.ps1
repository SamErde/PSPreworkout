BeforeAll {
    $RepositoryRoot = [System.IO.Path]::GetFullPath(
        (Join-Path -Path $PSScriptRoot -ChildPath '..\..\..')
    )
    $BuildScriptPath = Join-Path -Path $RepositoryRoot -ChildPath 'Scripts\Update-AllTheThings_Build.ps1'
    $PackagedScriptPath = Join-Path -Path $RepositoryRoot -ChildPath 'Scripts\Update-AllTheThings.ps1'
}

Describe 'Update-AllTheThings packaged script' {
    It 'matches the generated source artifact byte for byte' {
        $GeneratedScriptPath = Join-Path -Path $TestDrive -ChildPath 'Update-AllTheThings.ps1'

        & $BuildScriptPath -OutputPath $GeneratedScriptPath

        $GeneratedBytes = [System.IO.File]::ReadAllBytes($GeneratedScriptPath)
        $PackagedBytes = [System.IO.File]::ReadAllBytes($PackagedScriptPath)

        [Convert]::ToBase64String($GeneratedBytes) |
            Should -BeExactly ([Convert]::ToBase64String($PackagedBytes))
    }

    It 'loads in an isolated PowerShell process' {
        $SmokeTestPath = Join-Path -Path $TestDrive -ChildPath 'SmokeTest.ps1'
        $EscapedPackagePath = $PackagedScriptPath.Replace("'", "''")
        @"
. '$EscapedPackagePath'
Get-Command -Name Update-AllTheThings -ErrorAction Stop | Out-Null
Test-IsElevated | Out-Null
"@ | Set-Content -LiteralPath $SmokeTestPath -Encoding utf8

        $PowerShellPath = (Get-Process -Id $PID).Path
        & $PowerShellPath -NoLogo -NoProfile -NonInteractive -File $SmokeTestPath

        $LASTEXITCODE | Should -Be 0
    }
}
