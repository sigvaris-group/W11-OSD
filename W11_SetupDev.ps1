# Check if running in x64bit environment
Write-Host -ForegroundColor Gray "Is 64bit PowerShell: $([Environment]::Is64BitProcess)"
Write-Host -ForegroundColor Gray "Is 64bit OS: $([Environment]::Is64BitOperatingSystem)"

Write-Host -ForegroundColor Gray "Script: " -NoNewline
Write-Host -ForegroundColor Cyan "W11_SetupDev.ps1"

if ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    $TranscriptPath = [IO.Path]::Combine($env:ProgramData, "Scripts", "LanguageSetup", "InstallLog (x86).txt")
    Start-Transcript -Path $TranscriptPath -Force -IncludeInvocationHeader

    write-warning "Running in 32-bit Powershell, starting 64-bit..."
    if ($myInvocation.Line) {
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile $myInvocation.Line
    }else{
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile -file "$($myInvocation.InvocationName)" $args
    }
    
    Stop-Transcript
    
    exit $lastexitcode
}

Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

# Script Information
$ScriptName = 'W11_SetupDev.ps1' # Name
$ScriptDescription = 'This script setup the Operation System' # Description:
$ScriptVersion = '1.0' # Version
$ScriptDate = '18.09.2025' # Created on
$ScriptUpdateDate = '' # Update on
$ScriptUpdateReason = '' # Update reason
$ScriptDepartment = 'Workplace Team & GA Team' # Department
$ScriptAuthor = 'Andreas Schilling' # Author

# Script Local Variables
$Error.Clear()
$SL = "================================================================="
$EL = "`n=================================================================`n"
$LogFilePath = "C:\ProgramData\OSDeploy"
$LogFile = $ScriptName -replace ".{3}$", "log"
$StartTime = Get-Date

If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
}

Start-Transcript -Path (Join-Path $LogFilePath $LogFile) -ErrorAction Ignore
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Script start at: " -NoNewline
Write-Host -ForegroundColor Cyan "$($StartTime)"

# Script Information
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Name: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptName)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Description: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptDescription)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Version: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptVersion)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Created on: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptDate)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Update on: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptUpdateDate)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Update reason: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptUpdateReason)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Department: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptDepartment)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Author: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptAuthor)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Logfile Path: " -NoNewline
Write-Host -ForegroundColor Cyan "$($LogFilePath)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Logfile: " -NoNewline
Write-Host -ForegroundColor Cyan "$($LogFile)"
Write-Host -ForegroundColor DarkGray $EL

# ================================================================================================================================================~
# [SECTION] UI
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-Start] UI"
Write-Host -ForegroundColor DarkGray $SL

$jsonpath = "C:\ProgramData\OSDeploy"
$jsonfile = "UIjson.json"
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [UI] Load $($jsonfile) file from $($jsonpath)"

$json = Get-Content -Path (Join-Path $jsonpath $jsonfile) -Raw | ConvertFrom-Json
$OSDComputername = $($json.OSDComputername)
$OSDLocation = $($json.OSDLocation)
$OSDLanguage = $($json.OSDLanguage)
$OSDDisplayLanguage = $($json.OSDDisplayLanguage)
$OSDLanguagePack = $($json.OSDLanguagePack)
$OSDKeyboard = $($json.OSDKeyboard)
$OSDKeyboardLocale = $($json.OSDKeyboardLocale)
$OSDGeoID = $($json.OSDGeoID)
$OSDTimeZone = $($json.OSDTimeZone)
$OSDDomainJoin = $($json.OSDDomainJoin)

Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [UI] Your Settings are:"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [UI] Computername: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDComputername)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [UI] Location: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDLocation)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [UI] OS Language: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDLanguage)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [UI] Display Language: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDDisplayLanguage)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [UI] Language Pack: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDLanguagePack)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [UI] Keyboard: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDKeyboard)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [UI] KeyboardLocale: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDKeyboardLocale)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [UI] GeoID: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDGeoID)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [UI] TimeZone: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDTimeZone)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [UI] Active Directory Domain Join: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDDomainJoin)"

