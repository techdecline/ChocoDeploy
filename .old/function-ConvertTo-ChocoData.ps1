<#
    .SYNOPSIS
    Parses Chocolatey Info Block.
    .DESCRIPTION
    Parses Chocolatey Info Block and returns Name, Description and Tags.
    .EXAMPLE
    PS> ConvertTo-ChocoData -ChocoInfo (Get-Content ".\chrome.txt")

    PackageName  Description                                                                  Tags
    -----------  -----------                                                                  ----
    GoogleChrome  Chrome is a fast, simple, and secure web browser, built for the modern web.  google chrome web internet browser admin
#>
function ConvertTo-ChocoData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Object[]]$ChocoInfo
    )

    process {
        $Title = $ChocoInfo[1]
        $DisplayName = (($ChocoInfo[2].trim() -replace "^Title: ","") -replace "\|.*$").trim()
        # $Description = $ChocoInfo[12] -replace "^.*:",""
        $Description = $ChocoInfo | Where-Object {$_.Trim() -match "^Description:.*"}
        $tags = $ChocoInfo[9]

        $rtnObj = 1 | Select-Object @{Name = "PackageName";Expression = {($Title -split " ")[0]}},@{Name = "PackageVersion";Expression = {($Title -split " ")[1]}},@{Name = "DisplayName";Expression = {$DisplayName}},@{Name = "Description";Expression = {($Description -replace "^.*:","").Trim()}},@{Name = "Tags";Expression = {($tags -split "^.*: ","")[1]}}
        return $rtnObj
    }
}