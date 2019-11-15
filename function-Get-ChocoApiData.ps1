function Get-ChocoApiData {
    [CmdletBinding()]
    param (
        [String]$PackageName,
        [String]$TempDirectory = $env:TEMP
    )

    process {
        $packageUri = "https://chocolatey.org/api/v2/package/" + $PackageName
        $tmpFilePath = (Join-Path -Path $TempDirectory -ChildPath "$PackageName.nupkg")
        $tmpDirectory = Join-Path -Path $TempDirectory -ChildPath $PackageName
        try {
            Invoke-WebRequest -Uri $packageUri -OutFile $tmpFilePath -ErrorAction Stop -ErrorVariable webError | Out-Null
        }
        catch [System.Management.Automation.ActionPreferenceStopException] {
            Write-Warning "Could not invoke web request"
            return $webError
        }

        Expand-Archive -Path $tmpFilePath -DestinationPath $tmpDirectory -Force
        $nuspecFilePath = Join-Path $tmpDirectory -ChildPath "$PackageName.nuspec"
        [xml]$nuspecXml = Get-Content $nuspecFilePath
        $returnObj = 1 | select-object -property @{Name = "PackageName";Expression={$PackageName}},
                                                    @{Name = "PackageVersion"; Expression = {$nuspecXml.package.metadata.version}},
                                                    @{Name = "DisplayName"; Expression = {$nuspecXml.package.metadata.title}},
                                                    @{Name = "Description"; Expression = {$nuspecXml.package.metadata.description}},
                                                    @{Name = "tags"; Expression = {$nuspecXml.package.metadata.tags}},
                                                    @{Name = "ImageUrl"; Expression = {$nuspecXml.package.metadata.iconUrl}},
                                                    @{Name = "Author"; Expression = {$nuspecXml.package.metadata.authors}}

        remove-item $tmpFilePath
        Remove-Item $tmpDirectory
        return $returnObj
    }
}