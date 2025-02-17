#=============================================================================================================================
#
# Script Name:     W11_OSDStart.ps1
# Description:     Start Windows 11 OSD Deployment with WiFi Support and join Computer into domain
# Created:         01/18/2025
# Version:         1.2
#
#=============================================================================================================================

Write-Host -ForegroundColor Green "Starting Windows 11 Deployment with WiFi and Domain Join Support"
$UpdateNews = @(
"01/20/2025 Including WiFi and domain join"
"01/30/2025 Including script to install Windows updates"
"01/31/2025 Install Language pack moved to Intune app which will be installed by ESP, because with W11 24H2 it doesn't work anymore."
"           It installs all features of the language by default, which includes those subfeatures that take a long time to download (30min)"
"01/31/2025 Newest version of M365 Office is included"
"02/04/2025 English language pack for SICHSG,SIFRSJ,SIFRHU,SIPLGU,SIBRSP,SIPTLI,SIMXMC can be choosen"
)
Write-Host -ForegroundColor Green "UPDATE NEWS!"
foreach ($UpdateNew in $UpdateNews) {
    Write-Host "  $($UpdateNew)"
}
Start-Sleep -Seconds 10

#=======================================================================
#   [PostOS] Start U++ (user interface)
#=======================================================================
Write-Host -ForegroundColor Green "Start UI Client Setup"
$location = "X:\OSDCloud\Config\Scripts"
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/FTWCMLog64.dll" -OutFile "$location\FTWCMLog64.dll" -Verbose
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/FTWldap64.dll" -OutFile "$location\FTWldap64.dll" -Verbose
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/UI++64.exe" -OutFile "$location\UI++64.exe" -Verbose
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/UI++.xml" -OutFile "$location\UI++.xml" -Verbose
$UI = Start-Process -FilePath "$location\UI++64.exe" -WorkingDirectory $location -Wait
if ($UI) {
    Write-Host -ForegroundColor Cyan "Waiting for UI Client Setup to complete"
    if (Get-Process -Id $UI.Id -ErrorAction Ignore) {
        Wait-Process -Id $UI.Id
    } 
}
$OSDComputername = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDComputername
$OSDLocation = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDLocation
$OSDLanguage = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDLanguage
$OSDDisplayLanguage = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDDisplayLanguage
$OSDKeyboard = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDKeyboard
$OSDKeyboardLocale = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDKeyboardLocale
$OSDGeoID = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDGeoID
$OSDTimeZone = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDTimeZone
$OSDDomainJoin = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDDomainJoin

Write-Host -ForegroundColor Green "Your Settings are:"
Write-Host "  Computername: $OSDComputername"
Write-Host "  Location: $OSDLocation"
Write-Host "  OS Language: $OSDLanguage"
Write-Host "  Display Language: $OSDDisplayLanguage"
Write-Host "  Keyboard: $OSDKeyboard"
Write-Host "  KeyboardLocale: $OSDKeyboardLocale"
Write-Host "  GeoID: $OSDGeoID"
Write-Host "  TimeZone: $OSDTimeZone"
Write-Host "  DomainJoin: $OSDDomainJoin"

#================================================
#   [PreOS] Update Module
#================================================
if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host -ForegroundColor Green "Setting Display Resolution to 1600x"
    Set-DisRes 1600
}

Write-Host -ForegroundColor Green "Updating OSD PowerShell Module"
Set-ExecutionPolicy -ExecutionPolicy ByPass 
Install-Module OSD -SkipPublisherCheck -Force

Write-Host  -ForegroundColor Green "Importing OSD PowerShell Module"
Import-Module OSD -Force   

#=======================================================================
#   [OS] Params and Start-OSDCloud
#=======================================================================
#Set OSDCloud Vars
$Global:MyOSDCloud = [ordered]@{
    Restart = [bool]$False
    RecoveryPartition = [bool]$true
    OEMActivation = [bool]$True
    WindowsUpdate = [bool]$true
    WindowsUpdateDrivers = [bool]$true
    WindowsDefenderUpdate = [bool]$true
    SetTimeZone = [bool]$true
    ClearDiskConfirm = [bool]$False
    ShutdownSetupComplete = [bool]$false
    SyncMSUpCatDriverUSB = [bool]$true
    CheckSHA1 = [bool]$true    
}

#Variables to define the Windows OS / Edition etc to be applied during OSDCloud
$Params = @{
    OSVersion = "Windows 11"
    OSBuild = "24H2"
    OSEdition = "Enterprise"
    OSLanguage = "en-us"
    OSLicense = "Volume"
    ZTI = $true
    Firmware = $false
}
#Launch OSDCloud
Write-Host -ForegroundColor Green "Starting OSDCloud"

