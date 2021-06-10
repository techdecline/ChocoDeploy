function New-ChocoDeploymentType
{
    param (
        $ApplicationName,
        $ChocolateyExe = $Global:chocoExe,
        $ChocolateyLocation = '%ChocolateyInstall%'
    )

    $installCmd = $ChocolateyExe + " install " + $ApplicationName + " -y"
    $uninstallCmd = $ChocolateyExe + " uninstall " + $ApplicationName + " -y"
    $dtName = "CHOCO_" + $ApplicationName

    $scriptBlock = @"
    `$cmdReturn = Invoke-Expression "choco list --local-only --exact $ApplicationName"
    if (`$cmdReturn -eq "0 packages installed.")
    {
        return
    }
    else
    {
        return `$true
    }
"@


    $depTypeObj = Add-CMScriptDeploymentType -DeploymentTypeName $dtName -InstallCommand $installCmd `
        -InstallWorkingDirectory $ChocolateyLocation -UninstallCommand $uninstallCmd `
        -UninstallWorkingDirectory $ChocolateyLocation -ApplicationName $ApplicationName `
        -LogonRequirementType WhetherOrNotUserLoggedOn -ScriptLanguage PowerShell -ScriptText $scriptBlock `
        -InstallationBehaviorType InstallForSystem -UserInteractionMode Hidden -ErrorAction SilentlyContinue -Verbose:$false

    return $depTypeObj
}
