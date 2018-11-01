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
        [ValidateScript({Invoke-webrequest -uri $_})]
        [String]
        $ImageUrl,

        # Optional Download Location
        [Parameter(Mandatory=$false)]
        [ValidateScript({TEst-Path $_})]
        [String]
        $DownloadLocation = $env:TEMP
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
                Invoke-WebRequest -Uri $ImageUrl -OutFile $outputPath -ErrorAction Stop
                Write-Verbose "Image $ImageUrl has been downloaded to $outputPath"
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