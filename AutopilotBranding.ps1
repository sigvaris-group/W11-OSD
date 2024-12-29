#=============================================================================================================================
#
# Script Name:     AutopilotBranding.ps1
# Description:     Configure Windows Autopilot Branding
# Created:         12/29/2024
# Updated:
# Version:         1.0
#
#=============================================================================================================================

$Title = "Configure Windows Autopilot Branding"
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
$Global:Transcript = "AutopilotBranding.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

#===================================================================================================================================================
#   Load UIjson.json file
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Load C:\ProgramData\OSDeploy\UIjson.json file"
$json = Get-Content -Path "C:\ProgramData\OSDeploy\UIjson.json" -Raw | ConvertFrom-Json

# Access JSON properties
$OSDLanguage = $json.OSDLanguage
$OSDKeyboard = $json.OSDKeyboard
$OSDGeoID = $json.OSDGeoID
$OSDTimeZone = $json.OSDTimeZone

#===================================================================================================================================================
#   Enable location services so the time zone will be set automatically (even when skipping the privacy page in OOBE) when an administrator signs in
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Enable location services to automatically set the time zone"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type "String" -Value "Allow" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type "DWord" -Value 1 -Force
Start-Service -Name "lfsvc" -ErrorAction SilentlyContinue

Write-Host -ForegroundColor Green "Set TimeZone to $($OSDTimeZone)"
Set-TimeZone -Id $OSDTimeZone
tzutil.exe /s "$($OSDTimeZone)"

#===================================================================================================================================================
#   Don't let Edge create a desktop shortcut (roams to OneDrive, creates mess)
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Turning off (old) Edge desktop shortcut"
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v DisableEdgeDesktopShortcutCreation /t REG_DWORD /d 1 /f /reg:64 | Out-Host
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "CreateDesktopShortcutDefault" /t REG_DWORD /d 0 /f /reg:64 | Out-Host

#===================================================================================================================================================
#   Remove Personal Teams
#===================================================================================================================================================
Write-Host "STEP 4: Remove Personal Teams"
Get-AppxPackage -Name MicrosoftTeams -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue 

#===================================================================================================================================================
#   Disable WSUS
#===================================================================================================================================================
$currentWU = (Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ErrorAction Ignore).UseWuServer
if ($currentWU -eq 1)
{
	Write-Host "STEP 6: Turning off WSUS"
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU"  -Name "UseWuServer" -Value 0
	Restart-Service wuauserv
}

#===================================================================================================================================================
#   Disable network location fly-out
#===================================================================================================================================================
Write-Host "STEP 10: Turning off network location fly-out"
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" /f

# Create registry keys to detect this was installed
$currentDateTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss" 
New-Item -Path 'HKLM:\SOFTWARE\' -Name 'SIGVARIS' -ErrorAction SilentlyContinue
New-Item -Path 'HKLM:\SOFTWARE\SIGVARIS' -Name 'Autopilot' -ErrorAction SilentlyContinue
$RegPath = "HKLM:\SOFTWARE\SIGVARIS\Autopilot"
New-ItemProperty -Path  $RegPath -Name AutopilotBranding -Value 'Installed' -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path  $RegPath -Name Version -Value '1.1' -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path  $RegPath -Name InstallDateTime -Value $currentDateTime -Force -ErrorAction SilentlyContinue

Stop-Transcript | Out-Null