if ($OSDComputername -ne $env:COMPUTERNAME) {
    Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [UI] Set Computername to: " -NoNewline
    Write-Host -ForegroundColor Cyan "$($OSDComputername)"
    Rename-Computer -NewName $OSDComputername
}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] UI"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] SECTION took " -NoNewline
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Gray  "minutes to execute."
Write-Host -ForegroundColor DarkGray $SL

# ================================================================================================================================================~
# [SECTION] PowerCfg 
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-Start] PowerCfg"
Write-Host -ForegroundColor DarkGray $SL

Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [PowerCfg] Set PowerCfg to High Performance"
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] PowerCfg"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor Cyan   "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Cyan  "minutes to execute."
Write-Host -ForegroundColor DarkGray $SL

# ================================================================================================================================================~
# [SECTION] Forescout
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-Start] Forescout"
Write-Host -ForegroundColor DarkGray $SL

try {
    Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Forescout] Install Forescout Secure Connector"
    $MSIArguments = @(
        "/i"
        ('"{0}"' -f 'C:\Windows\Temp\SecureConnectorInstaller.msi')
        "MODE=AAAAAAAAAAAAAAAAAAAAAAoWAw8nE2tvKW7g1P8yKnqq6ZfnbnboiWRweKc1A4Tdz0m6pV4kBAAB1Sl1Nw-- /qn"
    )
    Start-Process -Wait "msiexec.exe" -ArgumentList $MSIArguments
    Start-Sleep -Seconds 30
    
    $SecCon = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "*SecureConnector*"} 
    if ($SecCon) {
        Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Forescout] " -NoNewline
        Write-Host -ForegroundColor Cyan "$($SecCon.Name)" -NoNewline
        Write-Host -ForegroundColor Gray " Version " -NoNewline
        Write-Host -ForegroundColor Cyan "$($SecCon.Version)"  -NoNewline
        Write-Host -ForegroundColor Gray " successfully installed" 
        Start-Sleep 60
    }
    else {
        Write-Host -ForegroundColor Red "[$(Get-Date -Format G)] [Forescout] Secure Connector is not installed"
    }
} 
catch {
    Write-Host -ForegroundColor Red "[$(Get-Date -Format G)] [Forescout] Install Forescout Secure Connector failed with error: " -NoNewline
    Write-Host -ForegroundColor Yellow "$($_.Exception.Message)"
}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] Forescout"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor Cyan   "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Cyan  "minutes to execute."
Write-Host -ForegroundColor DarkGray $SL

# ================================================================================================================================================~
# [SECTION] Network
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-Start] Network"
Write-Host -ForegroundColor DarkGray $SL

# Check Internet Connection
$AllNetConnectionProfiles = Get-NetConnectionProfile
$AllNetConnectionProfiles | Where-Object {$_.IPv4Connectivity -eq 'Internet' -or $_.IPv6Connectivity -eq 'Internet'}
if ($AllNetConnectionProfiles) { 
    Write-Host -ForegroundColor Green "[$(Get-Date -Format G)] [Network] Internet connection succesfull"
    #Write-Output $AllNetConnectionProfiles
}
else {
    Write-Host -ForegroundColor Yellow "[$(Get-Date -Format G)] [Network] No Internet Connection. Start Wi-Fi setup."  
    Start-Process -FilePath C:\Windows\WirelessConnect.exe -Wait
    start-Sleep -Seconds 10
}

#$IPConfig = Get-NetIPConfiguration
#Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Network] Get-NetIPConfiguration"
#Write-Output $IPConfig

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] Network"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor Cyan  "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Gray  "minutes to execute."
Write-Host -ForegroundColor DarkGray $SL

# ================================================================================================================================================~
# [SECTION] Branding
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-Start] Branding"
Write-Host -ForegroundColor DarkGray $SL

