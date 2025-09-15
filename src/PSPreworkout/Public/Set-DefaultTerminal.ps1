function Set-DefaultTerminal {
    <#
    .SYNOPSIS
    Configure the default terminal for Windows.

    .DESCRIPTION
    This function sets that default terminal in Windows to your choice of Windows PowerShell, PowerShell, Command Prompt,
    or Windows Terminal (default).

    .PARAMETER Name
    The name of the application to use as the default terminal in Windows.

    .EXAMPLE
    Set-DefaultTerminal -Name 'WindowsTerminal'
    #>

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'OK')]
    param (
        # The name of the application to use as the default terminal in Windows.
        [Parameter(Mandatory = $false)]
        [string]$Name = 'WindowsTerminal'
    )

    begin {
        # Send non-identifying usage statistics to PostHog.
        Write-PSPreworkoutTelemetry -EventName $MyInvocation.MyCommand.Name -ParameterNamesOnly $MyInvocation.BoundParameters.Keys

        $KeyPath = 'HKCU:\Console\%%Startup'
        if (-not (Test-Path -Path $keyPath)) {
            try {
                New-Item -Path $KeyPath >$null
            } catch {
                throw "Failed to create registry key: $_"
            }
        } else {
            Write-Verbose -Message "Key already exists: $KeyPath"
        }
    } # end begin block

    process {
        switch ($Name) {
            'WindowsTerminal' {
                try {
                    New-ItemProperty -Path 'HKCU:\Console\%%Startup' -Name 'DelegationConsole' -Value '{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}' -Force >$null
                    New-ItemProperty -Path 'HKCU:\Console\%%Startup' -Name 'DelegationTerminal' -Value '{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}' -Force >$null
                } catch {
                    throw "Failed to set default terminal: $_"
                }
            }
            default {
                Write-Information -MessageData 'No terminal application was specified.' -InformationAction Continue
            }
        }
    } # end process block

    end {
        Write-Information -MessageData "Default terminal set to: ${Name}." -InformationAction Continue
    } # end end block

} # end function Set-DefaultTerminal
