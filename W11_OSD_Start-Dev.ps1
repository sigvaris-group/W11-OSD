# Script Information Variables
$ScriptName = 'W11_OSD_Start-Dev.ps1' # Name
$ScriptDescription = 'Windows OS Deployment' # Description
$ScriptEnv = 'TEST' # Environment: TEST, PRODUCTION, OFFLINE
$OSVersion = 'Windows 11' # Windows version
$OSBuild = '24H2' # Windows Release 
$OSEdition = 'Enterprise' # Windows Release 
$OSLanguage = 'en-us' # Windows default language
$OSLicense = "Volume" # Windows licenses
$ScriptVersion = '1.0' # Version
$ScriptDate = '08.07.2025' # Created on
$ScriptDepartment = 'Global IT' # Department
$ScriptAuthor = 'Andreas Schilling' # Author
$Product = (Get-MyComputerProduct)
$Model = (Get-MyComputerModel)
$Manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer

# Updates
$UpdateNews = @(
"08.07.2025 Script created"
"16.07.2025 Script adjusted"
)

# Script Local Variables
$Error.Clear()
$SL = "================================================================================================================================================~"
$EL = "`n================================================================================================================================================~`n"
$DT = Get-Date -format G
$LogFilePath = "X:\OSDCloud\Logs"
$LogFile = $ScriptName -replace ".{3}$", "log"
$StartTime = Get-Date

Start-Transcript -Path (Join-Path $LogFilePath $LogFile) -ErrorAction Ignore
Write-Host -ForegroundColor Cyan "[$($DT)] [Start] Script started at: " -NoNewline
Write-Host -ForegroundColor Magenta "$($StartTime)"

# Script Information
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Cyan "Name: " -NoNewline
Write-Host -ForegroundColor Magenta "$($ScriptName)"
Write-Host -ForegroundColor Cyan "Description: " -NoNewline
Write-Host -ForegroundColor Magenta "$($ScriptDescription)"
Write-Host -ForegroundColor Cyan "Environment: " -NoNewline
Write-Host -ForegroundColor Magenta "$($ScriptEnv)"
Write-Host -ForegroundColor Cyan "OSVersion: " -NoNewline
Write-Host -ForegroundColor Magenta "$($OSVersion)"
Write-Host -ForegroundColor Cyan "OSBuild: " -NoNewline
Write-Host -ForegroundColor Magenta "$($OSBuild)"
Write-Host -ForegroundColor Cyan "OSEdition: " -NoNewline
Write-Host -ForegroundColor Magenta "$($OSEdition)"
Write-Host -ForegroundColor Cyan "OSLanguage: " -NoNewline
Write-Host -ForegroundColor Magenta "$($OSLanguage)"
Write-Host -ForegroundColor Cyan "OSLicense: " -NoNewline
Write-Host -ForegroundColor Magenta "$($OSLicense)"
Write-Host -ForegroundColor Cyan "Script Version: " -NoNewline
Write-Host -ForegroundColor Magenta "$($ScriptVersion)"
Write-Host -ForegroundColor Cyan "Created on: " -NoNewline
Write-Host -ForegroundColor Magenta "$($ScriptDate)"
Write-Host -ForegroundColor Cyan "Department: " -NoNewline
Write-Host -ForegroundColor Magenta "$($ScriptDepartment)"
Write-Host -ForegroundColor Cyan "Author: " -NoNewline
Write-Host -ForegroundColor Magenta "$($ScriptAuthor)"
Write-Host -ForegroundColor Cyan "Logfile Path: " -NoNewline
Write-Host -ForegroundColor Magenta "$($LogFilePath)"
Write-Host -ForegroundColor Cyan "Logfile: " -NoNewline
Write-Host -ForegroundColor Magenta "$($LogFile)"
Write-Host -ForegroundColor Cyan "Product: " -NoNewline
Write-Host -ForegroundColor Magenta "$($Product)"
Write-Host -ForegroundColor Cyan "Model: " -NoNewline
Write-Host -ForegroundColor Magenta "$($Model)"
Write-Host -ForegroundColor Cyan "Manufacturer: " -NoNewline
Write-Host -ForegroundColor Magenta "$($Manufacturer)"
Write-Host -ForegroundColor DarkBlue $EL

# Updates
Write-Host -ForegroundColor Cyan "[$($DT)] [Start] Below you find the newest updates of the script"
foreach ($UpdateNew in $UpdateNews) {
    Write-Host -ForegroundColor Magenta "$($UpdateNew)"
}
Start-Sleep -Seconds 5

# ================================================================================================================================================~
# [SECTION] UI
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] UI"
Write-Host -ForegroundColor DarkBlue $SL

