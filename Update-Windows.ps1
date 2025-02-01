#=============================================================================================================================
#
# Script Name:     Update-Windows.ps1
# Description:     Install Windows Updates
# Created:         01/30/2025
# Updated:
# Version:         1.0
#
#=============================================================================================================================

$Title = "Install Windows Updates"
$host.UI.RawUI.WindowTitle = $Title
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

$env:APPDATA = "C:\Windows\System32\Config\SystemProfile\AppData\Roaming"
$env:LOCALAPPDATA = "C:\Windows\System32\Config\SystemProfile\AppData\Local"
$Env:PSModulePath = $env:PSModulePath+";C:\Program Files\WindowsPowerShell\Scripts"
$env:Path = $env:Path+";C:\Program Files\WindowsPowerShell\Scripts"

Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null}
$Global:Transcript = "Update-Windows.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

# Install latest NuGet package provider
Write-Host -ForegroundColor Green "Install latest NuGet package provider"
Install-PackageProvider -Name "NuGet" -Force -ErrorAction SilentlyContinue -Verbose:$true
    
# Ensure default PSGallery repository is registered
Write-Host -ForegroundColor Green "Ensure default PSGallery repository is registered"
Register-PSRepository -Default -ErrorAction SilentlyContinue

# Attempt to get the installed PowerShellGet module
Write-Host -ForegroundColor Green "Attempt to get the installed PowerShellGet module"
$PowerShellGetInstalledModule = Get-InstalledModule -Name "PowerShellGet" -ErrorAction SilentlyContinue -Verbose:$true
if ($PowerShellGetInstalledModule) {
        # Attempt to locate the latest available version of the PowerShellGet module from repository
        Write-Host -ForegroundColor Green "Attempt to locate the latest available version of the PowerShellGet module from repository"
        $PowerShellGetLatestModule = Find-Module -Name "PowerShellGet" -ErrorAction SilentlyContinue -Verbose:$true
        if ($PowerShellGetLatestModule) {
                if ($PowerShellGetInstalledModule.Version -lt $PowerShellGetLatestModule.Version) {
                        Update-Module -Name "PowerShellGet" -Scope "AllUsers" -Force -ErrorAction SilentlyContinue -Confirm:$false -Verbose:$true
                }
        }
        else {

        }
}
else {
        # PowerShellGet module was not found, attempt to install from repository
        Write-Host -ForegroundColor Yellow "PowerShellGet module was not found, attempt to install from repository"
        Install-Module -Name "PackageManagement" -Force -Scope AllUsers -AllowClobber -ErrorAction SilentlyContinue -Verbose:$true
        Install-Module -Name "PowerShellGet" -Force -Scope AllUsers -AllowClobber -ErrorAction SilentlyContinue -Verbose:$true
}

Write-Host -ForegroundColor Green "Install Module PSWindowsUpdate"
Install-Module -Name PSWindowsUpdate -Force -Scope AllUsers -AllowClobber
Import-Module PSWindowsUpdate -Scope Global
Write-Host -ForegroundColor Green "Get Windows Updates"
Get-WindowsUpdate
Write-Host -ForegroundColor Green "Install Windows Updates"
Install-WindowsUpdate -AcceptAll -IgnoreReboot

Stop-Transcript | Out-Null