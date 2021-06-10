<#
    .SYNOPSIS
    .DESCRIPTION
    .EXAMPLE
#>
function New-ChocoClientApp {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        # Specify ConfigMgr Site Code
        [Parameter(Mandatory,ParameterSetName="ByConfigMgr")]
        [ValidatePattern("^\w{3}:$")]
        [string]
        $CMSiteCode,

        # Specify CM Site Server FQDN
        [Parameter(Mandatory,ParameterSetName="ByConfigMgr")]
        [String]
        $CMSiteServerFQDN,

        # Specify CM Application Location
        [Parameter(Mandatory,ParameterSetName="ByConfigMgr")]
        [String]
        $CMApplicationPath,

        # Specify Path for Intune Win32 App Preparation Tool
        [Parameter(Mandatory,ParameterSetName="ByIntune")]
        [ValidateScript({Test-Path $_})]
        [ValidatePattern(".*.exe")]
        [String]
        $IntuneWinAppExePath,

        # Specify Output Path for Intune App
        [Parameter(Mandatory=$false,ParameterSetName="ByIntune")]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]
        $Win32AppPath,

        # Specify Tenant Name for Intune App
        [Parameter(Mandatory,ParameterSetName="ByIntune")]
        [string]
        $TenantName
    )

    begin {
    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            "ByConfigMgr" {
                Write-Verbose "Selected Destination is ConfigMgr"
                try {
                    Import-Module "$PSScriptRoot\submodules\ChocoDeployCM\ChocoDeployCM.psm1"
                    $appParam = @{
                        CMSiteCode = $CMSiteCode
                        CMSiteServerFQDN = $CMSiteServerFQDN
                        SetupScriptLocation = "$PSScriptRoot\Setup-Chocolatey.ps1"
                        ApplicationLocation = $CMApplicationPath
                    }
                    New-ChocoCMClientApplication @appParam
                }
                catch {
                    Write-Warning "Could not create Chocolatey Client Application: $($error[0].Exception.Message)"
                }
            }
            "ByIntune" {
                Write-Verbose "Selected Destination is Intune"

                try {
                    Import-Module "$PSScriptRoot\submodules\ChocoDeployIntune\ChocoDeployIntune.psm1"
                    #New-ChocoIntuneW32AppSources -PackagePath $Win32AppPath -JsonFile $JsonFile | New-ChocoIntuneW32Package -IntuneWinAppUtilExe $IntuneWinAppExePathremo
                    Write-Verbose "Creating Application Sources"
                    $intuneAppStagingObj = New-ChocoIntuneW32ClientAppSources -PackagePath $Win32AppPath -SetupScriptLocation "$PSScriptRoot\Setup-Chocolatey.ps1"

                    $intuneAppStagingObj = $intuneAppStagingObj | Select-Object -Property *,@{Name = "IntuneAppFilePath";Expression = {New-ChocoIntuneW32Package -IntuneWinAppUtilExe $IntuneWinAppExePath -PackageFolder (Split-Path $_.DetectionScriptPath) -SetupFileName "Install_Chocolatey.cmd"}},
                                                                                            @{Name = "TenantName";Expression = {$TenantName}},
                                                                                            @{Name = "ApplicationPublisherName";Expression = {"Chocolatey"}}


                    #return $intuneAppStagingObj
                    $appStagingParam = $intuneAppStagingObj.psobject.properties | ForEach-Object -begin {$h=@{}} -process {$h."$($_.Name)" = $_.Value} -end {$h}
                    New-ChocoIntuneW32App @appStagingParam
                }
                catch {
                    Write-Warning "Could not create Application: $($error[0].exception.message)"
                }
            }
        }
    }

    end {
    }
}