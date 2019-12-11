function Resize-Image {
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
        [Chocodeploy.ConvertIcon]::ResizeImageFile($SourceFile,(Split-Path -Path $SourceFile -Parent))
        return $true
    }
    catch {
        return $false
    }
}


