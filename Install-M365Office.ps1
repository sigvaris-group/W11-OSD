#=============================================================================================================================
#
# Script Name:     Install-M365Office.ps1
# Description:     Script to install M365 Office by downloading the latest Office setup exe from evergreen url
#                  Running Setup.exe from downloaded files with provided configuration.xml file.
# Created:         01/31/2024
# Updated:         
# Version:         1.0
#
#=============================================================================================================================

$Title = "Install M365 Office App"
$host.UI.RawUI.WindowTitle = $Title
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

$env:APPDATA = "C:\Windows\System32\Config\SystemProfile\AppData\Roaming"
$env:LOCALAPPDATA = "C:\Windows\System32\Config\SystemProfile\AppData\Local"
$Env:PSModulePath = $env:PSModulePath+";C:\Program Files\WindowsPowerShell\Scripts"
$env:Path = $env:Path+";C:\Program Files\WindowsPowerShell\Scripts"

If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null}
$Global:Transcript = "Install-M365Office.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

#===================================================================================================================================================
#   Install M365 Office
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Download M365 Office"
$M365OfficeDownload = Start-Process -FilePath "C:\ProgramData\OSDeploy\M365\setup.exe" -ArgumentList "/download C:\ProgramData\OSDeploy\M365\configuration.xml" -Wait -PassThru -Verbose 
if ($M365OfficeDownload) {
    Write-Host -ForegroundColor Cyan "Waiting for M365 Office Download to complete"
    if (Get-Process -Id $M365OfficeDownload.Id -ErrorAction Ignore) {
        Wait-Process -Id $M365OfficeDownload.Id
    } 
}

Write-Host -ForegroundColor Green "Install M365 Office"
$M365Office = Start-Process -FilePath "C:\ProgramData\OSDeploy\M365\setup.exe" -ArgumentList "/configure C:\ProgramData\OSDeploy\M365\configuration.xml" -Wait -PassThru -Verbose 
if ($M365Office) {
    Write-Host -ForegroundColor Cyan "Waiting for M365 Office Setup to complete"
    if (Get-Process -Id $M365Office.Id -ErrorAction Ignore) {
        Wait-Process -Id $M365Office.Id
    } 
}

#===================================================================================================================================================
#   Check if M365 Office is installed
#===================================================================================================================================================
$RegistryKeys = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$M365Apps = "Microsoft 365 Apps"
$M365AppsCheck = $RegistryKeys | Get-ItemProperty | Where-Object { $_.DisplayName -match $M365Apps }
if ($M365AppsCheck) {
    Write-Host -ForegroundColor Green "Microsoft 365 Apps detected and installed"
} else {
    Write-Host -ForegroundColor Red "Microsoft 365 Apps not installed"
}

Stop-Transcript | Out-Null