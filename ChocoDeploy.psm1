# Implement your module commands in this script.

#region Helper functions
#. $PSScriptRoot\function-ConvertTo-ChocoData.ps1
. $PSScriptRoot\function-Test-ChocoPackage.ps1
#. $PSScriptRoot\function-Get-ChocoWebData.ps1
. $PSScriptRoot\function-Get-ChocoApiData.ps1

#endregion

#region Exported functions
. $PSScriptRoot\function-Get-ChocoInfo.ps1
. $PSScriptRoot\function-New-ChocoApp.ps1
. $PSScriptRoot\function-ConvertFrom-Svg.ps1
. $PSScriptRoot\function-Get-ChocoImage.ps1
. $PSScriptRoot\function-Resize-ChocoImage.ps1
#endregion

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function Get-ChocoInfo,New-ChocoApp,ConvertFrom-Svg,Get-ChocoImage