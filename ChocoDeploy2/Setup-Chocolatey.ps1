﻿param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("Test","Install","Uninstall")]
    [String]$Mode = "Test"
)

function Install-Chocolatey
{
    [CmdletBinding()]
    Param
    (

    )
    Process
    {
        # https://chocolatey.org/install
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
}

function Uninstall-Chocolatey
{
    [CmdletBinding()]
    param
    (

    )
    Process
    {
        if (!$env:ChocolateyInstall) {
          Write-Warning "The ChocolateyInstall environment variable was not found. `n Chocolatey is not detected as installed. Nothing to do"
          return
        }
        if (!(Test-Path "$env:ChocolateyInstall")) {
          Write-Warning "Chocolatey installation not detected at '$env:ChocolateyInstall'. `n Nothing to do."
          return
        }

        $userPath = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment').GetValue('PATH', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString()
        $machinePath = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment\').GetValue('PATH', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString()

@"
User PATH:
$userPath

Machine PATH:
$machinePath
"@ | Out-File "C:\PATH_backups_ChocolateyUninstall.txt" -Encoding UTF8 -Force

        if ($userPath -like "*$env:ChocolateyInstall*") {
          Write-Output "Chocolatey Install location found in User Path. Removing..."
          # WARNING: This could cause issues after reboot where nothing is
          # found if something goes wrong. In that case, look at the backed up
          # files for PATH.
          [System.Text.RegularExpressions.Regex]::Replace($userPath, [System.Text.RegularExpressions.Regex]::Escape("$env:ChocolateyInstall\bin") + '(?>;)?', '', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase) | %{[System.Environment]::SetEnvironmentVariable('PATH', $_.Replace(";;",";"), 'User')}
        }

        if ($machinePath -like "*$env:ChocolateyInstall*") {
          Write-Output "Chocolatey Install location found in Machine Path. Removing..."
          # WARNING: This could cause issues after reboot where nothing is
          # found if something goes wrong. In that case, look at the backed up
          # files for PATH.
          [System.Text.RegularExpressions.Regex]::Replace($machinePath, [System.Text.RegularExpressions.Regex]::Escape("$env:ChocolateyInstall\bin") + '(?>;)?', '', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase) | %{[System.Environment]::SetEnvironmentVariable('PATH', $_.Replace(";;",";"), 'Machine')}
        }

        # Adapt for any services running in subfolders of ChocolateyInstall
        $agentService = Get-Service -Name chocolatey-agent -ErrorAction SilentlyContinue
        if ($agentService -and $agentService.Status -eq 'Running') { $agentService.Stop() }
        # TODO: add other services here

        # delete the contents (remove -WhatIf to actually remove)
        Remove-Item -Recurse -Force "$env:ChocolateyInstall"

        [System.Environment]::SetEnvironmentVariable("ChocolateyInstall", $null, 'User')
        [System.Environment]::SetEnvironmentVariable("ChocolateyInstall", $null, 'Machine')
        [System.Environment]::SetEnvironmentVariable("ChocolateyLastPathUpdate", $null, 'User')
        [System.Environment]::SetEnvironmentVariable("ChocolateyLastPathUpdate", $null, 'Machine')
    }
}

function Test-Chocolatey
{
    [CmdletBinding()]
    param (

    )
    Process
    {
        if (-not (Test-Path "$env:ALLUSERSPROFILE\Chocolatey\bin\choco.exe")) {
            return
        }
        else {
            Write-Verbose "The Chocolatey Executable variable was found."
            return $true
        }
        <#if (!$env:ChocolateyInstall) {
          #Write-Warning "The ChocolateyInstall environment variable was not found. `n Chocolatey is not detected as installed."
          # return null because of ConfigMgr Detection Rule Logic
          return $null
        }
        else {
            Write-Verbose "The ChocolateyInstall environment variable was found."
            return $true
        }#>
    }
}

switch ($Mode) {
    "Test" {
        Test-Chocolatey
    }
    "Install" {
        Install-Chocolatey
    }
    "Uninstall" {
        Uninstall-Chocolatey
    }
}