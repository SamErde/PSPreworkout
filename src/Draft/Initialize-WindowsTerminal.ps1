function Initialize-WindowsTerminal {
    <#
        .SYNOPSIS
        Configure default settings for Windows Terminal

        .DESCRIPTION
        Configure settings for Windows Terminal and make it the default terminal application for Windows.

        .EXAMPLE
        Initialize-WindowsTerminal

        .NOTES
        Author: Sam Erde
        Version: 0.0.1
        Modified: 2024-11-13
    #>

    [CmdletBinding()]
    param ( )

    begin { } # end begin block

    process {
        $KeyPath = 'HKCU:\Console\%%Startup'
        if (-not (Test-Path -Path $keyPath)) {
            New-Item -Path $KeyPath | Out-Null
        } else {
            Write-Verbose -Message "Key already exists: $KeyPath"
        }
        New-ItemProperty -Path 'HKCU:\Console\%%Startup' -Name 'DelegationConsole' -Value '{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}' -Force | Out-Null
        New-ItemProperty -Path 'HKCU:\Console\%%Startup' -Name 'DelegationTerminal' -Value '{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}' -Force | Out-Null
    } # end process block

    end { } # end end block

} # end function Initialize-WindowsTerminal
