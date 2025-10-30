# Script Information Variables
$ScriptName = 'W11_OSDStartVM.ps1' # Name
$ScriptDescription = 'Windows OS Deployment' # Description
$ScriptEnv = 'VM' # Environment: TEST, PRODUCTION, OFFLINE
$OSVersion = 'Windows 11' # Windows version
$OSBuild = '24H2' # Windows Release 
$OSEdition = 'Enterprise' # Windows Release 
$OSLanguage = 'en-us' # Windows default language
$OSLicense = "Volume" # Windows licenses
$ScriptVersion = '1.0' # Version
$ScriptDate = '14.10.2025' # Created on
$ScriptDepartment = 'Workplace & GA Team' # Department
$ScriptAuthor = 'Andreas Schilling' # Author
$Product = (Get-MyComputerProduct)
$Model = (Get-MyComputerModel)
$Manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer

# Updates
$UpdateNews = @(
"13.10.2025 New script deployed for VMs"
"14.10.2025 New script to install Forescout before OOBE"
)

# Script Local Variables
$Error.Clear()
$SL = "================================================================="
$EL = "`n=================================================================`n"
$LogFilePath = "X:\OSDCloud\Logs"
$LogFile = $ScriptName -replace ".{3}$", "log"
$StartTime = Get-Date

Start-Transcript -Path (Join-Path $LogFilePath $LogFile) -ErrorAction Ignore
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Script started at: " -NoNewline
Write-Host -ForegroundColor Cyan "$($StartTime)"

# Script Information
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Name: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptName)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Description: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptDescription)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Environment: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptEnv)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] OSVersion: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSVersion)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] OSBuild: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSBuild)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] OSEdition: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSEdition)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] OSLanguage: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSLanguage)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] OSLicense: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSLicense)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Script Version: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptVersion)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Created on: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptDate)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Department: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptDepartment)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Author: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptAuthor)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Logfile Path: " -NoNewline
Write-Host -ForegroundColor Cyan "$($LogFilePath)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Logfile: " -NoNewline
Write-Host -ForegroundColor Cyan "$($LogFile)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Manufacturer: " -NoNewline
Write-Host -ForegroundColor Cyan "$($Manufacturer)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Model: " -NoNewline
Write-Host -ForegroundColor Cyan "$($Model)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Product: " -NoNewline
Write-Host -ForegroundColor Cyan "$($Product)"
Write-Host -ForegroundColor DarkGray $EL

# Updates
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Start] Below you find the newest updates of the script"
foreach ($UpdateNew in $UpdateNews) {
    Write-Host -ForegroundColor Cyan "$($UpdateNew)"
}
Start-Sleep -Seconds 5

# ================================================================================================================================================~
# [SECTION] UI
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-Start] UI"
Write-Host -ForegroundColor DarkGray $SL

# UI config folder
$UILocation = "X:\OSDCloud\Config\UI" 
$UIXMLFile = "UI++VM.xml" # change file name if using in production 
# Download UI++ Setup XML
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [UI] Load $($UIXMLFile) config file and store it into folder $($UILocation)"
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/UI++VM.xml" -OutFile "$($UILocation)\$($UIXMLFile)"

# Start UI++ 
$UIExe = "UI++64.exe"
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [UI] Start $($UIExe) from folder $($UILocation)"
$UI = Start-Process -FilePath "$($UILocation)\$($UIExe)" -ArgumentList "/config:$($UIXMLFile)" -WorkingDirectory $($UILocation) -Wait 
if ($UI) { 
    Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [UI] Waiting for UI Client Setup to complete"
    if (Get-Process -Id $UI.Id -ErrorAction Ignore) {
        Wait-Process -Id $UI.Id
    } 
}

$sfcVerifyOutput = Start-Process -Wait "$Env:windir\System32\sfc" -ArgumentList "/verifyonly" -WindowStyle Hidden 
if ($sfcVerifyOutput) {
    Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [SCF] Waiting for scf /verifyonlyto complete"
    if (Get-Process -Id $sfcVerifyOutput.Id -ErrorAction Ignore) {
        Wait-Process -Id $sfcVerifyOutput.Id
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

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] UI"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] Section took " -NoNewline
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Gray "minutes to execute."
Write-Host -ForegroundColor DarkGray $SL

# ================================================================================================================================================~
# [SECTION] OSDCloud
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-Start] OSDCloud"
Write-Host -ForegroundColor DarkGray $SL

if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [OSDCloud] Setting Display Resolution to 1600x for Virtual Machines"
    Set-DisRes 1600
}

Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [OSDCloud] Install OSD PowerShell Module"
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
Install-Module OSD -SkipPublisherCheck -Force

Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [OSDCloud] Importing OSD PowerShell Module"
Import-Module OSD -Force   

# [OSD] Params and Start-OSDCloud
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [OSDCloud] Set OSDCloud variables and parameters"

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
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [OSDCloud] MyOSDCloud variables"
Write-Output $Global:MyOSDCloud

# Variables to define the Windows OS / Edition etc to be applied during OSDCloud
$Params = @{
    OSVersion = "$($OSVersion)"
    OSBuild = "$($OSBuild)"
    OSEdition = "$($OSEdition)"
    OSLanguage = "$($OSLanguage)"
    OSLicense = "$($OSLicense)"
    ZTI = $true
    Firmware = $true
}
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [OSDCloud] Windows OS install parameters"
Write-Output $Params

# Launch OSDCloud
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [OSDCloud] Starting OSDCloud"

Start-OSDCloud @Params

Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [OSDCloud] OSDCloud Process Complete."

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] OSDCloud"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] Section took " -NoNewline
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Gray "minutes to execute."
Write-Host -ForegroundColor DarkGray $SL