Start-OSDCloud @Params

write-host -ForegroundColor Green "OSDCloud Process Complete, Running Custom Actions From Script Before Reboot"


#================================================
#  [PostOS] Do some custom stuff
#================================================
# Copy CMTrace.exe local
Write-Host -ForegroundColor Green "Downloading and copy cmtrace file"
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/CMTrace.exe" -OutFile "C:\Windows\System32\CMTrace.exe" -Verbose

# Copy sigvaris.bmp local
Write-Host -ForegroundColor Green "Downloading and copy sigvaris.bmp file"
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/sigvaris.bmp" -OutFile "C:\Windows\sigvaris.bmp" -Verbose

# Copy WirelessConnect.exe local
Write-Host -ForegroundColor Green "Downloading and copy WirelessConnect.exe file"
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/WirelessConnect.exe" -OutFile "C:\Windows\WirelessConnect.exe" -Verbose

# Download installation files for M365 Office
Write-Host -ForegroundColor Green "Download installation files for M365 Office"
If (!(Test-Path "C:\ProgramData\OSDeploy\M365")) {
    New-Item "C:\ProgramData\OSDeploy\M365" -ItemType Directory -Force | Out-Null
}
Write-Host "Attempting to download latest Office setup executable"
Invoke-WebRequest "https://officecdn.microsoft.com/pr/wsus/setup.exe" -OutFile "C:\ProgramData\OSDeploy\M365\setup.exe" -Verbose
Write-Host "Download configuration file for M365 Office installation"
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/Configuration.xml" -OutFile "C:\ProgramData\OSDeploy\M365\Configuration.xml" -Verbose


#================================================
#  [PostOS] OOBEDeploy Configuration
#================================================
Write-Host -ForegroundColor Green "Create C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json"
$OOBEDeployJson = @'
{
    "AddNetFX3":  {
                      "IsPresent":  true
                  },
    "Autopilot":  {
                      "IsPresent":  false
                  },
    "RemoveAppx":  [
                    "*ActiproSoftwareLLC*",
                    "*AdobeSystemsIncorporated.AdobePhotoshopExpress*",
                    "Disney.37853FC22B2CE",
                    "*Duolingo-LearnLanguagesforFree*",
                    "*EclipseManager*",
                    "*PandoraMediaInc*",
                    "*CandyCrush*",
                     "*BubbleWitch3Saga*"
                    "*Wunderlist*",
                    "*Flipboard*",
                    "*Twitter*",
                    "*Facebook*",
                    "*Spotify*",
                    "*Minecraft*",
                    "*Royal Revolt*",
                    "*Sway*",
                    "*Speed Test*",
                    "*Dolby*",
                    "*Office*",
                    "*Disney*",
                    "clipchamp.clipchamp",
                    "*gaming*",
                    "MicrosoftCorporationII.MicrosoftFamily"
                    "C27EB4BA.DropboxOEM"
                    "*DevHome*"
                    "Microsoft.549981C3F5F10",
                    "Microsoft.BingWeather",
                    "Microsoft.BingNews",
                    "Microsoft.GamingApp",
                    "Microsoft.GetHelp",
                    "Microsoft.Getstarted",
                    "Microsoft.Messaging",
                    "Microsoft.Microsoft3DViewer",
                    "Microsoft.MicrosoftOfficeHub",
                    "Microsoft.MicrosoftSolitaireCollection",
                    "Microsoft.MicrosoftStickyNotes",
                    "Microsoft.MSPaint",
                    "Microsoft.MixedReality.Portal",
                    "Microsoft.NetworkSpeedTest",
                    "Microsoft.News",
                    "Microsoft.Office.Lens",
                    "Microsoft.OneConnect",
                    "Microsoft.People",
                    "Microsoft.PowerAutomateDesktop",
                    "Microsoft.Print3D",
                    "Microsoft.SkypeApp",
                    "SpotifyAB.SpotifyMusic",
                    "Microsoft.StorePurchaseApp",
                    "MicrosoftTeams",
                    "Microsoft.Todos",
                    "microsoft.windowscommunicationsapps",
                    "Microsoft.WindowsFeedbackHub",
                    "Microsoft.WindowsMaps",
                    "Microsoft.WindowsSoundRecorder",
                    "Microsoft.Xbox.TCUI",
                    "Microsoft.GamingApp",
                    "Microsoft.XboxGameOverlay",
                    "Microsoft.XboxGamingOverlay",
                    "Microsoft.XboxGamingOverlay_5.721.10202.0_neutral_~_8wekyb3d8bbwe",
                    "Microsoft.XboxIdentityProvider",
                    "Microsoft.XboxSpeechToTextOverlay",
                    "Microsoft.YourPhone",
                    "Microsoft.ZuneMusic",
                    "Microsoft.ZuneVideo"
                   ],
    "UpdateDrivers":  {
                          "IsPresent":  true
                      },
    "UpdateWindows":  {
                          "IsPresent":  true
                      }
}
'@
If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
}
$OOBEDeployJson | Out-File -FilePath "C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json" -Encoding ascii -Force


