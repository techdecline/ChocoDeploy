<#
    .SYNOPSIS
    .DESCRIPTION
    .EXAMPLE
#>
function Convert-ChocoCMTag {
    [CmdletBinding(DefaultParameterSetName)]
    param (
        # Tag to be shortend
        [Parameter(Mandatory,ValueFromPipeline,Position=0)]
        [String]
        $Tag
    )

    process {
        $tagMod = ($Tag -split " " ) -join ", "
        return $tagMod
    }
}