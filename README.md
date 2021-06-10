# ChocoDeploy
PowerShell Module to import Chocolatey packages to various Configuration Management Systems

## How to use

### Prerequisites

* PowerShell 5.0+ (No PS 6 Support as of now)
* Chocolatey installed (see https://chocolatey.org/install)
* Configuration Manager Console installed (for ConfigMgr Application Creation)
* Microsoft Win32 Content Prep Tool (see https://github.com/Microsoft/Microsoft-Win32-Content-Prep-Tool)
* Internet connectivity

### Step by Step (ConfigMgr)

1. Download and install module from PowerShell Gallery.
2. Import Module
3. Create Chocolatey Client App
`New-ChocoClientApp -CMSiteCode DEC: -CMSiteServerFQDN cm001.declinelab.com -CMApplicationPath \\cm001\apps`
4. Create JSON File
`PS> Get-ChocoInfo -PackageName GoogleChrome -OutputPath "$Env:temp\"`
5. Create Application
`PS> New-ChocoApp -JsonFile $env:Temp\GoogleChrome.json -CMSiteCode CM1: -CMSiteServerFQDN sccm.contoso.com`
6. Check newly created App in Console and deploy it.

### Step by Step (Intune)
1. Download and install module from PowerShell Gallery.
2. Import Module
3. Create JSON File
`PS> Get-ChocoInfo -PackageName Winrar -OutputPath C:\Code\Workbench\`
4. Create Win32 Chocolatey App for Intune
`New-ChocoClientApp -IntuneWinAppExePath C:\Code\Workbench\Microsoft-Win32-Content-Prep-Tool-1.6\IntuneWinAppUtil.exe -Win32AppPath C:\Code\Workbench\ -TenantName declinelab.com`
5. Create Win32 App Package for Intune
`PS>New-ChocoApp -JsonFile C:\Code\Workbench\Winrar.json -IntuneWinAppExePath C:\Code\Workbench\Microsoft-Win32-Content-Prep-Tool-1.6\IntuneWinAppUtil.exe -TenantName declinelab.com -Verbose -Win32AppPath C:\Code\Workbench\`
6. Deploy the app from the Intune Portal

## Current State

* Query choco catalog for package name (Get-ChocoInfo) using Chocolatey API
* Create custom Object with all relevant metadata (Name, Description, Author, Version, ImageUrl, Tags)
* ConfigMgr App Creation
* Intune App Creation
* SVG to JPEG Conversion

## Open Work Items

* Provide mechanism to update Chocolatey Packages
* Pester Tests and documentation