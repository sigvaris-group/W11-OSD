#=============================================================================================================================
#
# Script Name:     Set-Language.ps1
# Description:     Set Language, Keyboard and TimeZone
# Created:         12/20/2024
# Updated:
# Version:         1.0
#
#=============================================================================================================================

$Title = "Set Language, Keyboard and TimeZone"
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
$Global:Transcript = "Set-Language.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

#=======================================================================
#   [OOBE] Load UIjson.json file
#=======================================================================
Write-Host -ForegroundColor Green "Load C:\ProgramData\OSDeploy\UIjson.json file"
$json = Get-Content -Path "C:\ProgramData\OSDeploy\UIjson.json" -Raw | ConvertFrom-Json

# Access JSON properties
$OSDLanguage = $json.OSDLanguage
$OSDKeyboard = $json.OSDKeyboard
$OSDGeoID = $json.OSDGeoID

#=======================================================================
#   [OOBE] Set Language
#=======================================================================

Write-Host -ForegroundColor Green "Install language pack $($OSDLanguage) and change the language of the OS on different places"
Install-Language $OSDLanguage -CopyToSettings

Write-Host -ForegroundColor Green "Set System Preferred UI Language $($OSDLanguage)"
Set-SystemPreferredUILanguage $OSDLanguage

Write-Host -ForegroundColor Green "Configure new language $($OSDLanguage) defaults under current user (system) after which it can be copied to system"
Set-WinUILanguageOverride -Language $OSDLanguage

Write-Host -ForegroundColor Green "Set Win User Language $($OSDLanguage) List, sets the current user language settings"
$UserLanguageList = New-WinUserLanguageList -Language $OSDLanguage
Set-WinUserLanguageList -LanguageList $UserLanguageList -Force

Write-Host -ForegroundColor Green "Set Culture $($OSDKeyboard), sets the user culture for the current user account"
Set-Culture -CultureInfo $OSDKeyboard

Write-Host -ForegroundColor Green "Set Win Home Location GeoID $($OSDGeoID), sets the home location setting for the current user"
Set-WinHomeLocation -GeoId $OSDGeoID

Write-Host -ForegroundColor Green "Copy User Internaltional Settings from current user to System, including Welcome screen and new user"
Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True

Stop-Transcript | Out-Null