# UI config folder
$UILocation = "X:\OSDCloud\Config\UI" 
$UIXMLFile = "UI++.xml" 
# Download UI++ Setup XML
Write-Host -ForegroundColor Cyan "[$($DT)] [UI] Load $($UIXMLFile) from $($UILocation)"
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/UI++Dev.xml" -OutFile "$($UILocation)\$($UIXMLFile)" 

# Start UI++ 
$UI = Start-Process -FilePath "$($UILocation)\UI++64.exe" -WorkingDirectory $UILocation -Wait
if ($UI) {
    Write-Host -ForegroundColor Cyan "[$($DT)] [UI] Waiting for UI Client Setup to complete"
    if (Get-Process -Id $UI.Id -ErrorAction Ignore) {
        Wait-Process -Id $UI.Id
    } 
}

# Set UI variables from WMI 
$OSDComputername = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDComputername
$OSDLocation = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDLocation
$OSDLanguage = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDLanguage
$OSDDisplayLanguage = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDDisplayLanguage
$OSDLanguagePack = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDLanguagePack
$OSDKeyboard = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDKeyboard
$OSDKeyboardLocale = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDKeyboardLocale
$OSDGeoID = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDGeoID
$OSDTimeZone = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDTimeZone
$OSDDomainJoin = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDDomainJoin
$OSDWindowsUpdate = (Get-WmiObject -Namespace "root\UIVars" -Class "Local_Config").OSDWindowsUpdate

Write-Host -ForegroundColor Cyan "[$($DT)] [UI] Your Settings are:"
Write-Host -ForegroundColor Cyan "Computername: " -NoNewline
Write-Host -ForegroundColor Magenta "$($OSDComputername)"
Write-Host -ForegroundColor Cyan "Location: " -NoNewline
Write-Host -ForegroundColor Magenta "$($OSDLocation)"
Write-Host -ForegroundColor Cyan "OS Language: " -NoNewline
Write-Host -ForegroundColor Magenta "$($OSDLanguage)"
Write-Host -ForegroundColor Cyan "Display Language: " -NoNewline
Write-Host -ForegroundColor Magenta "$($OSDDisplayLanguage)"
Write-Host -ForegroundColor Cyan "Language Pack: " -NoNewline
Write-Host -ForegroundColor Magenta "$($OSDLanguagePack)"
Write-Host -ForegroundColor Cyan "Keyboard: " -NoNewline
Write-Host -ForegroundColor Magenta "$($OSDKeyboard)"
Write-Host -ForegroundColor Cyan "KeyboardLocale: " -NoNewline
Write-Host -ForegroundColor Magenta "$($OSDKeyboardLocale)"
Write-Host -ForegroundColor Cyan "GeoID: " -NoNewline
Write-Host -ForegroundColor Magenta "$($OSDGeoID)"
Write-Host -ForegroundColor Cyan "TimeZone: " -NoNewline
Write-Host -ForegroundColor Magenta "$($OSDTimeZone)"
Write-Host -ForegroundColor Cyan "Active Directory Domain Join: " -NoNewline
Write-Host -ForegroundColor Magenta "$($OSDDomainJoin)"
Write-Host -ForegroundColor Cyan "Windows Updates: " -NoNewline
Write-Host -ForegroundColor Magenta "$($OSDWindowsUpdate)"

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] UI"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Section took " -NoNewline
Write-Host -ForegroundColor Magenta "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] OSDCloud
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] OSDCloud"
Write-Host -ForegroundColor DarkBlue $SL

if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host -ForegroundColor Cyan "[$($DT)] [OSDCloud] Setting Display Resolution to 1600x"
    Set-DisRes 1600
}

Write-Host -ForegroundColor Cyan "[$($DT)] [OSDCloud] Updating OSD PowerShell Module"
Set-ExecutionPolicy -ExecutionPolicy ByPass 
Install-Module OSD -SkipPublisherCheck -Force

Write-Host -ForegroundColor Cyan "[$($DT)] [OSDCloud] Importing OSD PowerShell Module"
Import-Module OSD -Force   

# [OSD] Params and Start-OSDCloud
Write-Host -ForegroundColor Cyan "[$($DT)] [OSDCloud] Set OSDCloud variables and parameters"

