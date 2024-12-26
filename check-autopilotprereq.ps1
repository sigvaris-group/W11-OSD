#=============================================================================================================================
#
# Script Name:     check-autopilotprereq.ps1
# Description:     Check Autopilot Prerequisites
# Created:         12/26/2024
# Updated:
# Version:         1.0
#
#=============================================================================================================================
# check-autopilotprereq.osdcloud.ch
$Title = "Check Autopilot Prerequisites"
$host.UI.RawUI.WindowTitle = $Title
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
$env:APPDATA = "C:\Windows\System32\Config\SystemProfile\AppData\Roaming"
$env:LOCALAPPDATA = "C:\Windows\System32\Config\SystemProfile\AppData\Local"
$Env:PSModulePath = $env:PSModulePath+";C:\Program Files\WindowsPowerShell\Scripts"
$env:Path = $env:Path+";C:\Program Files\WindowsPowerShell\Scripts"

$Global:Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Check-AutopilotPrerequisites.log"
Start-Transcript -Path (Join-Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\OSD\" $Global:Transcript) -ErrorAction Ignore

Write-Host "Execute Autopilot Prerequitites Check" -ForegroundColor Green

Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
Install-Script -Name Check-AutopilotPrerequisites -Force
Check-AutopilotPrerequisites

Stop-Transcript