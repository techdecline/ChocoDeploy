<#
    .SYNOPSIS
    .DESCRIPTION
    .EXAMPLE
#>

function New-ChocoCMApplication {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param(
        # Specify JSON Input File
        [Parameter(Mandatory,ParameterSetName="ByJSON")]
        [ValidateScript({Test-Path $_})]
        [ValidatePattern("*.json")]
        [String]
        $JsonFile,

        # Specify ConfigMgr Site Code
        [Parameter(Mandatory)]
        [ValidatePattern("^\w{3}:$")]
        [string]
        $CMSiteCode
    )
    begin {
        # Connect ConfigMgr
        $modulePath = Join-Path -Path (split-path "$env:SMS_ADMIN_UI_PATH" -Parent) -ChildPath "ConfigurationManager.psd1"
        Write-Verbose "Loading ConfigMgr Module from: $modulePath"
        try {
            Import-Module $modulePath -ErrorAction Sto
            Push-Location -Path $CMSiteCode
        }
        catch [System.Management.Automation.ActionPreferenceStopException] {
            Write-Error "Could not load ConfigMgr Module"
            return $false
        }
    }
    process {

        try {
            Write-Verbose "Importing JSON File: $JsonFile"
            $packageObj = get-content $JsonFile | ConvertFrom-Json $JsonFile -ErrorAction Stop

            Write-Verbose "Current Package is: $($packageObj.PackageName)"
            $app = Get-CMApplication -Name $PackageName -ErrorAction SilentlyContinue
        }
        catch {
            Write-Error "Could not load JSON input file"
        }
    }
}