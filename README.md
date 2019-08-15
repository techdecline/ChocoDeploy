# ChocoDeploy
PowerShell Module to import Chocolatey packages to various Configuration Management Systems

## How to use

### Prerequisites

* PowerShell 5.0+ (No PS 6 Support as of now)
* Chocolatey installed (see https://chocolatey.org/install)
* Configuration Manager Console installed (for ConfigMgr Application Creation)
* Internet connectivity
* Download Script **Resize-Image** from Technet Gallery (https://gallery.technet.microsoft.com/scriptcenter/Resize-Image-File-f6dd4a56)

### Step by Step (ConfigMgr)

1. Download and install module.
2. Import Module
3. Create JSON File
`PS> Get-ChocoInfo -PackageName GoogleChrome -OutputPath "$Env:temp\"`
4. Create Application
`PS> New-ChocoApp -JsonFile $env:Temp\GoogleChrome.json -CMSiteCode CM1: -CMSiteServerFQDN sccm.contoso.com`
5. Check newly created App in Console and deploy it.

## Current State

* Query choco catalog for package name (Get-ChocoInfo)
* Create custom Object with all relevant metadata (Name, Description, Author, Version, ImageUrl, Tags)
* ConfigMgr App Creation

### WIP

#### Intune App Creation
- [X] Automatically create intunewin package containing install, uninstall and detection script per package
- [ ] Implement https://github.com/microsoftgraph/Intune-PowerShell-SDK-Code-Generator for App creation
- [ ] Combine scripts into ChocoDeployIntune Module
- [ ] Update root scripts to support Intune app creation

### Backlog

* App-V Auto Sequencer

## How to get involved?
Test, Test, Test, report bugs ;-)