#===================================================================================================================================================
#  Hide the widgets
#  This will fail on Windows 11 24H2 due to UCPD, see https://kolbi.cz/blog/2024/04/03/userchoice-protection-driver-ucpd-sys/
#  New Work Around tested with 24H2 to disable widgets as a preference
#===================================================================================================================================================
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Branding] Hide the widgets"
$ci = Get-ComputerInfo
if ($ci.OsBuildNumber -ge 26100) {
    Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Attempting Widget Hiding workaround (Taskbar)"
    $regExePath = (Get-Command reg.exe).Source
    $tempRegExe = "$($env:TEMP)\reg1.exe"
    Copy-Item -Path $regExePath -Destination $tempRegExe -Force -ErrorAction Stop
    & $tempRegExe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f /reg:64 2>&1 | Out-Host
    Remove-Item $tempRegExe -Force -ErrorAction SilentlyContinue
    Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Widget Workaround Completed"
} else {
    Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Hiding widgets with registry key"	
    & reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f /reg:64 2>&1 | Out-Host
}

#===================================================================================================================================================
#  Disable Widgets (Grey out Settings Toggle)
#  GPO settings below will completely disable Widgets, see:https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-newsandinterests#allownewsandinterests
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Disable Widgets (Grey out Settings Toggle)"
if (-not (Test-Path "HKLM:\Software\Policies\Microsoft\Dsh")) {
    New-Item -Path "HKLM:\Software\Policies\Microsoft\Dsh" | Out-Null
}
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Dsh"  -Name "DisableWidgetsOnLockScreen" -Value 1
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Dsh"  -Name "DisableWidgetsBoard" -Value 1
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Dsh"  -Name "AllowNewsAndInterests" -Value 0

#===================================================================================================================================================
#   Don't let Edge create a desktop shortcut (roams to OneDrive, creates mess)
#===================================================================================================================================================

Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Turning off (old) Edge desktop shortcut"
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v DisableEdgeDesktopShortcutCreation /t REG_DWORD /d 1 /f /reg:64 | Out-Host
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "CreateDesktopShortcutDefault" /t REG_DWORD /d 0 /f /reg:64 | Out-Host

#===================================================================================================================================================
#   Remove Personal Teams
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Remove Personal Teams"
Get-AppxPackage -Name MicrosoftTeams -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue 

#===================================================================================================================================================
#   Disable network location fly-out
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Disable network location fly-out"
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" /f

#===================================================================================================================================================
#   Stop Start menu from opening on first logon
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Stop Start menu from opening on first logon"
reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v StartShownOnUpgrade /t REG_DWORD /d 1 /f | Out-Host

#===================================================================================================================================================
#   Hide "Learn more about this picture" from the desktop
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Hide 'Learn more about this picture' from the desktop"
reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{2cc5ca98-6485-489a-920e-b3e88a6ccce3}" /t REG_DWORD /d 1 /f | Out-Host

#===================================================================================================================================================
#   Disable Windows Spotlight as per https://github.com/mtniehaus/AutopilotBranding/issues/13#issuecomment-2449224828
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Disable Windows Spotlight"
reg.exe add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v DisableSpotlightCollectionOnDesktop /t REG_DWORD /d 1 /f | Out-Host

#===================================================================================================================================================
#   Remediate Windows Update policy conflict for Autopatch
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Remediate Windows Update policy conflict for Autopatch"
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
            Write-Host -ForegroundColor Yellow "[$(Get-Date -Format G)] [Branding] $($setting.name) was not found"
    }
}

#===================================================================================================================================================
#   Set registered user and organization
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Set registered user and organization"
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOwner /t REG_SZ /d "Global IT" /f /reg:64 | Out-Host
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOrganization /t REG_SZ /d "SIGVARIS GROUP" /f /reg:64 | Out-Host

#===================================================================================================================================================
#   Configure OEM branding info
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Configure OEM branding info"
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Manufacturer /t REG_SZ /d "SIGVARIS GROUP" /f /reg:64 | Out-Host
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Model /t REG_SZ /d "Autopilot" /f /reg:64 | Out-Host
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v SupportURL /t REG_SZ /d "https://sigvarisitcustomercare.saasiteu.com/Account/Login?ProviderName=AAD" /f /reg:64 | Out-Host
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Logo /t REG_SZ /d "C:\Windows\sigvaris.bmp" /f /reg:64 | Out-Host