#================================================
#  [PostOS] Create UIJson file
#================================================
Write-Host -ForegroundColor Green "Create C:\ProgramData\OSDeploy\UIjson.json"
$UIjson = @"
{
    "OSDComputername" : "$OSDComputername",
    "OSDLanguage" : "$OSDLanguage",
    "OSDDisplayLanguage" : "$OSDDisplayLanguage",
    "OSDLocation" : "$OSDLocation",
    "OSDKeyboard" : "$OSDKeyboard",
    "OSDKeyboardLocale" : "$OSDKeyboardLocale",
    "OSDGeoID" : "$OSDGeoID",
    "OSDTimeZone" : "$OSDTimeZone",
    "OSDDomainJoin" : "$OSDDomainJoin"
}
"@
$UIjson | Out-File -FilePath "C:\ProgramData\OSDeploy\UIjson.json" -Encoding ascii -Force


#================================================
#  [PostOS] Create Unattend XML file
#================================================
if ($OSDDomainJoin -eq "No") {
Write-Host -ForegroundColor Green "Create C:\Windows\Panther\Unattend.xml for Entra Joined Devices"
$UnattendXml = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <ComputerName>$OSDComputername</ComputerName>
        </component>
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>                             
                <RunSynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <Description>Connect to WiFi</Description>
                    <Path>PowerShell -ExecutionPolicy Bypass Start-Process -FilePath C:\Windows\WirelessConnect.exe -Wait</Path>
                </RunSynchronousCommand>                      
                <RunSynchronousCommand wcm:action="add">
                    <Order>2</Order>
                    <Description>Start Autopilot Import and Assignment Process</Description>
                    <Path>PowerShell -ExecutionPolicy Bypass C:\Windows\Setup\scripts\W11_Autopilot.ps1 -Wait</Path>
                </RunSynchronousCommand>                                                         
            </RunSynchronous>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <InputLocale>$OSDDisplayLanguage</InputLocale>
            <SystemLocale>$OSDDisplayLanguage</SystemLocale>
            <UILanguage>$OSDDisplayLanguage</UILanguage>
            <UserLocale>$OSDDisplayLanguage</UserLocale>
        </component>
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <OOBE>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideEULAPage>true</HideEULAPage>
                <ProtectYourPC>3</ProtectYourPC>
            </OOBE>
        </component>
    </settings>
</unattend>
"@ 
}
else {
Write-Host -ForegroundColor Green "Create C:\Windows\Panther\Unattend.xml for Hybrid Joined Devices"
$UnattendXml = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <ComputerName>$OSDComputername</ComputerName>
        </component>
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>                             
                <RunSynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <Description>Connect to WiFi</Description>
                    <Path>PowerShell -ExecutionPolicy Bypass Start-Process -FilePath C:\Windows\WirelessConnect.exe -Wait</Path>
                </RunSynchronousCommand>                                                                          
            </RunSynchronous>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <InputLocale>$OSDDisplayLanguage</InputLocale>
            <SystemLocale>$OSDDisplayLanguage</SystemLocale>
            <UILanguage>$OSDDisplayLanguage</UILanguage>
            <UserLocale>$OSDDisplayLanguage</UserLocale>
        </component>
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <OOBE>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideEULAPage>true</HideEULAPage>
                <ProtectYourPC>3</ProtectYourPC>
            </OOBE>
        </component>
    </settings>
</unattend>
"@ 
}

if (-NOT (Test-Path 'C:\Windows\Panther')) {
    New-Item -Path 'C:\Windows\Panther'-ItemType Directory -Force -ErrorAction Stop | Out-Null
}

$Panther = 'C:\Windows\Panther'
$UnattendPath = "$Panther\Unattend.xml"
$UnattendXml | Out-File -FilePath $UnattendPath -Encoding utf8 -Width 2000 -Force

Write-Host -ForegroundColor Green "Export Wi-Fi profile"
If (!(Test-Path "C:\ProgramData\OSDeploy\WiFi")) {
    New-Item "C:\ProgramData\OSDeploy\WiFi" -ItemType Directory -Force | Out-Null
}
netsh wlan export profile key=clear folder=C:\ProgramData\OSDeploy\WiFi