# Set OSDCloud Vars
$Global:MyOSDCloud = [ordered]@{
    Restart = [bool]$false
    RecoveryPartition = [bool]$true
    OEMActivation = [bool]$false
    WindowsUpdate = [bool]$false
    WindowsUpdateDrivers = [bool]$false
    WindowsDefenderUpdate = [bool]$false
    SetTimeZone = [bool]$false
    ClearDiskConfirm = [bool]$false
    ShutdownSetupComplete = [bool]$false
    SyncMSUpCatDriverUSB = [bool]$false
    CheckSHA1 = [bool]$true    
}
Write-Host -ForegroundColor Cyan "[$($DT)] [OSDCloud] MyOSDCloud variables"
Write-Output $Global:MyOSDCloud

# Variables to define the Windows OS / Edition etc to be applied during OSDCloud
$Params = @{
    OSVersion = "$($OSVersion)"
    OSBuild = "$($OSBuild)"
    OSEdition = "$($OSEdition)"
    OSLanguage = "$($OSLanguage)"
    OSLicense = "$($OSLicense)"
    ZTI = $true
    Firmware = $false
}
Write-Host -ForegroundColor Cyan "[$($DT)] [OSDCloud] Windows OS install parameters"
Write-Output $Params

# Launch OSDCloud
Write-Host -ForegroundColor Cyan "[$($DT)] [OSDCloud] Starting OSDCloud"

Start-OSDCloud @Params

Write-Host -ForegroundColor Cyan "[$($DT)] [OSDCloud] OSDCloud Process Complete, Running Custom Actions From Script Before Reboot"

# Download custom stuff
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Start PostOSD"
Write-Host -ForegroundColor DarkBlue $SL

# Copy CMTrace.exe local
Write-Host -ForegroundColor Cyan "[$($DT)] [PostOSD] Download and copy CMTrace.exe file"
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/CMTrace.exe" -OutFile "C:\Windows\System32\CMTrace.exe"

# Copy sigvaris.bmp local
Write-Host -ForegroundColor Cyan "[$($DT)] [PostOSD] Download and copy sigvaris.bmp file"
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/sigvaris.bmp" -OutFile "C:\Windows\sigvaris.bmp"

# Copy WirelessConnect.exe local
Write-Host -ForegroundColor Cyan "[$($DT)] [PostOSD] Download and copy WirelessConnect.exe file"
Invoke-WebRequest "https://github.com/okieselbach/Helpers/raw/master/WirelessConnect/WirelessConnect/bin/Release/WirelessConnect.exe" -OutFile "C:\Windows\WirelessConnect.exe"

# Create XML file for Microsoft M365 App
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [M365] Create XML file for Microsoft M365 App which used later in the application deployment"
Write-Host -ForegroundColor DarkBlue $SL

Write-Host -ForegroundColor Cyan "[$($DT)] [M365] Create C:\ProgramData\OSDeploy\M365\configuration.xml"

If (!(Test-Path "C:\ProgramData\OSDeploy\M365")) {
    New-Item "C:\ProgramData\OSDeploy\M365" -ItemType Directory -Force | Out-Null
}

$OfficeXml = @"
<Configuration ID="44ad4a5b-8ca2-4b1d-9120-4ccb79ab01bc">
  <Info Description="M365 Enterprise without Access" />
  <Add OfficeClientEdition="64" Channel="MonthlyEnterprise">
    <Product ID="O365ProPlusRetail">
      <Language ID="$OSDDisplayLanguage" />
      <Language ID="MatchOS" />
      <ExcludeApp ID="Access" />
      <ExcludeApp ID="Groove" />
      <ExcludeApp ID="Lync" />
      <ExcludeApp ID="Bing" />
    </Product>
  </Add>
  <Property Name="SharedComputerLicensing" Value="0" />
  <Property Name="FORCEAPPSHUTDOWN" Value="TRUE" />
  <Property Name="DeviceBasedLicensing" Value="0" />
  <Property Name="SCLCacheOverride" Value="0" />
  <Property Name="TenantId" Value="ef4411a0-98e1-423e-b88f-17bde7516216" />
  <Updates Enabled="TRUE" />
  <AppSettings>
    <Setup Name="Company" Value="SIGVARIS GROUP" />
    <User Key="software\microsoft\office\16.0\excel\options" Name="defaultformat" Value="51" Type="REG_SZ" App="excel16" Id="L_SaveExcelfilesas" />
    <User Key="software\microsoft\office\16.0\powerpoint\options" Name="defaultformat" Value="27" Type="REG_DWORD" App="ppt16" Id="L_SavePowerPointfilesas" />
    <User Key="software\microsoft\office\16.0\word\options" Name="defaultformat" Value="" Type="REG_SZ" App="word16" Id="L_SaveWordfilesas" />
  </AppSettings>
  <Display Level="None" AcceptEULA="TRUE" />
