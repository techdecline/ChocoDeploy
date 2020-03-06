

# unpublished functions
. $PSScriptRoot\function-New-ChocoCMDeploymentType.ps1
. $PSScriptRoot\function-Convert-ChocoCMTag.ps1
. $PSScriptRoot\function-Add-ChocoCMDependency.ps1

# published functions
. $PSScriptRoot\function-New-ChocoCMApplication.ps1
. $PSScriptRoot\function-New-ChocoCMClientApllication.ps1

Export-ModuleMember -Function New-ChocoCMApplication,New-ChocoCMClientApllication