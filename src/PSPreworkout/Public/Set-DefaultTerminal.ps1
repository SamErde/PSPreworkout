function Set-DefaultTerminal {
    <#
        .SYNOPSIS
        Configure the default terminal for Windows

        .DESCRIPTION
        This function sets that default terminal in Windows to your choice of Windows PowerShell, PowerShell, Command Prompt, or Windows Terminal (default).

        .PARAMETER Name
        The name of the application to use as the default terminal in Windows.

        .EXAMPLE
        Set-DefaultTerminal -Name 'WindowsTerminal'

        .NOTES
        Author: Sam Erde
        Version: 0.0.1
        Modified: 2024-11-15
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The name of the application to use as the default terminal in Windows.
        [Parameter(Mandatory = $false)]
        [string]$Name = 'WindowsTerminal'
    )

    begin {
        $KeyPath = 'HKCU:\Console\%%Startup'
        if (-not (Test-Path -Path $keyPath)) {
            New-Item -Path $KeyPath | Out-Null
        } else {
            Write-Verbose -Message "Key already exists: $KeyPath"
        }
    } # end begin block

    process {
        switch ($Name) {
            'WindowsTerminal' {
                New-ItemProperty -Path 'HKCU:\Console\%%Startup' -Name 'DelegationConsole' -Value '{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}' -Force | Out-Null
                New-ItemProperty -Path 'HKCU:\Console\%%Startup' -Name 'DelegationTerminal' -Value '{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}' -Force | Out-Null
            }
            default {
                Write-Information -Message 'No terminal application was specified.' -InformationAction Continue
            }
        }
    } # end process block

    end {
        Write-Information -Message "Default terminal set to: ${Name}." -InformationAction Continue
    } # end end block

} # end function Set-DefaultTerminal
