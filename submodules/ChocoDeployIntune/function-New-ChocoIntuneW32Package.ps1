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
        $intuneWinFile = Join-Path $PackageFolder -ChildPath "$$(packageName)_install.intunewin"
        #Write-Verbose "Will Create Intunewinfile: $intuneWinFile"
        $cmd = $IntuneWinAppUtilExe + " -c $PackageFolder -s $($PackageName)_install.cmd -o $PackageFolder -q"
        #return $cmd
        Write-Verbose "Command line is: $cmd"
        Invoke-Expression $cmd | Out-Null

        if (Test-Path $intuneWinFile) {
            return $intuneWinFile
        }
        else {
            "Could not create Intune W32 package"
        }
    }
}

#New-ChocoIntuneW32Package -PackageFolder C:\Sys\git -IntuneWinAppUtilExe "C:\Users\administrator\Downloads\Intune-Win32-App-Packaging-Tool-1.3\Intune-Win32-App-Packaging-Tool-1.3\IntuneWinAppUtil.exe" -Verbose