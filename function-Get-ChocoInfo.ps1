<#
    .SYNOPSIS
    Get-Choco queries the Chocolatey Package Repository for a given PackageName.
    .DESCRIPTION
    Get-Choco queries the Chocolatey Package Repository for a given PackageName and returns a custom object containing the name, the author and a path to a temporarily downloaded image.
    .EXAMPLE

    PS> Get-ChocoInfo -PackageName Chrome
#>
function Get-ChocoInfo {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [String[]]$PackageName
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
                $chocoObj = ConvertTo-ChocoData -ChocoInfo $cmdRtn
                $webData = Get-ChocoWebData -PackageName $package
                $chocoObj = $chocoObj | Select-Object -Property *,@{Name = "ImageUrl";Expression = {$webData.ImageUrl}},@{Name = "Author";Expression = {$webData.Author}}
                $rtnObj += $chocoObj
            }
            else {
                Write-Verbose "No such package: $package"
            }
        }
    }

    end {
        return $rtnObj
    }
}