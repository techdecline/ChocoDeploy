<#
    .SYNOPSIS
    .DESCRIPTION
    .EXAMPLE
#>
function New-ChocoApp {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        # Specify JSON Input File
        [Parameter(Mandatory)]
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
    }

    end {
    }
}