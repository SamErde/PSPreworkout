function Get-TypeAccelerator {
    <#
    .SYNOPSIS
    Get available type accelerators.

    .DESCRIPTION
    Get available type accelerators. These can be useful when trying to find or remember the different type accelerators
    that are available to use in PowerShell.

    .PARAMETER Name
    The name of a specific type accelerator to get.

    .EXAMPLE
    Get-TypeAccelerator -Name ADSI

    .EXAMPLE
    Get-TypeAccelerator -Name ps*

    Get all type accelerators that begin with the string "ps".

    .NOTES
    Author: Sam Erde
    Version: 0.0.3
    Modified: 2024/10/29

    Thanks to Jeff Hicks (@JDHITSolutions) for helpful suggestions and improvements on this output!

    #>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Get-TypeAccelerator')]
    [OutputType('Object[]')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'Fighting with VS Code autoformatting.')]
    param (

        # Parameter help description
        [Parameter(Position = 0, HelpMessage = 'The name of the type accelerator, such as "ADSI."')]
        [SupportsWildcards()]
        [string]
        $Name = '*'
    )

    Write-Debug "Getting type accelerators with the name: $Name"
    $TypeAccelerators = ([PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get).GetEnumerator() |
        Where-Object { $_.Key -like $Name } |
            ForEach-Object {
                # Create a custom object to store the type name and the type itself.
                [PSCustomObject]@{
                    PSTypeName = 'PSTypeAccelerator'
                    PSVersion  = $PSVersionTable.PSVersion
                    Name       = $_.Key
                    Type       = $_.Value.FullName
                }
            }
    $TypeAccelerators
}
