# Script Information Variables
$ScriptName = 'W11OSDStartDev.ps1' # Name
$ScriptDescription = 'Windows 11 OS Deployment' # Description
$ScriptEnv = 'Development' # Environment: Production, Offline, Development
$OSVersion = 'Windows 11' # Windows version
$OSBuild = '24H2' # Windows Release 
$OSEdition = 'Enterprise' # Windows Release 
$OSLanguage = 'en-us' # Windows default language
$OSLicense = "Volume" # Windows licenses
$ScriptVersion = '1.0' # Version
$ScriptDate = '28.06.2025' # Created on
$ScriptUpdateDate = '' # Update on
$ScriptUpdateReason = '' # Update reason
$ScriptDepartment = 'Global IT' # Department
$ScriptAuthor = 'Andreas Schilling' # Author
$Product = (Get-MyComputerProduct)
$Model = (Get-MyComputerModel)
$Manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer

# Updates
$UpdateNews = @(
"08.07.2025 New script created"
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
Write-Host -ForegroundColor Green "[$($DT)] [Start] Script started $($StartTime)"

# Script Information
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [Start] $($OSVersion) $($OSBuild) $($OSEdition) $($OSLanguage) Deployment"
Write-Host -ForegroundColor Cyan "Name:             $($ScriptName)"
Write-Host -ForegroundColor Cyan "Description:      $($ScriptDescription)"
Write-Host -ForegroundColor Cyan "Environment:      $($ScriptEnv)"
Write-Host -ForegroundColor Cyan "OSVersion:        $($OSVersion)"
Write-Host -ForegroundColor Cyan "OSBuild:          $($OSBuild)"
Write-Host -ForegroundColor Cyan "OSEdition:        $($OSEdition)"
Write-Host -ForegroundColor Cyan "OSLanguage:       $($OSLanguage)"
Write-Host -ForegroundColor Cyan "OSLicense:        $($OSLicense)"
Write-Host -ForegroundColor Cyan "Version:          $($ScriptVersion)"
Write-Host -ForegroundColor Cyan "Created on:       $($ScriptDate)"
Write-Host -ForegroundColor Cyan "Update on:        $($ScriptUpdateDate)"
Write-Host -ForegroundColor Cyan "Update reason:    $($ScriptUpdateReason )"
Write-Host -ForegroundColor Cyan "Department:       $($ScriptDepartment)"
Write-Host -ForegroundColor Cyan "Author:           $($ScriptAuthor)"
Write-Host -ForegroundColor Cyan "Logfile Path:     $($LogFilePath)"
Write-Host -ForegroundColor Cyan "Logfile:          $($LogFile)"
Write-Host -ForegroundColor Cyan "Product:          $($Product)"
Write-Host -ForegroundColor Cyan "Model:            $($Model)"
Write-Host -ForegroundColor Cyan "Manufacturer:     $($Manufacturer)"
Write-Host -ForegroundColor DarkBlue $EL


# Updates
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [Updates] Below you find the newest updates of the script"
Write-Host -ForegroundColor DarkBlue $SL
foreach ($UpdateNew in $UpdateNews) {
    Write-Host -ForegroundColor Green "$($UpdateNew)"
}
Write-Host -ForegroundColor DarkBlue $EL
Start-Sleep -Seconds 5


# IPConfig 
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [Network] Network information"
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Cyan "[$($DT)] [Network] Get-NetIPConfiguration"
$IPConfig = Get-NetIPConfiguration
Write-Output $IPConfig
Write-Host -ForegroundColor DarkBlue $EL

# U++ (user interface)
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [UI] Start U++ (user interface)"
Write-Host -ForegroundColor DarkBlue $SL

# USB UI Folder
$UILocation = "X:\OSDCloud\Config\UI" 

# Download UI++ Setup XML
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/UI++Dev.xml" -OutFile "$($UILocation)\UI++.xml" 

# Start UI++ 
$UI = Start-Process -FilePath "$($UILocation)\UI++64.exe" -WorkingDirectory $UILocation -Wait
if ($UI) {
    Write-Host -ForegroundColor Yellow "[$($DT)] [UI] Waiting for UI Client Setup to complete"
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
Write-Host -ForegroundColor Green "Computername: $OSDComputername"
Write-Host -ForegroundColor Green "Location: $OSDLocation"
Write-Host -ForegroundColor Green "OS Language: $OSDLanguage"
Write-Host -ForegroundColor Green "Display Language: $OSDDisplayLanguage"
Write-Host -ForegroundColor Green "Language Pack: $OSDLanguagePack"
Write-Host -ForegroundColor Green "Keyboard: $OSDKeyboard"
Write-Host -ForegroundColor Green "KeyboardLocale: $OSDKeyboardLocale"
Write-Host -ForegroundColor Green "GeoID: $OSDGeoID"
Write-Host -ForegroundColor Green "TimeZone: $OSDTimeZone"
Write-Host -ForegroundColor Green "Active Directory Domain Join: $OSDDomainJoin"
Write-Host -ForegroundColor Green "Windows Updates: $OSDWindowsUpdate"

# Update OSD Module
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [OSDCloud] Start OSD Module"
Write-Host -ForegroundColor DarkBlue $SL

if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host -ForegroundColor Cyan "[$($DT)] [OSDCloud] Setting Display Resolution to 1600x"
    Set-DisRes 1600
}

Write-Host -ForegroundColor Cyan "[$($DT)] [OSDCloud] Updating OSD PowerShell Module"
Set-ExecutionPolicy -ExecutionPolicy ByPass 
Install-Module OSD -SkipPublisherCheck -Force

Write-Host -ForegroundColor  Cyan "[$($DT)] [OSDCloud] Importing OSD PowerShell Module"
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
Write-Host -ForegroundColor Cyan "[$($DT)] [OSDCloud] MyOSDCloud variables"
Write-Output $Global:MyOSDCloud

# Variables to define the Windows OS / Edition etc to be applied during OSDCloud
$Params = @{
    OSVersion = "$($OSVersion)"
    OSBuild = "$($OSBuild))"
    OSEdition = "$($OSEdition)"
    OSLanguage = "$($OSLanguage)"
    OSLicense = "$($OSLicense)"
    ZTI = $true
    Firmware = $false
}
Write-Host -ForegroundColor Cyan "`n[$($DT)] [OSDCloud] Windows OS install parameters"
Write-Output $Params

# Launch OSDCloud
Write-Host -ForegroundColor Cyan "`n[$($DT)] [OSDCloud] Starting OSDCloud"

Start-OSDCloud @Params

Write-Host -ForegroundColor Cyan "`n[$($DT)] [OSDCloud] OSDCloud Process Complete, Running Custom Actions From Script Before Reboot"

# Download custom stuff
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [PostOSD] Download custom stuff"
Write-Host -ForegroundColor DarkBlue $SL

# Copy CMTrace.exe local
Write-Host -ForegroundColor Cyan "[$($DT)] [PostOSD] Download and copy cmtrace file"
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/CMTrace.exe" -OutFile "C:\Windows\System32\CMTrace.exe"

# Copy sigvaris.bmp local
Write-Host -ForegroundColor Cyan "[$($DT)] [PostOSD] Download and copy sigvaris.bmp file"
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/sigvaris.bmp" -OutFile "C:\Windows\sigvaris.bmp"

# Copy WirelessConnect.exe local
Write-Host -ForegroundColor Cyan "[$($DT)] [PostOSD] Download and copy WirelessConnect.exe file"
Invoke-WebRequest "https://github.com/okieselbach/Helpers/raw/master/WirelessConnect/WirelessConnect/bin/Release/WirelessConnect.exe" -OutFile "C:\Windows\WirelessConnect.exe"

# Create XML file for Microsoft M365 App
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [M365] Create XML file for Microsoft M365 App"
Write-Host -ForegroundColor DarkBlue $SL

If (!(Test-Path "C:\ProgramData\OSDeploy\M365")) {
    New-Item "C:\ProgramData\OSDeploy\M365" -ItemType Directory -Force | Out-Null
}
Write-Host -ForegroundColor Cyan "[$($DT)] [M365] Create C:\ProgramData\OSDeploy\M365\configuration.xml"
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

if ($OSDDomainJoin -eq 'Yes') {
Write-Host -ForegroundColor Cyan "[$($DT)] [Windows] Create C:\Windows\Panther\Unattend.xml for Domain Joined Devices"
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
            <InputLocale>$OSDKeyboardLocale</InputLocale>
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
Write-Host -ForegroundColor Cyan "[$($DT)] [Windows] Create C:\Windows\Panther\Unattend.xml for Entra Joined Devices"
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
                    <Description>Import WiFi Profiless</Description>
                    <Path>PowerShell -ExecutionPolicy Bypass C:\Windows\Setup\scripts\ImportWiFiProfilesDev.ps1 -Wait</Path>
                </RunSynchronousCommand>                               
                <RunSynchronousCommand wcm:action="add">
                    <Order>2</Order>
                    <Description>Connect to WiFi</Description>
                    <Path>PowerShell -ExecutionPolicy Bypass Start-Process -FilePath C:\Windows\WirelessConnect.exe -Wait</Path>
                </RunSynchronousCommand> 
                <RunSynchronousCommand wcm:action="add">
                    <Order>3</Order>
                    <Description>Start Autopilot Import and Assignment Process</Description>
                    <Path>PowerShell -ExecutionPolicy Bypass C:\Windows\Setup\scripts\W11_Autopilot.ps1 -Wait</Path>
                </RunSynchronousCommand>                                               
            </RunSynchronous>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <InputLocale>$OSDKeyboardLocale</InputLocale>
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
    New-Item -Path 'C:\Windows\Panther' -ItemType Directory -Force -ErrorAction Stop | Out-Null
}

$Panther = 'C:\Windows\Panther'
$UnattendPath = "$($Panther)\Unattend.xml"
$UnattendXml | Out-File -FilePath $UnattendPath -Encoding utf8 -Width 2000 -Force

# Setup Wi-Fi profile
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [Wifi] Setup Wi-Fi profile"
Write-Host -ForegroundColor DarkBlue $SL

Write-Host -ForegroundColor Cyan "[$($DT)] [Wifi] Export Wi-Fi profile"
If (!(Test-Path "C:\ProgramData\OSDeploy\WiFi")) {
    New-Item "C:\ProgramData\OSDeploy\WiFi" -ItemType Directory -Force | Out-Null
}
netsh wlan export profile key=clear folder=C:\ProgramData\OSDeploy\WiFi

Write-Host -ForegroundColor Cyan "[$($DT)] [Wifi] Change Wi-Fi connectionMode to Auto"
$XmlDirectory = "C:\ProgramData\OSDeploy\WiFi"
$XMLprofiles = Get-ChildItem $XmlDirectory | Where-Object {$_.extension -eq ".xml"}
foreach ($XMLprofile in $XMLprofiles) {
    [xml]$wifiProfile = Get-Content -path $XMLprofile.fullname
    $wifiProfile.WLANProfile.connectionMode = "Auto"
    $wifiProfile.Save("$($XMLprofile.fullname)")
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

# Set Computername
Write-Host -ForegroundColor Cyan "[$($DT)] [OOBE] Set Computername $($OSDComputername)"
Rename-Computer -NewName $OSDComputername

Write-Host -ForegroundColor Cyan "[$($DT)] [OOBE] Download AutopilotBranding.ps1"
Invoke-RestMethod "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/AutopilotBranding.ps1" | Out-File -FilePath 'C:\Windows\Setup\scripts\AutopilotBranding.ps1' -Encoding ascii -Force

Write-Host -ForegroundColor Cyan "[$($DT)] [OOBE] Download Import-WiFiProfiles.ps1"
Invoke-RestMethod "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/ImportWiFiProfilesDev.ps1" | Out-File -FilePath 'C:\Windows\Setup\scripts\ImportWiFiProfilesDev.ps1' -Encoding ascii -Force

Write-Host -ForegroundColor Cyan "[$($DT)] [OOBE] Download Set-Language.ps1"
Invoke-RestMethod "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/Set-Language.ps1" | Out-File -FilePath 'C:\Windows\Setup\scripts\Set-Language.ps1' -Encoding ascii -Force

Write-Host -ForegroundColor Cyan "[$($DT)] [OOBE] Download UpdateWindowsDev.ps1"
Invoke-RestMethod "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/UpdateWindowsDev.ps1" | Out-File -FilePath 'C:\Windows\Setup\scripts\UpdateWindowsDev.ps1' -Encoding ascii -Force

Write-Host -ForegroundColor Cyan "[$($DT)] [OOBE] Download InstallPreAppsDev.ps1"
Invoke-RestMethod "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/InstallPreAppsDev.ps1" | Out-File -FilePath 'C:\Windows\Setup\scripts\InstallPreAppsDev.ps1' -Encoding ascii -Force

Write-Host -ForegroundColor Cyan "[$($DT)] [OOBE] Setup scripts for OOBE phase"
$OOBECMD = @'
@echo off

# Execute OOBE Tasks
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\ImportWiFiProfilesDev.ps1
#start /wait powershell.exe -NoL -ExecutionPolicy Bypass Start-Process -FilePath C:\Windows\WirelessConnect.exe
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\InstallPreAppsDev.ps1
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\UpdateWindowsDev.ps1
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\scripts\Set-Language.ps1
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\Computer-DomainJoin.ps1
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\AutopilotBranding.ps1

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

Write-Host -ForegroundColor Green "[$($DT)] [End] Script ended $($EndTime)"
Write-Host -ForegroundColor Green "[$($DT)] [End] Script took $($ExecutionTime.Minutes) minutes to execute"
Write-Host -ForegroundColor Red "[$($DT)] [End] Restarting in 10 seconds into Windows OS"
start-Sleep -Seconds 10
Stop-Transcript | Out-Null  
wpeutil reboot