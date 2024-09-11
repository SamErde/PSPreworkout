function Get-TypeAccelerators {
    <#
    .SYNOPSIS
    List all available type accelerators.

    .DESCRIPTION
    List all available type accelerators. These can be useful when trying to find or remember the different type accellerators that are available to use in PowerShell.

    .PARAMETER GridView
    Show the output in a grid view.

    .EXAMPLE
    Get-TypeAccelerators

    .NOTES
    Thanks to Jeff Hicks (@JDHITSolutions) for helpful suggestions and improvements on this output!

    #>
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', 'Get-TypeAccelerators', Justification = 'The type accelerators are plural.')]
    param (
        # Show a grid view of the loaded assemblies
        [Parameter()]
        [switch]
        $GridView
    )

    $TypeAccelerators = ([PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get).GetEnumerator() |
        ForEach-Object {
            # Create a custom object to store the type name and the type itself.
            [PSCustomObject]@{
                PSTypeName = 'PSTypeAccelerator'
                PSVersion  = $PSVersionTable.PSVersion
                Name       = $_.Key
                Type       = $_.Value.FullName
            }
        }

    if ($PSBoundParameters.ContainsKey('GridView')) {

        if ((Get-Command -Name Out-ConsoleGridView -ErrorAction SilentlyContinue) -and ($PSVersionTable.PSEdition -eq 'Core')) {

            $TypeAccelerators | Out-ConsoleGridView -OutputMode Multiple

        } elseif ((Get-Command -Name Out-GridView -ErrorAction SilentlyContinue) -and ($PSVersionTable.PSEdition -eq 'Desktop')) {

            $TypeAccelerators | Out-GridView -OutputMode Multiple

        } else {
            Write-Output 'The Out-GridView and Out-ConsoleGridView cmdlets were not found. Please install the Microsoft.PowerShell.ConsoleGuiTools module or re-install the PowerShell ISE if using Windows PowerShell 5.1.'
            $TypeAccelerators | Format-Table -AutoSize
        }
    }

    $TypeAccelerators
}