Write-Host -ForegroundColor Green "Change Wi-Fi connectionMode to Auto"
$XmlDirectory = "C:\ProgramData\OSDeploy\WiFi"
$profiles = Get-ChildItem $XmlDirectory | Where-Object {$_.extension -eq ".xml"}
foreach ($profile in $profiles) {
    [xml]$wifiProfile = Get-Content -path $profile.fullname
    $wifiProfile.WLANProfile.connectionMode = "Auto"
    $wifiProfile.Save("$($profile.fullname)")
}

Write-Host -ForegroundColor Green "Copying script files"
Copy-Item X:\OSDCloud\Config\Scripts C:\OSDCloud\ -Recurse -Force
Copy-Item "X:\OSDCloud\Config\Scripts\Install-PreApps.ps1" -Destination "C:\Windows\Setup\Scripts\Install-PreApps.ps1" -Recurse -Force
Copy-Item "X:\OSDCloud\Config\Scripts\W11_Autopilot.ps1" -Destination "C:\Windows\Setup\Scripts\W11_Autopilot.ps1" -Recurse -Force
Copy-Item "X:\OSDCloud\Config\Scripts\Computer-DomainJoin.ps1" -Destination "C:\Windows\Setup\Scripts\Computer-DomainJoin.ps1" -Recurse -Force

# Set Computername
Write-Host -ForegroundColor Green "Set Computername $($OSDComputername)"
Rename-Computer -NewName $OSDComputername

#================================================
#  [PostOS] OOBE CMD Command Line
#================================================
Write-Host -ForegroundColor Green "Downloading and creating scripts for OOBE phase"
#Invoke-RestMethod "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/check-autopilotprereq.ps1" | Out-File -FilePath 'C:\Windows\Setup\scripts\check-autopilotprereq.ps1' -Encoding ascii -Force
Write-Host -ForegroundColor Green "Download Update-Windows.ps1"
Invoke-RestMethod "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/Update-Windows.ps1" | Out-File -FilePath 'C:\Windows\Setup\scripts\Update-Windows.ps1' -Encoding ascii -Force
Write-Host -ForegroundColor Green "Download AutopilotBranding.ps1"
Invoke-RestMethod "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/AutopilotBranding.ps1" | Out-File -FilePath 'C:\Windows\Setup\scripts\AutopilotBranding.ps1' -Encoding ascii -Force
Write-Host -ForegroundColor Green "Download Import-WiFiProfiles.ps1"
Invoke-RestMethod "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/Import-WiFiProfiles.ps1" | Out-File -FilePath 'C:\Windows\Setup\scripts\Import-WiFiProfiles.ps1' -Encoding ascii -Force
Write-Host -ForegroundColor Green "Download Install-M365Office.ps1"
Invoke-RestMethod "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/Install-M365Office.ps1" | Out-File -FilePath 'C:\Windows\Setup\scripts\Install-M365Office.ps1' -Encoding ascii -Force
Write-Host -ForegroundColor Green "Download Set-Language.ps1"
Invoke-RestMethod "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/Set-Language.ps1'" | Out-File -FilePath 'C:\ProgramData\OSDeploy\Set-Language.ps1' -Encoding ascii -Force

# Download Pre-required Applications
Write-Host -ForegroundColor Green "Download Forescout Secure Connector"
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/SecureConnectorInstaller.msi" -OutFile 'C:\Windows\Temp\SecureConnectorInstaller.msi' -Verbose


Write-Host -ForegroundColor Green "Downloading and creating script for OOBE phase"
$OOBECMD = @'
@echo off
# Execute OOBE Tasks
#start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\check-autopilotprereq.ps1
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\Import-WiFiProfiles.ps1
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\Install-PreApps.ps1
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\Computer-DomainJoin.ps1
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\Install-M365Office.ps1
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\Update-Windows.ps1
#start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\ProgramData\OSDeploy\Set-Language.ps1
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\AutopilotBranding.ps1

# Below a PS session for debug and testing in system context, # when not needed 
#start /wait powershell.exe -NoL -ExecutionPolicy Bypass

exit 
'@
$OOBECMD | Out-File -FilePath 'C:\Windows\Setup\scripts\oobe.cmd' -Encoding ascii -Force

#=======================================================================
#   Restart-Computer
#=======================================================================
Write-Host  -ForegroundColor Green "Restarting in 20 seconds!"
start-Sleep -Seconds 20
wpeutil reboot