#===================================================================================================================================================
#    Disable extra APv2 pages (too late to do anything about the EULA), see https://call4cloud.nl/autopilot-device-preparation-hide-privacy-settings/
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Disable extra APv2 pages (too late to do anything about the EULA)"
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE"
New-ItemProperty -Path $registryPath -Name "DisablePrivacyExperience" -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $registryPath -Name "DisableVoice" -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $registryPath -Name "PrivacyConsentStatus" -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $registryPath -Name "ProtectYourPC" -Value 3 -PropertyType DWord -Force | Out-Null

#===================================================================================================================================================
#    Skip FSIA and turn off delayed desktop switch
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Skip FSIA and turn off delayed desktop switch"
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
New-ItemProperty -Path $registryPath -Name "EnableFirstLogonAnimation" -Value 0 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $registryPath -Name "DelayedDesktopSwitch" -Value 0 -PropertyType DWord -Force | Out-Null

#===================================================================================================================================================
#    Enable .NET Framework 3.5 for US, CA
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Enable .NET Framework 3.5 for US, CA"
$DeviceName = $env:COMPUTERNAME.Substring(0,6)
Switch ($DeviceName) {
    'SICAMO' {Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -NoRestart;break}
    'SIUSGA' {Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -NoRestart;break}
    'SIUSMI' {Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -NoRestart;break}
}

#===================================================================================================================================================
#    Enable Printing-PrintToPDFServices-Features because of KB5058411
#    https://support.microsoft.com/en-us/topic/may-13-2025-kb5058411-os-build-26100-4061-356568c2-c730-469e-819d-b680d43b1265
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Enable Printing-PrintToPDFServices-Features because of KB5058411"
Disable-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features -NoRestart -ErrorAction SilentlyContinue
Enable-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features -NoRestart -ErrorAction SilentlyContinue

#===================================================================================================================================================
#    Remove OSDCloudRegistration Certificate
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Remove Import-Certificate.ps1 script"
if (Test-Path -Path $env:SystemDrive\OSDCloud\Scripts\Import-Certificate.ps1) {
    Remove-Item -Path $env:SystemDrive\OSDCloud\Scripts\Import-Certificate.ps1 -Force -ErrorAction SilentlyContinue
}

#===================================================================================================================================================
#    Remove C:\Windows\Setup\Scripts\ Items
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Remove C:\Windows\Setup\Scripts Items"
Remove-Item C:\Windows\Setup\Scripts\*.* -Exclude *.TAG -Force | Out-Null

#===================================================================================================================================================
#    Copy OSDCloud logs and delete C:\OSDCloud folder
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Copy OSDCloud logs and delete C:\OSDCloud folder"
Copy-Item -Path "C:\OSDCloud\Logs\*" -Destination "C:\ProgramData\OSDeploy" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item C:\OSDCloud -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item C:\ProgramData\OSDeploy\WiFi -Recurse -Force -ErrorAction SilentlyContinue

Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [Branding] Set Computername to $($OSDComputername)"
Rename-Computer -NewName $OSDComputername -ErrorAction SilentlyContinue

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] Branding"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor Cyan  "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Gray  "minutes to execute."
Write-Host -ForegroundColor DarkGray $SL

# ================================================================================================================================================~
# End Script
# ================================================================================================================================================~
$EndTime = Get-Date
$ExecutionTime = $EndTime - $StartTime

Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Script end at: " -NoNewline
Write-Host -ForegroundColor Cyan "$($EndTime)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [End] Script took " -NoNewline 
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes)"
Write-Host -ForegroundColor Gray " minutes to execute"

Stop-Transcript | Out-Null

Write-Host -ForegroundColor Yellow "Computer will be rebooted"
Restart-Computer -Force