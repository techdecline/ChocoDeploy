function Resize-ChocoImage {
    [CmdletBinding()]
    param (
        # Image File Path
        [Parameter(Mandatory=$true,ValueFromPipeline)]
        [ValidateScript({Test-Path $_})]
        [String]$FilePath,

        # New Height
        [Parameter(Mandatory=$false)]
        [ValidateRange(1,512)]
        [Int]
        $Height = 256,

        # New Width
        [Parameter(Mandatory=$false)]
        [ValidateRange(1,512)]
        [Int]
        $Width = 256
    )

    function Resize-ToBitmap {
        param (
            # Image Object
            [Parameter(Mandatory)]
            [System.Drawing.Image]$ImageObject,

            # New Height
           [Parameter(Mandatory)]
           [ValidateRange(1,512)]
           [Int]
           $Height,

           # New Width
           [Parameter(Mandatory)]
           [ValidateRange(1,512)]
           [Int]
           $Width
       )
       try {
           $bitMapObj = [System.Drawing.Bitmap]::new($Height,$Width)
           [System.Drawing.Graphics]::FromImage($bitMapObj).DrawImage($ImageObject,0,0,$Width,$Height)
           return ([System.Drawing.Bitmap]::new($bitMapObj))
       }
       catch [System.Exception] {
           throw "Could not resize Image Object: $($error[0].Exception.Message)"
       }
    }

    function Save-ToTemp {
        param (
            # Bitmap Object
            [Parameter(Mandatory,ValueFromPipeline)]
            [System.Drawing.Bitmap]
            $BitmapObject
        )
        try {
           $tempFile = [System.IO.Path]::GetTempFileName()
           Write-Verbose "Saving Bitmap Object to: $tempFile"
           $BitmapObject.Save($tempFile)
           $BitmapObject.Dispose()
       }
       catch [System.Exception] {
           throw "Could not save Image File: $($error[0].Exception.Message)"
       }
       return $tempFile
    }

    try {
        Write-Verbose "Resizing Image"

    }
    catch [System.Exception] {
        throw "Could not resize image: $($error[0].Exception.Message)"
    }
    $memoryByteArr = [System.IO.File]::ReadAllBytes($FilePath)
    $stream = [System.IO.MemoryStream]::new($memoryByteArr)
    $imageObject = [System.Drawing.Image]::FromStream($stream)
    #$tempFile = Resize-ToBitmap -ImageObject ([System.Drawing.Image]::FromFile($FilePath)) -Width $Width -Height $Height | Save-ToTemp
    $tempFile = Resize-ToBitmap -ImageObject $imageObject -Width $Width -Height $Height | Save-ToTemp

    try {
        Write-Verbose "Overwriting original file: $FilePath"
        Remove-Item $FilePath -Force -ErrorAction Stop
        Move-Item $tempFile -Destination $FilePath -ErrorAction Stop
    }
    catch {
        throw "Could not overwrite original file: $($error[0].Exception.Message)"
    }
    return (get-item $FilePath)
}


