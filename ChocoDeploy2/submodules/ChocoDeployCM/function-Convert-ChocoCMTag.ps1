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
        $tagMod = $tag -split " "
        return $tagMod
    }
}