# ================================================================================================================================================~
# [SECTION] PostOSD
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-Start] PostOSD"
Write-Host -ForegroundColor DarkGray $SL

# Copy CMTrace.exe local
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [PostOSD] Download and copy CMTrace.exe file"
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/CMTrace.exe" -OutFile "C:\Windows\System32\CMTrace.exe"

# Copy sigvaris.bmp local
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [PostOSD] Download and copy sigvaris.bmp file"
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/sigvaris.bmp" -OutFile "C:\Windows\sigvaris.bmp"

# Copy W11_SetupVM.ps1 local
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [PostOSD] Download W11_SetupVM.ps1" 
Invoke-RestMethod "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/W11_SetupVM.ps1" | Out-File -FilePath 'C:\Windows\Setup\scripts\W11_SetupVM.ps1' -Encoding ascii -Force

# Copy Install-PreApps.ps1 local
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [PostOSD] Download Install-PreApps.ps1" 
Invoke-RestMethod "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/Install-PreApps.ps1" | Out-File -FilePath 'C:\Windows\Setup\scripts\Install-PreApps.ps1' -Encoding ascii -Force

# Copy W11_CleanUP.ps1 local
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [PostOSD] Download W11_CleanUP.ps1" 
Invoke-RestMethod "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/W11_CleanUP.ps1" | Out-File -FilePath 'C:\Windows\Setup\scripts\W11_CleanUP.ps1' -Encoding ascii -Force

# OOBEDeploy Configuration
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [PostOSD] Create OOBEDeploy configuration file for Start-AutopilotOOBE function (removes unwanted apps)"
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
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [PostOSD] Create UIJson file (used by several scripts)"
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
    "OSDDomainJoin" : "$OSDDomainJoin"
}
"@
$UIjson | Out-File -FilePath "C:\ProgramData\OSDeploy\UIjson.json" -Encoding ascii -Force


# Create Windows Unattend XML file
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [PostOSD] Create Windows Unattend XML file"
if (-NOT (Test-Path 'C:\Windows\Panther')) {
    New-Item -Path 'C:\Windows\Panther' -ItemType Directory -Force -ErrorAction Stop | Out-Null
}

Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [PostOSD] Create C:\Windows\Panther\Unattend.xml"
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
                    <Path>PowerShell -ExecutionPolicy Bypass C:\Windows\Setup\scripts\Autopilot-RegisterDevice.ps1 -Wait</Path>
                </RunSynchronousCommand>   
                <RunSynchronousCommand wcm:action="add">
                    <Order>2</Order>
                    <Description>Install Pre-Applications</Description>
                    <Path>PowerShell -ExecutionPolicy Bypass C:\Windows\Setup\scripts\Install-PreApps.ps1 -Wait</Path>
                </RunSynchronousCommand>                                                                                                                                  
            </RunSynchronous>
        </component>
    </settings>
    <settings pass="oobeSystem"> 
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <InputLocale>en-US</InputLocale>
            <SystemLocale>en-US</SystemLocale>
            <UILanguage>en-US</UILanguage>
            <UserLocale>en-US</UserLocale>
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
$Panther = 'C:\Windows\Panther'
$UnattendPath = "$($Panther)\Unattend.xml"
$UnattendXml | Out-File -FilePath $UnattendPath -Encoding utf8 -Width 2000 -Force

Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [PostOSD] Copy Autopilot-RegisterDevice.ps1" 
Copy-Item "X:\OSDCloud\Config\Scripts\Autopilot-RegisterDevice.ps1" -Destination "C:\Windows\Setup\Scripts\Autopilot-RegisterDevice.ps1" -Force

Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [PostOSD] Computer_DomainJoin.ps1" 
Copy-Item "X:\OSDCloud\Config\Scripts\Computer_DomainJoin.ps1" -Destination "C:\Windows\Setup\Scripts\Computer_DomainJoin.ps1" -Force

Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [PostOSD] Copy SecureConnectorInstaller.msi" 
Copy-Item "X:\OSDCloud\Config\Tools\SecureConnectorInstaller.msi" -Destination "C:\Windows\Temp\SecureConnectorInstaller.msi" -Force

Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [PostOSD] Setup scripts for OOBE phase" 
$OOBECMD = @'
@echo off

# Execute OOBE Tasks
# Below a PS session for debug and testing in system context, # when not needed 
#start /wait powershell.exe -NoL -ExecutionPolicy Bypass

start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\W11_SetupVM.ps1
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\Computer_DomainJoin.ps1
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\W11_CleanUP.ps1

exit 
'@
$OOBECMD | Out-File -FilePath 'C:\Windows\Setup\scripts\oobe.cmd' -Encoding ascii -Force

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] PostOSD"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] Section took " -NoNewline
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Gray "minutes to execute."
Write-Host -ForegroundColor DarkGray $SL

$EndTime = Get-Date
$ExecutionTime = $EndTime - $StartTime
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [End] Script ended at: " -NoNewline
Write-Host -ForegroundColor Cyan "$($EndTime)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [End] Script took " -NoNewline
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes)" -NoNewline
Write-Host -ForegroundColor Gray " minutes to execute"

Stop-Transcript | Out-Null  

# Copy OSDCloud files from USB
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [PostOSD] Copy OSDCloud files from USB" 
Copy-Item X:\OSDCloud\Config C:\OSDCloud\Config -Recurse -Force
Copy-Item X:\OSDCloud\Logs C:\OSDCloud\Logs -Recurse -Force

#=======================================================================
#   Restart-Computer
#=======================================================================
Write-Host -ForegroundColor Yellow "[$(Get-Date -Format G)] [End] Restarting in 10 seconds into Windows OS"
start-Sleep -Seconds 10
wpeutil reboot