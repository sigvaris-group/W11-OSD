#=============================================================================================================================
#
# Script Name:     Remove-WSUS.ps1
# Description:     Remove WSUS Settings
# Created:         03/17/2025
# Updated:         
# Version:         1.0
#
#=============================================================================================================================

$Title = "Remove WSUS Settings"
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
$Global:Transcript = " Remove-WSUS.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

# Stop the Windows Update service
Write-Host -ForegroundColor Green "Stop the Windows Update service"
Stop-Service -Name wuauserv -ErrorAction SilentlyContinue

#===================================================================================================================================================
#   Remediate Windows Update policy conflict for Autopatch
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Remediate Windows Update policy conflict for Autopatch"
# initialize the array
[PsObject[]]$regkeys = @()
# populate the array with each object
$regkeys += [PsObject]@{ Name = "DoNotConnectToWindowsUpdateInternetLocations"; path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"}
$regkeys += [PsObject]@{ Name = "DisableWindowsUpdateAccess"; path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"}
$regkeys += [PsObject]@{ Name = "WUServer"; path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"}
$regkeys += [PsObject]@{ Name = "UseWUServer"; path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\"}
$regkeys += [PsObject]@{ Name = "NoAutoUpdate"; path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\"}

foreach ($setting in $regkeys)
{
    write-host "checking $($setting.name)"
    if((Get-Item $setting.path -ErrorAction Ignore).Property -contains $setting.name)
    {
        write-host "remediating $($setting.name)"
        Remove-ItemProperty -Path $setting.path -Name $($setting.name)
    }
    else
    {
        write-host "$($setting.name) was not found"
    }
}