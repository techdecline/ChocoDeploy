$ModuleManifestName = 'ChocoDeploy.psd1'
$ModuleName = ($ModuleManifestName -split "\.")[0]
$ModuleManifestPath = "$PSScriptRoot\..\$ModuleManifestName"

Describe "$ModuleName Manifest Tests" {
    Context "Module Setup" {
        It 'Passes Test-ModuleManifest' {
            Test-ModuleManifest -Path $ModuleManifestPath
            $? | Should Be $true
        }

        It  "Has Root Module $ModuleName.psm1" {
            "$PSScriptRoot\..\$ModuleName.psm1" | Should exist
        }

        It "$moduleName is valid PowerShell code" {
            $psFile = Get-Content -Path "$PSScriptRoot\..\$moduleName.psm1" `
                                  -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
            $errors.Count | Should Be 0
        }

        It "$ModuleName has functions" {
            "$PSScriptRoot\..\function-*.ps1" | should exist
        }
    }

    $functionArr = ("Get-ChocoInfo","ConvertTo-ChocoData","Test-ChocoPackage","Get-ChocoApiData")

    foreach ($functionStr in $functionArr ) {
        Context "Test function $functionStr" {
            It "$functionStr.ps1 should exist" {
                "$PSScriptRoot\..\function-$functionStr.ps1" | should exist
            }

            It "$functionStr.ps1 should have a help block" {
                "$PSScriptRoot\..\function-$functionStr.ps1" | Should Contain '<#'
                "$PSScriptRoot\..\function-$functionStr.ps1" | Should Contain '#>'
            }

            It "$functionStr.ps1 should have a SYNOPSIS in the help block" {
                "$PSScriptRoot\..\function-$functionStr.ps1" | Should Contain 'SYNOPSIS'
            }

            It "$functionStr.ps1 should have a DESCRIPTION in the help block" {
                "$PSScriptRoot\..\function-$functionStr.ps1" | Should Contain 'DESCRIPTION'
            }

            It "$functionStr.ps1 should have a EXAMPLE in the help block" {
                "$PSScriptRoot\..\function-$functionStr.ps1" | Should Contain 'EXAMPLE'
            }

            It "$functionStr.ps1 should be an advanced function" {
                "$PSScriptRoot\..\function-$functionStr.ps1" | Should Contain 'function'
                "$PSScriptRoot\..\function-$functionStr.ps1" | Should Contain 'cmdletbinding'
                "$PSScriptRoot\..\function-$functionStr.ps1" | Should Contain 'param'
            }
              <#
              It "$functionStr.ps1 should contain Write-Verbose blocks" {
                "$PSScriptRoot\..\function-$functionStr.ps1" | Should Contain 'Write-Verbose'
            }
                #>
            It "$functionStr.ps1 is valid PowerShell code" {
                $psFile = Get-Content -Path "$PSScriptRoot\..\function-$functionStr.ps1" `
                                      -ErrorAction Stop
                $errors = $null
                $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
                $errors.Count | Should Be 0
            }
        }

        Context "$functionStr has tests" {
            It "$PSScriptRoot\function-$functionStr.Tests.ps1 should exist" {
                "$PSScriptRoot\function-$functionStr.Tests.ps1" | should exist
            }
        }
    }
}