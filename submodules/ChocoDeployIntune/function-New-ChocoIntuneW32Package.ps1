function New-ChocoIntuneW32Package {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline,Position=0)]
        [ValidateScript({Test-Path $_})]
        [String]$PackageFolder,

        [Parameter(Mandatory)]
        [ValidateScript({Test-Path $_})]
        [String]$IntuneWinAppUtilExe
    )

    process {
        $packageName = Split-Path $PackageFolder -Leaf
        Write-Verbose "Package name is: $packageName"
        $intuneWinFile = Join-Path $PackageFolder -ChildPath "$($packageName)_install.intunewin"
        Write-Verbose "Will Create Intunewinfile: $intuneWinFile"
        $cmdParam = "-c $PackageFolder -s $($PackageName)_install.cmd -o $PackageFolder -q"
        Write-Verbose "Attribute list is: $cmdParam"
        Start-Process -FilePath $IntuneWinAppUtilExe -ArgumentList $cmdParam -Wait

        if (Test-Path $intuneWinFile) {
            return $intuneWinFile
        }
        else {
            "Could not create Intune W32 package"
        }
    }
}