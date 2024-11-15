function Remove-OldModule {
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
    param (

    )

    begin {

    }

    process {
        $Modules = Get-Module -ListAvailable
        $MultipleVersions = ($Modules | Group-Object -Property Name).Where({ $_.Count -gt 1 })

        foreach ($module in $MultipleVersions) {
            $SupersededModules = $module.Group | Select-Object -Skip 1
            $SupersededModules | ForEach-Object {
                Uninstall-Module -Name $_.Name -RequiredVersion $_.Version -Force
            }
        }
    }

    end {

    }
}
