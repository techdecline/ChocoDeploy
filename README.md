# ChocoDeploy
PowerShell Module to import Chocolatey packages to various Configuration Management Systems

## How to use

### Prerequisites

* PowerShell 5.0+ (No PS 6 Support as of now)
* Chocolatey installed (see https://chocolatey.org/install)
* Configuration Manager Console installed (for ConfigMgr Application Creation)
* Internet connectivity

### Step by Step (ConfigMgr)

1. Download and install module from PowerShell Gallery.
2. Import Module
3. Create JSON File
`PS> Get-ChocoInfo -PackageName GoogleChrome -OutputPath "$Env:temp\"`
4. Create Application
`PS> New-ChocoApp -JsonFile $env:Temp\GoogleChrome.json -CMSiteCode CM1: -CMSiteServerFQDN sccm.contoso.com`
5. Check newly created App in Console and deploy it.

### Step by Step (Intune)
1. Download and install module from PowerShell Gallery.
2. Import Module
3. Create JSON File
`PS> Get-ChocoInfo -PackageName Winrar -OutputPath "$Env:temp\"`
4. Create Win32 App Package for Intune
`PS>New-ChocoApp -PackageFolder C:\Temp\Winrar.json -IntuneWinAppExePath C:\Users\schuchardt\Downloads\Microsoft-Win32-Content-Prep-Tool-1.6\IntuneWinAppUtil.exe -Win32AppPath c:\Temp -Verbose`
5. Upload generated Intunwin file in Intune portal and deploy manually

## Current State

* Query choco catalog for package name (Get-ChocoInfo) using Chocolatey API
* Create custom Object with all relevant metadata (Name, Description, Author, Version, ImageUrl, Tags)
* ConfigMgr App Creation
* SVG to jpeg Conversion