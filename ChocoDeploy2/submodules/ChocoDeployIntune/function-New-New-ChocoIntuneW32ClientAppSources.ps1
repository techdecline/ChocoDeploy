function New-ChocoIntuneW32ClientAppSources {
    [CmdletBinding()]
    param (
        # Directory where to create source files
        [Parameter(Mandatory=$false)]
        [ValidateScript({Test-Path $_})]
        [String]$PackagePath=$env:TEMP,

        # Specify Setup-Chocolatey Script location
        [Parameter(Mandatory=$false)]
        [ValidateScript({Test-Path $_})]
        [String]$SetupScriptLocation = (Join-Path -Path $PSScriptRoot -ChildPath "Setup-Chocolatey.ps1")
    )

    process {
        # Create Source Files
        try {
            $appLocation = new-item (Join-Path $PackagePath -ChildPath "ChocolateyClient") -ItemType Directory
            Write-Verbose "Creating Source Files at: $($appLocation.FullName)"
            $detectionScript = Copy-Item (get-item $SetupScriptLocation).PSPath -Destination $appLocation.FullName -Force -PassThru
            $installScript = Join-Path -Path $appLocation.FullName -childPath "Install_Chocolatey.cmd"
            # add hard reboot exit code
            $installScriptContent = [String]::Concat('%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -Command "%~dp0Setup-Chocolatey.ps1 -Mode Install"',"`nexit 1641")
            $uninstallScript = Join-Path -Path $appLocation.FullName -childPath "Uninstall_Chocolatey.cmd"
            #'%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -Command "%~dp0Setup-Chocolatey.ps1 -Mode Install"' | Out-File -FilePath $installScript -Force -Encoding utf8NoBOM
            [System.IO.File]::WriteAllLines($installScript,$installScriptContent)
            #'%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -Command "%~dp0Setup-Chocolatey.ps1 -Mode Uninstall"' | Out-File -FilePath $uninstallScript -Force -Encoding utf8NoBOM
            [System.IO.File]::WriteAllLines($uninstallScript,'%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -Command "%~dp0Setup-Chocolatey.ps1 -Mode Uninstall"')
        }
        catch [System.Exception] {
            throw "Could not create source files: $($error.exception.message)"
        }

        $returnObj = 1 | Select-Object @{Name = "ApplicationDisplayName";Expression = {"ChocolateyClient"}},
                                        @{Name = "InstallCommandline";Expression = {"Install_Chocolatey.cmd"}},
                                        @{Name = "UninstallCommandline";Expression = {"Uninstall_Chocolatey.cmd"}},
                                        @{Name = "DetectionScriptPath";Expression = {$($detectionScript.FullName)}}
        return $returnObj
    }
}