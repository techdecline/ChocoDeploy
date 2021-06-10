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
                    Write-Verbose "Creating Application Sources"
                    $intuneAppStagingObj = New-ChocoIntuneW32AppSources -PackagePath $Win32AppPath -JsonFile $JsonFile

                    $jsonFullName = (get-item $JsonFile).FUllName
                    $packageObj = get-content $jsonFullName | ConvertFrom-Json -ErrorAction Stop
                    $intuneAppStagingObj = $intuneAppStagingObj | Select-Object -Property *,@{Name = "IntuneAppFilePath";Expression = {New-ChocoIntuneW32Package -IntuneWinAppUtilExe $IntuneWinAppExePath -PackageFolder (Split-Path $_.DetectionScriptPath)}},
                                                                                            @{Name = "TenantName";Expression = {$TenantName}},
                                                                                            @{Name = "ApplicationDescription";Expression = {$packageObj.Description}},
                                                                                            @{Name = "ApplicationPublisherName";Expression = {$packageObj.Author}}


                    #return $intuneAppStagingObj
                    $appStagingParam = $intuneAppStagingObj.psobject.properties | ForEach-Object -begin {$h=@{}} -process {$h."$($_.Name)" = $_.Value} -end {$h}
                    New-ChocoIntuneW32App @appStagingParam
                }
                catch {
                    Write-Warning "Could not create Application: $error[0].exception.message"
                }
            }
        }
    }

    end {
    }
}