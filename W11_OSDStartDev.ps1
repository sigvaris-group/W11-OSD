# Script Information Variables
$ScriptName = 'W11_OSDStartDev.ps1' # Name
$ScriptDescription = 'Windows OS Deployment' # Description
$ScriptEnv = 'TEST' # Environment: TEST, PRODUCTION, OFFLINE
$OSVersion = 'Windows 11' # Windows version
$OSBuild = '24H2' # Windows Release 
$OSEdition = 'Enterprise' # Windows Release 
$OSLanguage = 'en-us' # Windows default language
$OSLicense = "Volume" # Windows licenses
$ScriptVersion = '1.0' # Version
$ScriptDate = '22.07.2025' # Created on
$ScriptDepartment = 'GA & Workplace Team' # Department
$ScriptAuthor = 'Andreas Schilling' # Author
$Product = (Get-MyComputerProduct)
$Model = (Get-MyComputerModel)
$Manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer

# Updates
$UpdateNews = @(
"22.07.2025 New script provided for testing"
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
Write-Host -ForegroundColor Blue "[$($DT)] [Start] Script started at: " -NoNewline
Write-Host -ForegroundColor Cyan "$($StartTime)"

# Script Information
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "Name: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptName)"
Write-Host -ForegroundColor Blue "Description: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptDescription)"
Write-Host -ForegroundColor Blue "Environment: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptEnv)"
Write-Host -ForegroundColor Blue "OSVersion: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSVersion)"
Write-Host -ForegroundColor Blue "OSBuild: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSBuild)"
Write-Host -ForegroundColor Blue "OSEdition: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSEdition)"
Write-Host -ForegroundColor Blue "OSLanguage: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSLanguage)"
Write-Host -ForegroundColor Blue "OSLicense: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSLicense)"
Write-Host -ForegroundColor Blue "Script Version: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptVersion)"
Write-Host -ForegroundColor Blue "Created on: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptDate)"
Write-Host -ForegroundColor Blue "Department: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptDepartment)"
Write-Host -ForegroundColor Blue "Author: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptAuthor)"
Write-Host -ForegroundColor Blue "Logfile Path: " -NoNewline
Write-Host -ForegroundColor Cyan "$($LogFilePath)"
Write-Host -ForegroundColor Blue "Logfile: " -NoNewline
Write-Host -ForegroundColor Cyan "$($LogFile)"
Write-Host -ForegroundColor Blue "Product: " -NoNewline
Write-Host -ForegroundColor Cyan "$($Product)"
Write-Host -ForegroundColor Blue "Model: " -NoNewline
Write-Host -ForegroundColor Cyan "$($Model)"
Write-Host -ForegroundColor Blue "Manufacturer: " -NoNewline
Write-Host -ForegroundColor Cyan "$($Manufacturer)"
Write-Host -ForegroundColor DarkBlue $EL

# Updates
Write-Host -ForegroundColor Blue "[$($DT)] [Start] Below you find the newest updates of the script"
foreach ($UpdateNew in $UpdateNews) {
    Write-Host -ForegroundColor Cyan "$($UpdateNew)"
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
Write-Host -ForegroundColor Blue "[$($DT)] [UI] Load $($UIXMLFile) from $($UILocation)"
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

Write-Host -ForegroundColor Blue "[$($DT)] [UI] Your Settings are:"
Write-Host -ForegroundColor Blue "Computername: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDComputername)"
Write-Host -ForegroundColor Blue "Location: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDLocation)"
Write-Host -ForegroundColor Blue "OS Language: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDLanguage)"
Write-Host -ForegroundColor Blue "Display Language: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDDisplayLanguage)"
Write-Host -ForegroundColor Blue "Language Pack: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDLanguagePack)"
Write-Host -ForegroundColor Blue "Keyboard: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDKeyboard)"
Write-Host -ForegroundColor Blue "KeyboardLocale: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDKeyboardLocale)"
Write-Host -ForegroundColor Blue "GeoID: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDGeoID)"
Write-Host -ForegroundColor Blue "TimeZone: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDTimeZone)"
Write-Host -ForegroundColor Blue "Active Directory Domain Join: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDDomainJoin)"
Write-Host -ForegroundColor Blue "Windows Updates: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDWindowsUpdate)"

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] UI"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Section took " -NoNewline
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes) " -NoNewline
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
    Write-Host -ForegroundColor Blue "[$($DT)] [OSDCloud] Setting Display Resolution to 1600x for Virtual Machines"
    Set-DisRes 1600
}

