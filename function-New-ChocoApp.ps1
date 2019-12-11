<#
    .SYNOPSIS
    .DESCRIPTION
    .EXAMPLE
#>
function New-ChocoApp {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        # Specify JSON Input File
        [Parameter(Mandatory,ValueFromPipeline,Position=0)]
        [ValidateScript({Test-Path $_})]
        [ValidatePattern(".*.json")]
        [String]
        $JsonFile,

        # Specify ConfigMgr Site Code
        [Parameter(Mandatory,ParameterSetName="ByConfigMgr")]
        [ValidatePattern("^\w{3}:$")]
        [string]
        $CMSiteCode,

        # Specify CM Site Server FQDN
        [Parameter(Mandatory,ParameterSetName="ByConfigMgr")]
        [String]
        $CMSiteServerFQDN,

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
        $Win32AppPath
    )

    begin {
    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            "ByConfigMgr" {
                Write-Verbose "Selected Destination is ConfigMgr"
                try {
                    Import-Module "$PSScriptRoot\submodules\ChocoDeployCM\ChocoDeployCM.psm1"
                    New-ChocoCMApplication -JsonFile $JsonFile -CMSiteCode $CMSiteCode -Verbose -CMSiteServerFQDN $CMSiteServerFQDN
                }
                catch {
                    Write-Warning "Could not create Application"
                }
            }
            "ByIntune" {
                Write-Verbose "Selected Destination is Intune"
                try {
                    Import-Module "$PSScriptRoot\submodules\ChocoDeployIntune\ChocoDeployIntune.psm1"
                    New-ChocoIntuneW32AppSources -PackagePath $Win32AppPath -JsonFile $JsonFile | New-ChocoIntuneW32Package -IntuneWinAppUtilExe $IntuneWinAppExePath
                }
                catch {
                    Write-Warning "Could not create Application"
                }
            }
        }
    }

    end {
    }
}