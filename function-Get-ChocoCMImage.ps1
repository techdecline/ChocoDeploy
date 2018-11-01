<#
    .SYNOPSIS
    .DESCRIPTION
    .EXAMPLE
#>
function Get-ChocoCMImage {
    [CmdletBinding()]
    param (
        # Provide Download URL
        [Parameter(Mandatory,ValueFromPipeline,Position=0)]
        [ValidateScript({Invoke-webrequest -uri $_ -usebasicparsing})]
        [String]
        $ImageUrl,

        # Optional Download Location
        [Parameter(Mandatory=$false)]
        [ValidateScript({TEst-Path $_})]
        [String]
        $DownloadLocation = $env:TEMP,

        # Toggle Resize
        [Parameter(Mandatory=$false)]
        [Switch]
        $DoNotResize
    )

    process {
        # download image
        $fileName = Split-Path $ImageUrl -Leaf
        Write-Verbose "Download Location will be: $fileName"
        if ($fileName -notmatch ".*svg$") {
            $outputPath = Join-Path $DownloadLocation -ChildPath $fileName
            if ( Test-Path $outputPath )
            {
                Remove-Item $outputPath -Force
            }
            try {
                Invoke-WebRequest -Uri $ImageUrl -OutFile $outputPath -ErrorAction Stop -UseBasicParsing
                Write-Verbose "Image $ImageUrl has been downloaded to $outputPath"

                if (-not ($DoNotResize)) {
                    $resizeOutputPath = Join-Path -Path (Split-Path $outputPath -Parent) -ChildPath ("resize_" + $fileName)
                    Resize-Image -InputFile $outputPath -OutputFile $resizeOutputPath -Width 250 -Height 250
                    return $resizeOutputPath
                }

                return $outputPath
            }
            catch [System.Management.Automation.ActionPreferenceStopException] {
                Write-Error "Could not download image"
            }
        }
        else {
            Write-Verbose "Unsupported File Type (.svg)"
            return $null
        }
    }
}