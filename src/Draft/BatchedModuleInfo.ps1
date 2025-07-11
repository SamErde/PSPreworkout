$OnlineModuleInfo = [System.Collections.Generic.List[Object]]::new()

$InstalledModules = Get-InstalledModule | Sort-Object -Property Name
if (Get-Module -Name 'Microsoft.PowerShell.PSResourceGet' -ListAvailable) {
    # Use PSResourceGet if it is available.
    $OnlineModuleInfo = Find-PSResource $InstalledModules.Name
} else {
    # Fallback to PowerShellGet if PSResourceGet is not available. Batch processing is used to avoid exceeding the 63 module limit.
    Write-Information -MessageData 'The PSResourceGet module is not available. Using PowerShellGet instead. It is recommended to installed the updated Microsoft.PowerShell.PSResourceGet module for the best functionality and performance.' -InformationAction Continue
    if ($InstalledModules.Count -le 63) {
        $OnlineModuleInfo = Find-Module $InstalledModules
    } else {
        # If there are more than 63 modules, find them in batches of 63
        Write-Verbose 'More than 63 modules found. Processing in batches of 63.'
        for ($i = 0; $i -lt $InstalledModules.Count; $i += 63) {
            Write-Verbose "Processing batch starting at index $i"
            $Batch = $InstalledModules[$i..[Math]::Min($i + 62, $InstalledModules.Count - 1)]
            Find-Module $Batch.Name -ErrorAction SilentlyContinue | ForEach-Object {
                $OnlineModuleInfo.Add($_)
            }
        }
    }
}
