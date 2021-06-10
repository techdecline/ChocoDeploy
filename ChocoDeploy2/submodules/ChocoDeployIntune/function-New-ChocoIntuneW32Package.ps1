function New-ChocoIntuneW32Package {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline,Position=0)]
        [ValidateScript({Test-Path $_})]
        [String]$PackageFolder,

        [Parameter(Mandatory)]
        [ValidateScript({Test-Path $_})]
        [String]$IntuneWinAppUtilExe,

        # Enter Package installer (optional)
        [Parameter(Mandatory=$false)]
        [String]$SetupFileName
    )

    process {
        $packageName = Split-Path $PackageFolder -Leaf
        Write-Verbose "Package name is: $packageName"
        Write-Verbose "Will Create Intunewinfile: $intuneWinFile"
        if (-not ($SetupFileName)) {
            $cmdParam = "-c $PackageFolder -s $($PackageName)_install.cmd -o $PackageFolder -q"
            $intuneWinFile = Join-Path $PackageFolder -ChildPath "$($packageName)_install.intunewin"
        }
        else {
            $cmdParam = "-c $PackageFolder -s $SetupFileName -o $PackageFolder -q"
            $intuneWinFile = Join-Path $PackageFolder -ChildPath ($SetupFileName -replace "\..*$",".intunewin")
        }

        Write-Verbose "Attribute list is: $cmdParam"
        Start-Process -FilePath $IntuneWinAppUtilExe -ArgumentList $cmdParam -Wait

        if (Test-Path $intuneWinFile) {
            return $intuneWinFile
        }
        else {
            write-warning "Could not create Intune W32 package: $($error[0].exception.message)"
            return
        }
    }
}