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
        $CMSiteServerFQDN
    )

    begin {
    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            "ByConfigMgr" {
                Write-Verbose "Selected Destination is ConfigMgr"
                try {
                    New-ChocoCMApplication -JsonFile $JsonFile -CMSiteCode $CMSiteCode -Verbose -CMSiteServerFQDN $CMSiteServerFQDN
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