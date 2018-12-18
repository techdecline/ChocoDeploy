# Implement your module commands in this script.

#region Helper functions
. .\function-ConvertTo-ChocoData.ps1
. .\function-Test-ChocoPackage.ps1
. .\function-Get-ChocoWebData.ps1
. .\function-New-ChocoCMApplication.ps1
. .\function-New-ChocoCMDeploymentType.ps1
. .\function-Get-ChocoCMImage.ps1
. .\function-Convert-ChocoCMTag.ps1
. .\function-Add-ChocoCMDependency.ps1

#endregion

#region Exported functions
. .\function-Get-ChocoInfo.ps1
. .\function-New-ChocoApp.ps1
#endregion

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function Get-ChocoInfo,New-ChocoApp