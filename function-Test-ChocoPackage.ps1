<#
    .SYNOPSIS
    Tests for exact existence of a Chocolatey Package.
    .DESCRIPTION
    Tests for exact existence of a Chocolatey Package and return either true or false
    .EXAMPLE
    PS> Test-ChocoPackage -PackageName GoogleChrome

    $true
#>
function Test-ChocoPackage {
    [CmdletBinding()]
    param (
        # Package Name to query
        [Parameter(Mandatory,ValueFromPipeline)]
        [String]
        $PackageName
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
        Write-Verbose "Looking up package: $package"
        $cmd = $chocoExe + " search " + $package + " --exact"
        Write-Verbose "Native command is: $cmd"
        $cmdRtn = Invoke-Expression $cmd
        Write-Verbose "Chocolatey return was: $cmdRtn"
        if ($cmdRtn[-1] -match "1 packages found.") {
            return $true
        }
        else {
            Write-Warning "No such package: $PackageName"
            return $false
        }
    }
}