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
$OSDTimeZone = $json.OSDTimeZone

#===================================================================================================================================================
#   Enable location services so the time zone will be set automatically (even when skipping the privacy page in OOBE) when an administrator signs in
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Enable location services to automatically set the time zone"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type "String" -Value "Allow" -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type "DWord" -Value 1 -Force -ErrorAction SilentlyContinue
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
Write-Host -ForegroundColor Green "Remove Personal Teams"
Get-AppxPackage -Name MicrosoftTeams -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue 

#===================================================================================================================================================
#   Disable network location fly-out
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Disable network location fly-out"
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" /f

#===================================================================================================================================================
#   Stop Start menu from opening on first logon
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Stop Start menu from opening on first logon"
reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v StartShownOnUpgrade /t REG_DWORD /d 1 /f | Out-Host

#===================================================================================================================================================
#   Hide "Learn more about this picture" from the desktop
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Hide 'Learn more about this picture' from the desktop"
reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{2cc5ca98-6485-489a-920e-b3e88a6ccce3}" /t REG_DWORD /d 1 /f | Out-Host

#===================================================================================================================================================
#   Disable Windows Spotlight as per https://github.com/mtniehaus/AutopilotBranding/issues/13#issuecomment-2449224828
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Disable Windows Spotlight"
reg.exe add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v DisableSpotlightCollectionOnDesktop /t REG_DWORD /d 1 /f | Out-Host

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

#===================================================================================================================================================
#   Set registered user and organization
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Set registered user and organization"
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOwner /t REG_SZ /d "Global IT" /f /reg:64 | Out-Host
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOrganization /t REG_SZ /d "SIGVARIS GROUP" /f /reg:64 | Out-Host

#===================================================================================================================================================
#   Configure OEM branding info
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Configure OEM branding info"
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Manufacturer /t REG_SZ /d "SIGVARIS GROUP" /f /reg:64 | Out-Host
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Model /t REG_SZ /d "Autopilot" /f /reg:64 | Out-Host
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v SupportURL /t REG_SZ /d "https://sigvarisitcustomercare.saasiteu.com/Account/Login?ProviderName=AAD" /f /reg:64 | Out-Host
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Logo /t REG_SZ /d "C:\Windows\sigvaris.bmp" /f /reg:64 | Out-Host

#===================================================================================================================================================
#    Install OneDrive per machine
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Install OneDrive per machine"
$dest = "C:\Windows\Temp\OneDriveSetup.exe"
$proc = Start-Process $dest -ArgumentList "/allusers" -WindowStyle Hidden -PassThru
$proc.WaitForExit()

#===================================================================================================================================================
#    Remove C:\Windows\Setup\Scripts\ Items
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Remove C:\Windows\Setup\Scripts Items"
Remove-Item C:\Windows\Setup\Scripts\*.* -Exclude *.TAG -Force | Out-Null

#===================================================================================================================================================
#    Copy OSDCloud logs and delete C:\OSDCloud folder
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Copy OSDCloud logs and delete C:\OSDCloud folder"
Copy-Item -Path "C:\OSDCloud\Logs\*" -Destination "C:\ProgramData\OSDeploy" -Recurse
Remove-Item C:\OSDCloud -Recurse -Force | Out-Null

#===================================================================================================================================================
#   Create registry keys to detect this was installed
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Create registry keys to detect this was installed"
$currentDateTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss" 
New-Item -Path 'HKLM:\SOFTWARE\' -Name 'SIGVARIS' -ErrorAction SilentlyContinue
New-Item -Path 'HKLM:\SOFTWARE\SIGVARIS' -Name 'Autopilot' -ErrorAction SilentlyContinue
$RegPath = "HKLM:\SOFTWARE\SIGVARIS\Autopilot"
New-ItemProperty -Path  $RegPath -Name AutopilotBranding -Value 'Installed' -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path  $RegPath -Name Version -Value '1.1' -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path  $RegPath -Name InstallDateTime -Value $currentDateTime -Force -ErrorAction SilentlyContinue

Stop-Transcript | Out-Null