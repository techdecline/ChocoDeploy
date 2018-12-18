function Add-ChocoCMDependency {
    [CmdletBinding()]
    param (
        # Input Deployment Type
        [Parameter(Mandatory)]
        [ValidateScript({$_.SmsProviderObjectPath -match "^SMS_DeploymentType.*"})]
        $TargetDeploymentType,

        # Name of Chocolatey Client Application
        [Parameter(Mandatory=$false)]
        [string]$ChocoAppName = "Chocolatey Client"
    )

    begin {
        Write-Verbose "Trying to find Chocolatey Client Deployment Type with Name: $ChocoAppName"
        $chocoDt = Get-CMDeploymentType -ApplicationName $ChocoAppName
        if (-not ($chocoDt)) {
            Write-Error "Could not find Deployment Type for Chocolatey Client"
        }
        else {
            Write-Verbose "Found Deployment Type for Chocolatey Client: $($chocoDt.LocalizedDisplayName)"
        }
    }

    process {
        Write-Verbose "Checking for existing dependency group on: $($TargetDeploymentType.LocalizedDisplayName)"
        $existingDependencyGroup = Get-CMDeploymentTypeDependencyGroup -InputObject $TargetDeploymentType -GroupName "Choco" -ErrorAction SilentlyContinue
        if ($existingDependencyGroup)
        {
            Write-Verbose "Found existing dependecy group. Will impose no further actions"
            return $TargetDeploymentType
        }
        else {
            Write-Verbose "Adding dependency group 'choco' to : $($TargetDeploymentType.LocalizedDisplayName)"
            try {
                $obj = New-CMDeploymentTypeDependencyGroup -GroupName Choco -InputObject $TargetDeploymentType
                $newDependencyGroup = Add-CMDeploymentTypeDependency -IsAutoInstall $true -DeploymentTypeDependency $chocoDt -InputObject $obj
                return $TargetDeploymentType
            }
            catch {
                Write-Error "Error adding dependency: $($error[0])"
            }
        }
    }
}