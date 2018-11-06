# downloaded from https://github.com/Microsoft/Intune-PowerShell-SDK
import-module C:\Users\schuchardt\Downloads\Intune-PowerShell-SDK_v6.1811.0.4-preview\Release\net471\Microsoft.Graph.Intune.psd1

# connect to MS Graph
Connect-MSGraph

# Create an App
Get-DeviceAppManagement_MobileApps | select '@odata.type' -Unique

# currently no support for intunewin apps --> halting