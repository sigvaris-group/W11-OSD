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

Set-LanguageSettings-22H2.ps1

$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
Install-Language ($tsenv.Value('SIGLanguage')) -CopyToSettings 

$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
Set-TimeZone -Id ($tsenv.Value('SIGTimezone'))

Apply Language Preferences
rundll32.exe shell32,Control_RunDLL intl.cpl,, /f:"C:\Windows\Temp\UI-Settings.xml"

Install-LanguageOnlineNew.ps1


$Title = "Set-KeyboardLanguage"
$host.UI.RawUI.WindowTitle = $Title
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

$env:APPDATA = "C:\Windows\System32\Config\SystemProfile\AppData\Roaming"
$env:LOCALAPPDATA = "C:\Windows\System32\Config\SystemProfile\AppData\Local"
$Env:PSModulePath = $env:PSModulePath + ";C:\Program Files\WindowsPowerShell\Scripts"
$env:Path = $env:Path + ";C:\Program Files\WindowsPowerShell\Scripts"

$Global:Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Set-KeyboardLanguage.log"
Start-Transcript -Path (Join-Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\OSD\" $Global:Transcript) -ErrorAction Ignore

Write-Host -ForegroundColor Green "Set keyboard language to de-CH"
Start-Sleep -Seconds 5

$LanguageList = Get-WinUserLanguageList

$LanguageList.Add("de-CH")
Set-WinUserLanguageList $LanguageList -Force

Start-Sleep -Seconds 5

$LanguageList = Get-WinUserLanguageList
$LanguageList.Remove(($LanguageList | Where-Object LanguageTag -like 'de-DE'))
Set-WinUserLanguageList $LanguageList -Force

$LanguageList = Get-WinUserLanguageList
$LanguageList.Remove(($LanguageList | Where-Object LanguageTag -like 'en-US'))
Set-WinUserLanguageList $LanguageList -Force

Stop-Transcript