Write-Host -ForegroundColor Blue "[$($DT)] [OSDCloud] Install OSD PowerShell Module"
Set-ExecutionPolicy -ExecutionPolicy ByPass 
Install-Module OSD -SkipPublisherCheck -Force

Write-Host -ForegroundColor Blue "[$($DT)] [OSDCloud] Importing OSD PowerShell Module"
Import-Module OSD -Force   

# [OSD] Params and Start-OSDCloud
Write-Host -ForegroundColor Blue "[$($DT)] [OSDCloud] Set OSDCloud variables and parameters"

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
Write-Host -ForegroundColor Blue "[$($DT)] [OSDCloud] MyOSDCloud variables"
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
Write-Host -ForegroundColor Blue "[$($DT)] [OSDCloud] Windows OS install parameters"
Write-Output $Params

# Launch OSDCloud
Write-Host -ForegroundColor Blue "[$($DT)] [OSDCloud] Starting OSDCloud"

Start-OSDCloud @Params

Write-Host -ForegroundColor Blue "[$($DT)] [OSDCloud] OSDCloud Process Complete. Running Custom Actions From Script Before Reboot"

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] OSDCloud"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Section took " -NoNewline
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] PostOSD
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] PostOSD"
Write-Host -ForegroundColor DarkBlue $SL

# Copy CMTrace.exe local
Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Download and copy CMTrace.exe file"
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/CMTrace.exe" -OutFile "C:\Windows\System32\CMTrace.exe"

# Copy sigvaris.bmp local
Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Download and copy sigvaris.bmp file"
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/sigvaris.bmp" -OutFile "C:\Windows\sigvaris.bmp"

# Copy WirelessConnect.exe local
Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Download and copy WirelessConnect.exe file"
Invoke-WebRequest "https://github.com/okieselbach/Helpers/raw/master/WirelessConnect/WirelessConnect/bin/Release/WirelessConnect.exe" -OutFile "C:\Windows\WirelessConnect.exe"

# Create XML file for Microsoft M365 App
Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Create XML file for Microsoft M365 App which used later in the application deployment"
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
Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Create OOBEDeploy configuration file for Start-AutopilotOOBE function (removes unwanted apps)"
If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
}
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
$OOBEDeployJson | Out-File -FilePath "C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json" -Encoding ascii -Force

# Create UIJson file
Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Create UIJson file (used by several scripts)"
If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
}
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
Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Create Windows Unattend XML file"
if (-NOT (Test-Path 'C:\Windows\Panther')) {
    New-Item -Path 'C:\Windows\Panther' -ItemType Directory -Force -ErrorAction Stop | Out-Null
}
if ($OSDDomainJoin -eq 'Yes') {
Write-Host -ForegroundColor Blue "Create C:\Windows\Panther\Unattend.xml for Domain Joined Devices"
$UnattendXml = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <ComputerName>$OSDComputername</ComputerName>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <InputLocale>$OSDDisplayLanguage</InputLocale>
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
}
else {
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
}
$Panther = 'C:\Windows\Panther'
$UnattendPath = "$($Panther)\Unattend.xml"
$UnattendXml | Out-File -FilePath $UnattendPath -Encoding utf8 -Width 2000 -Force

