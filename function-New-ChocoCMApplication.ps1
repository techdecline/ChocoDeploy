<#
    .SYNOPSIS
    .DESCRIPTION
    .EXAMPLE
    PS> New-ChocoCMApplication -JsonFile .\examples\Firefox.json -CMSiteCode "DEC:" -Verbose -CMSiteServerFQDN cm-server1.decline.lab
#>

function New-ChocoCMApplication {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param(
        # Specify JSON Input File
        [Parameter(Mandatory,ParameterSetName="ByJSON")]
        [ValidateScript({Test-Path $_})]
        [ValidatePattern(".*.json")]
        [String]
        $JsonFile,

        # Specify ConfigMgr Site Code
        [Parameter(Mandatory)]
        [ValidatePattern("^\w{3}:$")]
        [string]
        $CMSiteCode,

        # Specify CM Site Server FQDN
        [Parameter(Mandatory)]
        [String]
        $CMSiteServerFQDN
    )
    begin {
        # Connect ConfigMgr
        $modulePath = Join-Path -Path (split-path "$env:SMS_ADMIN_UI_PATH" -Parent) -ChildPath "ConfigurationManager.psd1"
        $jsonFullName = (get-item $JsonFile).FullName
        Write-Verbose "Loading ConfigMgr Module from: $modulePath"
        try {
            Import-Module $modulePath -ErrorAction Stop -Verbose:$false
            New-PSDrive -Name $CMSiteCode.Substring(0,3) -PSProvider CMSite -Root $CMSiteServerFQDN | Out-Null
            Push-Location -Path ($CMSiteCode + "\")
        }
        catch [System.Management.Automation.ActionPreferenceStopException] {
            Write-Error "Could not load ConfigMgr Module"
            return $false
        }
    }
    process {

        try {
            Write-Verbose "Importing JSON File: $jsonFullName"
            $packageObj = get-content $jsonFullName | ConvertFrom-Json -ErrorAction Stop

        }
        catch {
            Write-Error "Could not load JSON input file"
        }
        Write-Verbose "Current Package is: $($packageObj.PackageName)"
        $app = Get-CMApplication -Name $packageObj.PackageName -ErrorAction SilentlyContinue -Verbose:$false

        # Collect Parameters
        $appCreationParam = @{
            "Name" = $packageObj.PackageName
            "LocalizedDescription" = $packageObj.Description
            "Publisher" = $packageObj.Author
            "SoftwareVersion" = $packageObj.PackageVersion
            "Verbose" = $false
            "LocalizedName" = $packageObj.DisplayName
        }

        $imageFilePath = Get-ChocoCMImage -ImageUrl $packageObj.ImageUrl

        if ($imageFilePath) {
            $appCreationParam.Add("IconLocationFile",$imageFilePath)
        }

        Write-Verbose "Creating Application Container for $($packageObj.PackageName)"
        new-cmapplication @appCreationParam | out-null
        Set-CMApplication -Name $packageObj.PackageName -Keyword (Convert-ChocoCMTag -Tag $packageObj.Tags) -Verbose:$false| out-null

        Write-Verbose "Creating Chocolatey Deployment Type for: $($packageObj.PackageName)"
        $newDeploymentType = New-ChocoDeploymentType -ApplicationName $packageObj.PackageName -Verbose:$false
    }

    end {
        Pop-Location
    }
}

#New-ChocoCMApplication -JsonFile .\examples\Firefox.json -CMSiteCode "DEC:" -Verbose -CMSiteServerFQDN cm-server1.decline.lab