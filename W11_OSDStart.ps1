#=============================================================================================================================
#
# Script Name:     W11_OSDStart.ps1
# Description:     Start Windows 11 OSD Deployment
# Created:         12/20/2024
# Updated:
# Version:         1.0
#
#=============================================================================================================================

Write-Host -ForegroundColor Green "Starting Windows 11 Deployment"
Start-Sleep -Seconds 5

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


#=======================================================================
#   [PostOS] Start U++ (user interface)
#=======================================================================
Write-Host -ForegroundColor Green "Start UI Client Setup"
If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
}
$location = "C:\ProgramData\OSDeploy"
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
Write-Host -ForegroundColor Green "Computername: $($OSDComputerName)"
Write-Host -ForegroundColor Green "Language: $($OSDLanguage)"
Write-Host -ForegroundColor Green "Location: $($OSDLocation)"

#================================================
#  [PostOS] Do some custom stuff
#================================================
#Copy CMTrace Local:
Write-Host -ForegroundColor Green "Downloading and copy cmtrace file"
Invoke-WebRequest "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/CMTrace.exe" -OutFile "C:\Windows\System32\CMTrace.exe" -Verbose

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
#  [PostOS] AutopilotOOBE Configuration Staging
#================================================
Write-Host -ForegroundColor Green "Create C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json"
$AutopilotOOBEJson = @"
{
    "AssignedComputerName" : "$OSDComputername ",
    "Assign":  {
                   "IsPresent":  true
               },
    "GroupTag":  "SICHSG",
    "GroupTagOptions" = "SIATVI","SIAUME","SIBRSP","SICAMO","SIDEME","SIFRHU","SIFRSJ","SIITSI","SIMXMC","SIPLGU","SIPTLI","SIUKAN","SIUSGA","SIUSMI"
    "Hidden":  [
                   "AddToGroup",
                   "AssignedUser",
                   "PostAction",
                   "Assign"
               ],
    "PostAction":  "Quit",
    "Disabled": "Assign","PostAction",
    "Run":  "WindowsSettings",
    "Title":  "Autopilot Registration"
}
"@

If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
}
$AutopilotOOBEJson | Out-File -FilePath "C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json" -Encoding ascii -Force

#================================================
#  [PostOS] OOBE CMD Command Line
#================================================
Write-Host -ForegroundColor Green "Downloading and creating script for OOBE phase"
Invoke-RestMethod "https://github.com/sigvaris-group/W11-OSD/raw/refs/heads/main/check-autopilotprereq.ps1" | Out-File -FilePath 'C:\Windows\Setup\scripts\check-autopilotprereq.ps1' -Encoding ascii -Force
#Invoke-RestMethod https://start-autopilotoobe.osdcloud.ch | Out-File -FilePath 'C:\Windows\Setup\scripts\autopilotoobe.ps1' -Encoding ascii -Force


$OOBECMD = @'
@echo off
# Execute OOBE Tasks
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\keyboard.ps1
#start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\productkey.ps1
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\autopilotprereq.ps1
start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\autopilotoobe.ps1

# Below a PS session for debug and testing in system context, # when not needed 
# start /wait powershell.exe -NoL -ExecutionPolicy Bypass

exit 
'@
$OOBECMD | Out-File -FilePath 'C:\Windows\Setup\scripts\oobe.cmd' -Encoding ascii -Force

#=======================================================================
#   Restart-Computer
#=======================================================================
Write-Host  -ForegroundColor Green "Restarting in 20 seconds!"
start-Sleep -Seconds 20
#wpeutil reboot