<#
# Setup Wi-Fi profile if connected
Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Setup Wi-Fi profile if connected"
$WiFiConProfile = Get-NetConnectionProfile | Where-Object { $_.InterfaceAlias -like '*wi-fi*' -or $_.InterfaceAlias -like '*wifi*' -or $_.InterfaceAlias -like '*wlan*' }
if ($WiFiConProfile.IPv4Connectivity -eq 'Internet' -or  $WiFiConProfile.IPv6Connectivity -eq 'Internet') {
    Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Device is Wi-Fi connected"
    
    Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Export Wi-Fi profile"
    $XmlDirectory = "C:\OSDCloud\WiFi" 
    If (!(Test-Path $XmlDirectory)) {
        New-Item $XmlDirectory -ItemType Directory -Force | Out-Null
    }   
    Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Export Wi-Fi profile"
    netsh wlan export profile key=clear folder=$XmlDirectory

    Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Change Wi-Fi Connection Mode to Auto"
    $XMLprofiles = Get-ChildItem $XmlDirectory | Where-Object {$_.extension -eq ".xml"}
    foreach ($XMLprofile in $XMLprofiles) {
        [xml]$wifiProfile = Get-Content -path $XMLprofile.fullname
        $wifiProfile.WLANProfile.connectionMode = "Auto"
        $wifiProfile.Save("$($XMLprofile.fullname)")
    }
}
else {
    Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Device is wired connected"    
}
#>

# Copy script files from USB
Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Copy scripts and config files from USB" 
Copy-Item X:\OSDCloud\Config C:\OSDCloud\Config -Recurse -Force

Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Copy W11_Autopilot.ps1" 
Copy-Item "X:\OSDCloud\Config\Scripts\W11_Autopilot.ps1" -Destination "C:\Windows\Setup\Scripts\W11_Autopilot.ps1" -Force

Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Computer_DomainJoin.ps1" 
Copy-Item "X:\OSDCloud\Config\Scripts\Computer_DomainJoin.ps1" -Destination "C:\Windows\Setup\Scripts\Computer_DomainJoin.ps1" -Force

Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Copy SecureConnectorInstaller.msi" 
Copy-Item "X:\OSDCloud\Config\Tools\SecureConnectorInstaller.msi" -Destination "C:\Windows\Temp\SecureConnectorInstaller.msi" -Force

Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Copy Copy OneDriveSetup.exe" 
Copy-Item "X:\OSDCloud\Config\OneDrive\OneDriveSetup.exe" -Destination "C:\Windows\Temp\OneDriveSetup.exe" -Force -Verbose

Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Copy MSTeams-x64.msix" 
Copy-Item "X:\OSDCloud\Config\Teams\MSTeams-x64.msix" -Destination "C:\Windows\Temp\MSTeams-x64.msix" -Force -Verbose

Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Copy teamsbootstrapper.exe" 
Copy-Item "X:\OSDCloud\Config\Teams\teamsbootstrapper.exe" -Destination "C:\Windows\Temp\teamsbootstrapper.exe" -Force -Verbose

Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Copy Copy M365 setup.exe" 
(New-Item -ItemType "directory" -Path "$($env:SystemRoot)\Temp" -Name OfficeSetup -Force).FullName
Copy-Item -Path "X:\OSDCloud\Config\M365\setup.exe" -Destination "$($env:SystemRoot)\Temp\OfficeSetup\setup.exe" -Force

Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Download W11_SetupDev.ps1" 
Invoke-RestMethod "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/W11_SetupDev.ps1" | Out-File -FilePath 'C:\Windows\Setup\scripts\WW11_SetupDev.ps1' -Encoding ascii -Force

Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Setup scripts for OOBE phase" 
$OOBECMD = @'
@echo off

# Execute OOBE Tasks
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\Computer-DomainJoin.ps1
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\W11_SetupDev.ps1

# Below a PS session for debug and testing in system context, # when not needed 
#start /wait powershell.exe -NoL -ExecutionPolicy Bypass

exit 
'@
$OOBECMD | Out-File -FilePath 'C:\Windows\Setup\scripts\oobe.cmd' -Encoding ascii -Force

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] PostOSD"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Section took " -NoNewline
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

#=======================================================================
#   Restart-Computer
#=======================================================================
$EndTime = Get-Date
$ExecutionTime = $EndTime - $StartTime
Write-Host -ForegroundColor Blue "[$($DT)] [End] Script end at: " -NoNewline
Write-Host -ForegroundColor Cyan "$($EndTime)"
Write-Host -ForegroundColor Blue "[$($DT)] [End] Script took " -NoNewline
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes)" -NoNewline
Write-Host -ForegroundColor Blue " minutes to execute"

Write-Host -ForegroundColor Yellow "[$($DT)] [End] Restarting in 10 seconds into Windows OS"
start-Sleep -Seconds 10
Stop-Transcript | Out-Null  
wpeutil reboot