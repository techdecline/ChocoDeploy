<#
    .SYNOPSIS
    .DESCRIPTION
    .EXAMPLE
#>
function ConvertFrom-Svg {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]$SourceFile,

        [Parameter(Mandatory=$false)]
        [ValidateScript({Test-Path $_})]
        [String]$Destination = (Split-Path -Path $SourceFile -Parent)
    )

    [System.Reflection.Assembly]::LoadFile((join-path -Path $Global:ModuleRoot -ChildPath "lib\Svg.dll"))
    [System.Reflection.Assembly]::LoadFile((join-path -Path $Global:ModuleRoot -ChildPath "lib\SvgConvert.dll"))

    try {
        [Chocodeploy.ConvertIcon]::ConvertSvg($SourceFile,$Destination)
        return $true
    }
    catch {
        return $false
    }
}