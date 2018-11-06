function New-ChocoIntuneW32AppSources {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline,Position=0)]
        [ValidateScript({Test-path $_})]
        [String]$JsonFile,

        [Parameter(Mandatory=$false)]
        [ValidateScript({Test-Path $_})]
        [String]$PackagePath
    )

    process {
        $jsonFullName = (get-item $JsonFile).FUllName
        $packageObj = get-content $jsonFullName | ConvertFrom-Json -ErrorAction Stop

        $pkgFolder = New-Item (Join-Path $PackagePath -ChildPath $packageObj.PackageName) -ItemType DIrectory -Force

        $installCmd = "choco install " + $packageObj.PackageName + " -y"
        $uninstallCmd = "choco uninstall " + $packageObj.PackageName + " -y"
        $detectCmd = @"
`$cmdReturn = Invoke-Expression "choco list --local-only $($packageObj.PackageName)"
if (`$cmdReturn -eq "0 packages installed.")
{
    return
}
else
{
    return `$true
}
"@


        $installCmd |Out-File -FilePath (Join-Path $pkgFolder.FullName -ChildPath ($packageObj.PackageName + "_install.cmd"))
        $uninstallCmd |Out-File -FilePath (Join-Path $pkgFolder.FullName -ChildPath ($packageObj.PackageName + "_uninstall.cmd"))
        $detectCmd | Out-File -FilePath (Join-Path $pkgFolder.FullName -ChildPath ($packageObj.PackageName + "_detect.ps1"))

        return $pkgFolder.FullName
    }
}

# New-ChocoIntuneW32AppSources -JsonFile C:\sys\git.json -PackagePath C:\Sys