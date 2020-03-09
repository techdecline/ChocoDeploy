function Resize-ChocoImage {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]$SourceFile,

        [Parameter(Mandatory=$false)]
        [ValidateScript({Test-Path $_})]
        [String]$Destination
    )

    if (-not ($Destination)) {
        $Destination = (Split-Path -Path $SourceFile -Parent)
    }
    [System.Reflection.Assembly]::LoadFile((join-path -Path $Global:ModuleRoot -ChildPath "lib\Svg.dll"))
    [System.Reflection.Assembly]::LoadFile((join-path -Path $Global:ModuleRoot -ChildPath "lib\SvgConvert.dll"))

    try {
        [Chocodeploy.ConvertIcon]::ResizeImageFile($SourceFile,$Destination)
        return $true
    }
    catch {
        return $false
    }
}


