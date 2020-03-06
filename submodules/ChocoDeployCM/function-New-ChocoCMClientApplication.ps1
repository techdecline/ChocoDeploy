function New-ChocoCMClientApplication {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param(
        # Specify ConfigMgr Site Code
        [Parameter(Mandatory)]
        [ValidatePattern("^\w{3}:$")]
        [string]
        $CMSiteCode,

        # Specify CM Site Server FQDN
        [Parameter(Mandatory)]
        [String]
        $CMSiteServerFQDN,

        # Specify Setup-Chocolatey Script location
        [Parameter(Mandatory=$false)]
        [ValidateScript({Test-Path $_})]
        [String]$SetupScriptLocation = (Join-Path -Path $PSScriptRoot -ChildPath "Setup-Chocolatey.ps1"),

        # Specify UNC Path for Application Creation
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path $_})]
        [ValidatePattern("\\\\.*")]
        [String]$ApplicationLocation
    )

    Begin {
        # Create Source Files
        try {
            $appLocation = new-item (Join-Path $ApplicationLocation -ChildPath "Chocolatey Client") -ItemType Directory
            Write-Verbose "Creating Source Files at: $($appLocation.FullName)"
            Copy-Item (get-item $SetupScriptLocation).PSPath -Destination $appLocation.FullName -Force
            $installScript = Join-Path -Path $appLocation.FullName -childPath "Install_Chocolatey.cmd"
            $uninstallScript = Join-Path -Path $appLocation.FullName -childPath "Uninstall_Chocolatey.cmd"
            '%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -Command ".\Setup-Chocolatey.ps1 -Mode Install"' | Out-File -FilePath $installScript -Force
            '%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -Command ".\Setup-Chocolatey.ps1 -Mode Uninstall"' | Out-File -FilePath $uninstallScript -Force

        }
        catch [System.Exception] {
            throw "Could not create source files: $($error.exception.message)"
        }

        # Connect ConfigMgr
        $modulePath = Join-Path -Path (split-path "$env:SMS_ADMIN_UI_PATH" -Parent) -ChildPath "ConfigurationManager.psd1"
        Write-Verbose "Loading ConfigMgr Module from: $modulePath"
        try {
            Import-Module $modulePath -ErrorAction Stop -Verbose:$false
            New-PSDrive -Name $CMSiteCode.Substring(0,3) -PSProvider CMSite -Root $CMSiteServerFQDN | Out-Null
            Push-Location -Path ($CMSiteCode + "\")
        }
        catch [System.Management.Automation.ActionPreferenceStopException] {
            throw "Could not load ConfigMgr Module"
        }
    }
    Process {
        $appName = "Chocolatey Client"

        # Create Application Container
        $app = Get-CMApplication -Name $appName -ErrorAction SilentlyContinue
        if ($app) {
            Write-Verbose "Application exists: $appName"
            return $app
        }
        else {
            try {
                $app = New-CMApplication -Name $appName
            }
            catch [System.Exception] {
                throw "Could not create application: $($error.exception.message)"
            }
        }

        # Create Deployment Type
        try {
            $dtParam = @{
                DeploymentTypeName = "SCRIPT_ChocolateyClient"
                ContentLocation = $appLocation.FullName
                InstallCommand = Split-Path $installScript -Leaf
                UninstallCommand = Split-Path $uninstallScript -Leaf
                ScriptLanguage = "Powershell"
                ScriptText = (Get-Content $SetupScriptLocation) -join "`n"
                InstallationBehaviorType = "InstallForSystem"
                UserInteractionMode = "Hidden"
                LogonRequirementType = "WhetherOrNotUserLoggedOn"
                ApplicationId = $app.CI_ID
            }
            Add-CMScriptDeploymentType @dtParam
        }
        catch [System.exception] {
            throw "Could not create deployment type: $($error.exception.message)"
        }
    }
    End {
        Pop-Location
    }
}