<#
    .DESCRIPTION
        A quick proof of concept for pulling a list of Microsoft PowerShell modules from the msshells.net project.

    .NOTES
        Credit and thanks to Andrés Gorzelany for permission to depend on the MSSHELLS.NET project for its data!

        See https://github.com/get-itips/msshells, https://twitter.com/AndresGorzelany
#>

function Get-MsShellsModules {
    $MsShellsRepoUri = 'https://api.github.com/repos/get-itips/msshells/contents/_ps_modules'
    $Content = Invoke-RestMethod -Uri $MsShellsRepoUri

    foreach ($item in $Content) {
        $DownloadPath = "msshells-content/$($item.name)"
        Invoke-RestMethod -Uri $item.download_url -OutFile $DownloadPath
    }
}

function Read-ModuleInfo {
    Install-Module powershell-yaml
    Import-Module powershell-yaml

    $PsModuleFiles = Get-ChildItem -Path 'msshells-content/*.md'
    foreach ($item in $PsModuleFiles) {

        $Module = ConvertFrom-Yaml -Yaml ([System.IO.File]::ReadAllText("$item"))
        Find-Module -Name $Module.name
    }
}

<#
    Compare with sample from checker.ps1
    # Convert files from YAML
    $moduleDataObj = Get-ChildItem -Path $dataFolderPath | ForEach-Object {
        @{
        FileName = $PSItem.Name
        Content = ConvertFrom-Yaml -Yaml (
            Get-Content -Path $PSItem -Raw
            ).replace("---`n", "").trim()
        }
    }
#>
