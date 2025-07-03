function Test-IsElevated {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Test-IsElevated')]
    [Alias('isadmin', 'isroot')]
    [OutputType([bool])]
    param ()

    if (($PSVersionTable.PSVersion.Major -le 5) -or $IsWindows) {
        $CurrentUser = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
        return $CurrentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } else {
        # Unix-like systems (Linux, macOS, etc.)
        # Method 1: Try id command with error handling
        try {
            $userId = & id -u 2>$null
            if ($LASTEXITCODE -eq 0 -and $null -ne $userId) {
                return 0 -eq [int]$userId
            }
        } catch {
            Write-Debug "id command failed: $($_.Exception.Message)"
        }

        # Method 2: Check username via .NET
        try {
            if ([System.Environment]::UserName -eq 'root') {
                return $true
            }
        } catch {
            Write-Debug ".NET username check failed: $($_.Exception.Message)"
        }

        # Method 3: Check for macOS admin group membership
        try {
            # Check if we're on macOS and if user is in admin or wheel groups
            if ($IsMacOS -or (Get-Command 'sw_vers' -ErrorAction SilentlyContinue)) {
                # Method 3a: Use groups command to check admin group membership
                $groups = & Get-Groups 2>$null
                if ($LASTEXITCODE -eq 0 -and $groups) {
                    $groupList = $groups -split '\s+'
                    if ($groupList -contains 'admin' -or $groupList -contains 'wheel') {
                        return $true
                    }
                }

                # Method 3b: Use id command to check group IDs
                $groupIds = & id -G 2>$null
                if ($LASTEXITCODE -eq 0 -and $groupIds) {
                    $gidList = $groupIds -split '\s+' | ForEach-Object { [int]$_ }
                    if ($gidList -contains 80 -or $gidList -contains 0) {
                        # 80=admin, 0=wheel
                        return $true
                    }
                }
            }
        } catch {
            Write-Debug "macOS admin group check failed: $($_.Exception.Message)"
        }

        # Method 4: Check effective user ID via /proc (Linux-specific)
        try {
            if (Test-Path '/proc/self/status') {
                $statusContent = Get-Content '/proc/self/status' -ErrorAction SilentlyContinue
                $uidLine = $statusContent | Where-Object { $_ -match '^Uid:' }
                if ($uidLine -and $uidLine -match '\s+(\d+)\s+') {
                    return 0 -eq [int]$matches[1]
                }
            }
        } catch {
            Write-Debug "/proc status check failed: $($_.Exception.Message)"
        }

        # All methods failed
        Write-Warning 'Unable to determine elevation status on this Unix-like system. All detection methods failed.'
        return $false
    }
}