</Configuration>
"@ 
$OfficeXml | Out-File -FilePath "C:\ProgramData\OSDeploy\M365\configuration.xml" -Encoding utf8 -Width 2000 -Force

# OOBEDeploy Configuration
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [OOBEDeploy] Create OOBEDeploy configuration file for Start-AutopilotOOBE function"
Write-Host -ForegroundColor DarkBlue $SL

Write-Host -ForegroundColor Cyan "[$($DT)] [OOBEDeploy] Create C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json"
$OOBEDeployJson = @'
{
    "AddNetFX3":  {
                      "IsPresent":  false
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
                    "Microsoft.Copilot",
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
                   ]
}
'@
If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
}
$OOBEDeployJson | Out-File -FilePath "C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json" -Encoding ascii -Force

# Create UIJson file
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [UI] Create UIJson file"
Write-Host -ForegroundColor DarkBlue $SL

Write-Host -ForegroundColor Cyan "[$($DT)] [UI] Create C:\ProgramData\OSDeploy\UIjson.json"
$UIjson = @"
{
    "OSDComputername" : "$OSDComputername",
    "OSDLanguage" : "$OSDLanguage",
    "OSDDisplayLanguage" : "$OSDDisplayLanguage",
    "OSDLanguagePack" : "$OSDLanguagePack",    
    "OSDLocation" : "$OSDLocation",
    "OSDKeyboard" : "$OSDKeyboard",
    "OSDKeyboardLocale" : "$OSDKeyboardLocale",
    "OSDGeoID" : "$OSDGeoID",
    "OSDTimeZone" : "$OSDTimeZone",
    "OSDDomainJoin" : "$OSDDomainJoin",
    "OSDWindowsUpdate" : "$OSDWindowsUpdate"
}
"@
$UIjson | Out-File -FilePath "C:\ProgramData\OSDeploy\UIjson.json" -Encoding ascii -Force

# Create Windows Unattend XML file
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [Windows] Create Windows Unattend XML file"
Write-Host -ForegroundColor DarkBlue $SL


Write-Host -ForegroundColor Cyan "[$($DT)] [Windows] Create C:\Windows\Panther\Unattend.xml for Entra ID devices"
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
                    <Description>Start Autopilot Import and Assignment Process</Description>
                    <Path>PowerShell -ExecutionPolicy Bypass C:\Windows\Setup\scripts\W11_Autopilot.ps1 -Wait</Path>
                </RunSynchronousCommand>                                               
            </RunSynchronous>
        </component>        
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <InputLocale>$OSDKeyboardLocale</InputLocale>
            <SystemLocale>$OSDLanguage</SystemLocale>
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

if (-NOT (Test-Path 'C:\Windows\Panther')) {
    New-Item -Path 'C:\Windows\Panther' -ItemType Directory -Force -ErrorAction Stop | Out-Null
}

$Panther = 'C:\Windows\Panther'
$UnattendPath = "$($Panther)\Unattend.xml"
$UnattendXml | Out-File -FilePath $UnattendPath -Encoding utf8 -Width 2000 -Force

# Setup Wi-Fi profile if connected
$WiFiConProfile = Get-NetConnectionProfile | Where-Object { $_.InterfaceAlias -like '*wi-fi*' -or $_.InterfaceAlias -like '*wifi*' -or $_.InterfaceAlias -like '*wlan*' }
if ($WiFiConProfile.IPv4Connectivity -eq 'Internet' -or  $WiFiConProfile.IPv6Connectivity -eq 'Internet') {
    Write-Host -ForegroundColor DarkBlue $SL
    Write-Host -ForegroundColor Blue "[$($DT)] [Wifi] Setup Wi-Fi profile"
    Write-Host -ForegroundColor DarkBlue $SL

    Write-Host -ForegroundColor Cyan "[$($DT)] [Wifi] Export Wi-Fi profile $($WiFiConProfile.Name)"
    $XmlDirectory = "C:\OSDCloud\WiFi" 
    If (!(Test-Path $XmlDirectory)) {
        New-Item $XmlDirectory -ItemType Directory -Force | Out-Null
    }   
    netsh wlan export profile "$($WiFiConProfile.Name)" key=clear folder=$XmlDirectory

    Write-Host -ForegroundColor Cyan "[$($DT)] [Wifi] Change Wi-Fi Connection Mode to Auto"
    $XMLprofiles = Get-ChildItem $XmlDirectory | Where-Object {$_.extension -eq ".xml"}
    foreach ($XMLprofile in $XMLprofiles) {
        [xml]$wifiProfile = Get-Content -path $XMLprofile.fullname
        $wifiProfile.WLANProfile.connectionMode = "Auto"
        $wifiProfile.Save("$($XMLprofile.fullname)")
    }
}
else {
    Write-Host -ForegroundColor Cyan "[$($DT)] [Wifi] Device is wired connected"    
}

