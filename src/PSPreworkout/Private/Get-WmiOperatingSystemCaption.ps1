function Get-WmiOperatingSystemCaption {
    <#
    .SYNOPSIS
    Gets the operating-system caption through WMI.

    .DESCRIPTION
    Queries Win32_OperatingSystem and returns its caption for Windows PowerShell
    5.1 environments where CimCmdlets are unavailable.

    .OUTPUTS
    System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWMICmdlet',
        '',
        Justification = 'Get-WmiObject is required as a Windows PowerShell 5.1 fallback when CimCmdlets are unavailable.'
    )]
    param(
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [scriptblock]$Query = {
            (Get-WmiObject -Class Win32_OperatingSystem -ErrorAction Stop).Caption
        }
    )

    return & $Query
}
