try {
    $Global:chocoExe = (Get-Command "choco.exe" -ErrorAction Stop  | Where-Object {$_.CommandType -eq "Application"}).Source
    $Global:ModuleRoot = $PSScriptRoot
    Write-Verbose "Detected Chocolatey executable in: $chocoExe"
}
catch [System.Management.Automation.CommandNotFoundException] {
    $Global:chocoExe = $null
    Write-Error -Message "Could not find Chocolatey Executable."
    Remove-Module ChocoDeploy -Force
}