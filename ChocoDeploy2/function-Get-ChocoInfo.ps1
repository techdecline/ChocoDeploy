<#
    .SYNOPSIS
    Get-Choco queries the Chocolatey Package Repository for a given PackageName.
    .DESCRIPTION
    Get-Choco queries the Chocolatey Package Repository for a given PackageName and returns a custom object containing the name, the author and a path to a temporarily downloaded image.
    .EXAMPLE

    PS> Get-ChocoInfo -PackageName GoogleChrome

    Returns Package Data Object for GoogleChrome

    .EXAMPLE

    PS> Get-ChocoInfo -PackageName GoogleChrome -OutputPath "$Env:temp\ChocoApp"

    Returns Package Data for Google Chrome as JSON File in $env:temp\ChocoApp
#>
function Get-ChocoInfo {
    [Cmdletbinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(Mandatory,ValueFromPipeline,Position=0)]
        [String[]]$PackageName,

        [Parameter(Mandatory,ParameterSetName="WithJson")]
        [ValidateScript({Test-Path $_})]
        [String]$OutputPath
    )

    begin {
        <#
        try {
            $chocoExe = (Get-Command "choco.exe" -ErrorAction Stop  | Where-Object {$_.CommandType -eq "Application"}).Source
            Write-Verbose "Detected Chocolatey executable in: $chocoExe"
        }
        catch [System.Management.Automation.CommandNotFoundException] {
            Write-Error -Message "Could not find Chocolatey Executable."
        }
        #>
    }
    process {
        $rtnObj = @()
        foreach ($package in $PackageName) {
            if (test-chocopackage -PackageName $package) {
                Write-Verbose "Fetching Data for package: $package"
                $cmd = $chocoExe + " info " + $package
                Write-Verbose "Native command is: $cmd"
                $cmdRtn = Invoke-Expression $cmd
                Write-Verbose "Chocolatey return was: $cmdRtn"
                $chocoObj = Get-ChocoApiData -PackageName $package
                # $webData = Get-ChocoWebData -PackageName $package
                # $chocoObj = $chocoObj | Select-Object -Property *,@{Name = "ImageUrl";Expression = {$webData.ImageUrl}},@{Name = "Author";Expression = {$webData.Author}}
                $rtnObj += $chocoObj
            }
            else {
                Write-Verbose "No such package: $package"
            }
        }
    }

    end {
        if ($OutputPath) {
            foreach ($pkgObj in $rtnObj) {
                Write-Verbose "JSON export has been selected."
                $jsonPath = Join-Path $OutputPath -ChildPath ($pkgObj.PackageName + ".json")
                Write-Verbose "Output Path will be: $jsonPath"
                try {

                    $pkgObj | ConvertTo-Json | Out-File $jsonPath -ErrorAction Stop -Force
                    Write-Verbose "Successfully saved JSON File"
                    return $jsonPath
                }
                catch [System.Management.Automation.ActionPreferenceStopException] {
                    Write-Warning "Could not save JSON file: $jsonPath"
                }
            }
        }
        else {
            return $rtnObj
        }
    }
}