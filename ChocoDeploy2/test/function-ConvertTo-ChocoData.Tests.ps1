$moduleName = "ChocoDeploy"
Remove-Module $moduleName -Force -ErrorAction SilentlyContinue

Import-Module "$PSScriptRoot\..\$moduleName.psd1"

Describe "ConvertTo-ChocoData Tests" {

}