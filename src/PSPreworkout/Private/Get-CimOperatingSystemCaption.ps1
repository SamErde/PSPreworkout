function Get-CimOperatingSystemCaption {
    <#
    .SYNOPSIS
    Gets the operating-system caption through CIM.

    .DESCRIPTION
    Queries CIM_OperatingSystem and returns its caption.

    .OUTPUTS
    System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [scriptblock]$Query = {
            (Get-CimInstance -ClassName CIM_OperatingSystem -ErrorAction Stop).Caption
        }
    )

    return & $Query
}