# Copy script files from USB
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [USB] Copy files from USB"
Write-Host -ForegroundColor DarkBlue $SL

Write-Host -ForegroundColor Cyan "[$($DT)] [USB] Copy all config files"
Copy-Item X:\OSDCloud\Config C:\OSDCloud\Config -Recurse -Force

Write-Host -ForegroundColor Cyan "[$($DT)] [USB] Copy W11_Autopilot.ps1"
Copy-Item "X:\OSDCloud\Config\Scripts\W11_Autopilot.ps1" -Destination "C:\Windows\Setup\Scripts\W11_Autopilot.ps1" -Force

Write-Host -ForegroundColor Cyan "[$($DT)] [USB] Copy Computer-DomainJoin.ps1"
Copy-Item "X:\OSDCloud\Config\Scripts\Computer-DomainJoin.ps1" -Destination "C:\Windows\Setup\Scripts\Computer-DomainJoin.ps1" -Force

Write-Host -ForegroundColor Cyan "[$($DT)] [USB] Copy SecureConnectorInstaller.msi"
Copy-Item "X:\OSDCloud\Config\Tools\SecureConnectorInstaller.msi" -Destination "C:\Windows\Temp\SecureConnectorInstaller.msi" -Force

Write-Host -ForegroundColor Cyan "[$($DT)] [USB] Copy OneDriveSetup.exe"
Copy-Item "X:\OSDCloud\Config\OneDrive\OneDriveSetup.exe" -Destination "C:\Windows\Temp\OneDriveSetup.exe" -Force -Verbose

Write-Host -ForegroundColor Cyan "[$($DT)] [USB] Copy MSTeams-x64.msix"
Copy-Item "X:\OSDCloud\Config\Teams\MSTeams-x64.msix" -Destination "C:\Windows\Temp\MSTeams-x64.msix" -Force -Verbose

Write-Host -ForegroundColor Cyan "[$($DT)] [USB] Copy teamsbootstrapper.exe"
Copy-Item "X:\OSDCloud\Config\Teams\teamsbootstrapper.exe" -Destination "C:\Windows\Temp\teamsbootstrapper.exe" -Force -Verbose

Write-Host -ForegroundColor Cyan "[$($DT)] [USB] Copy M365 setup.exe"
(New-Item -ItemType "directory" -Path "$($env:SystemRoot)\Temp" -Name OfficeSetup -Force).FullName
Copy-Item -Path "X:\OSDCloud\Config\M365\setup.exe" -Destination "$($env:SystemRoot)\Temp\OfficeSetup\setup.exe" -Force

# OOBE Customization
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [OOBE] OOBE Customization"
Write-Host -ForegroundColor DarkBlue $SL

Write-Host -ForegroundColor Cyan "[$($DT)] [OOBE] Download OS_Installps1"
Invoke-RestMethod "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/OS_Install.ps1" | Out-File -FilePath 'C:\Windows\Setup\scripts\OS_Install.ps1' -Encoding ascii -Force

Write-Host -ForegroundColor Cyan "[$($DT)] [OOBE] Setup scripts for OOBE phase"
$OOBECMD = @'
@echo off

# Execute OOBE Tasks
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\OS_install.ps1

# Below a PS session for debug and testing in system context, # when not needed 
#start /wait powershell.exe -NoL -ExecutionPolicy Bypass

exit 
'@
$OOBECMD | Out-File -FilePath 'C:\Windows\Setup\scripts\oobe.cmd' -Encoding ascii -Force

#=======================================================================
#   Restart-Computer
#=======================================================================
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [End]  Windows 11 OS Deployment"
Write-Host -ForegroundColor DarkBlue $SL

$EndTime = Get-Date
$ExecutionTime = $EndTime - $StartTime

Write-Host -ForegroundColor Cyan "[$($DT)] [End] Script ended at: " -NoNewline
Write-Host -ForegroundColor Magenta "$($EndTime)"
Write-Host -ForegroundColor Cyan "[$($DT)] [End] Script took " -NoNewline
Write-Host -ForegroundColor Magenta "$($ExecutionTime.Minutes)" -NoNewline
Write-Host -ForegroundColor Cyan " minutes to execute"

Write-Host -ForegroundColor Yellow "[$($DT)] [End] Restarting in 10 seconds into Windows OS"
start-Sleep -Seconds 10
Stop-Transcript | Out-Null  
wpeutil reboot