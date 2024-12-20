#=============================================================================================================================
#
# Script Name:     Set-Language.ps1
# Description:     Set Language, Keyboard and TimeZone based on the $AutopilotOOBEJson 
#                  "C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json"
# Author:          Andreas Schilling
# Email:           andreas.schilling@sigvaris.com
# Created:         12/20/2024
# Updated:
# Version:         1.1
#
#=============================================================================================================================

$Title = "Set-LanguageKeyboardTimeZone"
$host.UI.RawUI.WindowTitle = $Title
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

$env:APPDATA = "C:\Windows\System32\Config\SystemProfile\AppData\Roaming"
$env:LOCALAPPDATA = "C:\Windows\System32\Config\SystemProfile\AppData\Local"
$Env:PSModulePath = $env:PSModulePath + ";C:\Program Files\WindowsPowerShell\Scripts"
$env:Path = $env:Path + ";C:\Program Files\WindowsPowerShell\Scripts"

$Global:Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Set-Language.log"
Start-Transcript -Path (Join-Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\OSD\" $Global:Transcript) -ErrorAction Ignore

Write-Host -ForegroundColor Green "Set keyboard language to de-CH"
Start-Sleep -Seconds 5

$LanguageList = Get-WinUserLanguageList
Write-Output $LanguageList

Stop-Transcript