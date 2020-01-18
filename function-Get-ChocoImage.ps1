<#
    .SYNOPSIS
    .DESCRIPTION
    .EXAMPLE
#>
function Get-ChocoImage {
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
        $outputPath = Join-Path $DownloadLocation -ChildPath $fileName
        if ( Test-Path $outputPath )
        {
            Remove-Item $outputPath -Force
        }
        try {
            Invoke-WebRequest -Uri $ImageUrl -OutFile $outputPath -ErrorAction Stop -UseBasicParsing
            Write-Verbose "Image $ImageUrl has been downloaded to $outputPath"
            switch ((get-item $outputPath).Extension) {
                ".svg" {
                    Write-Verbose "Converting Image from svg"
                    $newOutputPath = $outputPath -replace "svg","jpeg"
                    Write-Verbose "New path: $newOutputPath"
                    if (ConvertFrom-Svg -SourceFile $outputPath) {
                        Write-Verbose "Returning new path: $newOutputPath"
                        return $newOutputPath
                    }
                    else {
                        return $null
                    }
                }
                Default {
                    Write-Verbose "Resizing Image"
                    if (Resize-Image -SourceFile $outputPath) {
                        return $outputPath
                    }
                    else {
                        return $false
                    }
                }
            }
            return $outputPath
        }
        catch [System.Management.Automation.ActionPreferenceStopException] {
            Write-Error "Could not download image"
        }
    }
}