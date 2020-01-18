# Package MSI as .intunewin file
$SourceFolder = "C:\IntuneWinAppUtil\Source\7-Zip"
$SetupFile = "7z1900-x64.msi"
$OutputFolder = "C:\IntuneWinAppUtil\Output"
$Win32AppPackage = New-IntuneWin32AppPackage -SourceFolder $SourceFolder -SetupFile $SetupFile -OutputFolder $OutputFolder -Verbose

# Get MSI meta data from .intunewin file
$IntuneWinFile = $Win32AppPackage.Path
$IntuneWinMetaData = Get-IntuneWin32AppMetaData -FilePath $IntuneWinFile

# Create custom display name like 'Name' and 'Version'
$DisplayName = $IntuneWinMetaData.ApplicationInfo.Name + " " + $IntuneWinMetaData.ApplicationInfo.MsiInfo.MsiProductVersion

# Create MSI detection rule
$DetectionRule = New-IntuneWin32AppDetectionRule -MSI -MSIProductCode $IntuneWinMetaData.ApplicationInfo.MsiInfo.MsiProductCode

# Create custom return code
$ReturnCode = New-IntuneWin32AppReturnCode -ReturnCode 1337 -Type "retry"

# Convert image file to icon
$ImageFile = "C:\IntuneWinAppUtil\Logos\7-Zip.png"
$Icon = New-IntuneWin32AppIcon -FilePath $ImageFile

# Add new MSI Win32 app
$Win32App = Add-IntuneWin32App -TenantName "name.onmicrosoft.com" -FilePath $IntuneWinFile -DisplayName $DisplayName -InstallExperience "system" -RestartBehavior "suppress" -DetectionRule $DetectionRule -ReturnCode $ReturnCode -Icon $Icon -Verbose

# Add assignment for all users
Add-IntuneWin32AppAssignment -TenantName "name.onmicrosoft.com" -DisplayName $Win32App.displayName -Target "AllUsers" -Intent "available" -Notification "showAll" -Verbose