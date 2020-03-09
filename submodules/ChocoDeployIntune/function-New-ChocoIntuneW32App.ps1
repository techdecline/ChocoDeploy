#Requires -Module @{ ModuleName = 'PSIntuneAuth'; ModuleVersion = '1.2.2' },@{ ModuleName = 'AzureAD'; ModuleVersion = '2.0.2.76' },@{ModuleName = "intunewin32app"; ModuleVersion = "1.1.0"}
#Requires -Version 5.1
<#
    .SYNOPSIS
    .DESCRIPTION
    .EXAMPLE
#>
function New-ChocoIntuneW32App {
    [CmdletBinding()]
    param (
        # Application Icon
        [Parameter(Mandatory=$false)]
        [ValidateScript({Test-Path $_})]
        [ValidatePattern(".jpeg$|.jpg$|.png$")]
        [String]
        $IconFilePath,

        # PowerShell Detection Script Path
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path $_})]
        [ValidatePattern(".ps1")]
        [String]
        $DetectionScriptPath,

        # Install Command Line
        [Parameter(Mandatory)]
        [string]
        $InstallCommandLine,

        # Uninstall Command Line
        [Parameter(Mandatory)]
        [string]
        $UninstallCommandLine,

        # Description
        [Parameter(Mandatory=$false)]
        [string]
        $ApplicationDescription = " ",

        # Application Display Name
        [Parameter(Mandatory)]
        [string]
        $ApplicationDisplayName,

        # Application Publisher Name
        [Parameter(Mandatory)]
        [string]
        $ApplicationPublisherName,

        # Application File Name
        [Parameter(Mandatory)]
        [ValidatePattern(".intunewin$")]
        [string]
        $IntuneAppFilePath,

        # Tenant Name
        [Parameter(Mandatory)]
        [string]
        $TenantName
    )
    process {


        $appCreateParam = @{
            DetectionRule = New-IntuneWin32AppDetectionRule -PowerShellScript -ScriptFile $DetectionScriptPath
            RestartBehavior = "suppress"
            TenantName = $TenantName
            FilePath = $IntuneAppFilePath
            DisplayName = $ApplicationDisplayName
            InstallCommandLine = $InstallCommandLine
            UninstallCommandline = $UninstallCommandLine
            InstallExperience = "system"
            #Icon = $imgFile
            Description = $ApplicationDescription
            Publisher = $ApplicationPublisherName
        }

        if ($IconFilePath) {
            $imgFile = New-IntuneWin32AppIcon -FilePath $IconFilePath
            $appCreateParam.Add("Icon",$imgFile)
        }
        Write-Verbose "Creating Intune Application: $ApplicationDisplayName"
        Add-IntuneWin32App @appCreateParam
    }
}