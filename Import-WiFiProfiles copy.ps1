#=============================================================================================================================
#
# Script Name:     Import-WiFiProfiles.ps1
# Description:     Import WiFi Profiles
# Created:         06/14/2025
# Version:         3.0
#
#=============================================================================================================================
$Title = "Import WiFi Profiles"
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
$Global:Transcript = "Import-WiFiProfiles.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

Write-Host -ForegroundColor Green "Import Wi-Fi profiles"
$XmlDirectory = "C:\ProgramData\OSDeploy\WiFi"
Get-ChildItem $XmlDirectory | Where-Object {$_.extension -eq ".xml"} | ForEach-Object {netsh wlan add profile filename=($XmlDirectory+"\"+$_.name)}

<#
Write-Host -ForegroundColor Green "Start Wi-Fi connection"
$profiles = Get-ChildItem $XmlDirectory | Where-Object {$_.extension -eq ".xml"}
foreach ($profile in $profiles) {
    [xml]$wifiProfile = Get-Content -path $profile.fullname
    $SSID = $wifiProfile.WLANProfile.SSIDConfig.SSID.name
    $ProfileName = $profile.Name
    netsh wlan connect ssid="$($SSID)" name="$($ProfileName)"
}
#>

start-Sleep -Seconds 20

Stop-Transcript | Out-Null