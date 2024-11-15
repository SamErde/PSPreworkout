
function Test-GEV {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Interactive Use')]
    param ()

    Clear-Host
    Write-Host 'Expected: Return all environment variables from all targets.' -ForegroundColor Magenta
    Write-Host 'Results:  Works as expected.' -ForegroundColor Magenta
    Write-Host 'Nothing' -ForegroundColor Magenta -BackgroundColor Black
    Get-EnvironmentVariable -Debug | Format-Table Name, Target, Value

    Clear-Host
    Write-Host 'Expected: Return all environment variables from all targets.' -ForegroundColor Magenta
    Write-Host 'Results:  Works as expected.' -ForegroundColor Magenta
    Write-Host 'Everything' -ForegroundColor Magenta -BackgroundColor Black
    Get-EnvironmentVariable -All -Debug | Format-Table Name, Target, Value

    Clear-Host
    Write-Host 'Expected: Return all name matches in the specified targets.' -ForegroundColor Magenta
    Write-Host 'Results:  Works as expected.' -ForegroundColor Magenta
    Write-Host '-Name with Targets' -ForegroundColor Magenta -BackgroundColor Black
    Get-EnvironmentVariable -Name TEMP -Target 'Machine' -Debug | Format-Table Name, Target, Value
    Get-EnvironmentVariable -Name TEMP -Target 'Machine', 'User' -Debug | Format-Table Name, Target, Value
    Get-EnvironmentVariable -Name TEMP -Target 'Machine', 'User', 'Process' -Debug | Format-Table Name, Target, Value

    Clear-Host
    Write-Host 'Expected: Return all pattern matches in the specified targets.' -ForegroundColor Magenta
    Write-Host 'Results:  Works as expected.' -ForegroundColor Magenta
    Write-Host '-Pattern with Targets' -ForegroundColor Magenta -BackgroundColor Black
    Get-EnvironmentVariable -Pattern '^t' -Target 'Machine' -Debug | Format-Table Name, Target, Value
    Get-EnvironmentVariable -Pattern '^t' -Target 'Machine', 'User' -Debug | Format-Table Name, Target, Value
    Get-EnvironmentVariable -Pattern '^t' -Target 'Machine', 'User', 'Process' -Debug | Format-Table Name, Target, Value

    Clear-Host
    Write-Host 'Expected: Return all environment variables from the specified target[s].' -ForegroundColor Magenta
    Write-Host 'Results:  Works as expected.' -ForegroundColor Magenta
    Write-Host 'Just Targets' -ForegroundColor Cyan -BackgroundColor Black
    Get-EnvironmentVariable -Target 'Machine' -Debug | Format-Table Name, Target, Value
    Get-EnvironmentVariable -Target 'Machine', 'User' -Debug | Format-Table Name, Target, Value
    Get-EnvironmentVariable -Target 'Machine', 'User', 'Process' -Debug | Format-Table Name, Target, Value

    Clear-Host
    Write-Host 'Expected: Return all name matches in the specified target[s]. Ignore the -All switch.' -ForegroundColor Magenta
    Write-Host 'Results:  Works as expected.' -ForegroundColor Magenta
    Write-Host '-Name with Targets & All' -ForegroundColor Yellow -BackgroundColor Black
    Get-EnvironmentVariable -Name TEMP -Target 'Machine' -All -Debug | Format-Table Name, Target, Value
    Get-EnvironmentVariable -Name TEMP -Target 'Machine', 'User' -All -Debug | Format-Table Name, Target, Value
    Get-EnvironmentVariable -Name TEMP -Target 'Machine', 'User', 'Process' -All -Debug | Format-Table Name, Target, Value

    Clear-Host
    Write-Host 'Expected: Return all pattern matches in the specified target[s]. Ignore the -All switch.' -ForegroundColor Magenta
    Write-Host 'Results:  Works as expected.' -ForegroundColor Magenta
    Write-Host '-Pattern with Targets & All' -ForegroundColor Green -BackgroundColor Black
    Get-EnvironmentVariable -Pattern '^t' -Target 'Machine' -All -Debug | Format-Table Name, Target, Value
    Get-EnvironmentVariable -Pattern '^t' -Target 'Machine', 'User' -All -Debug | Format-Table Name, Target, Value
    Get-EnvironmentVariable -Pattern '^t' -Target 'Machine', 'User', 'Process' -All -Debug | Format-Table Name, Target, Value

    Clear-Host
    Write-Host 'Expected: Return all environment variables from the specified target[s].' -ForegroundColor Magenta
    Write-Host 'Results:  Works as expected.' -ForegroundColor Magenta
    Write-Host 'Just Targets & All' -ForegroundColor Cyan -BackgroundColor Black
    Get-EnvironmentVariable -Target 'Machine' -All -Debug | Format-Table Name, Target, Value
    Get-EnvironmentVariable -Target 'Machine', 'User' -All -Debug | Format-Table Name, Target, Value
    Get-EnvironmentVariable -Target 'Machine', 'User', 'Process' -All -Debug | Format-Table Name, Target, Value
}
