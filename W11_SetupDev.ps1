# Check if running in x64bit environment
Write-Host -ForegroundColor Blue "Is 64bit PowerShell: $([Environment]::Is64BitProcess)"
Write-Host -ForegroundColor Blue "Is 64bit OS: $([Environment]::Is64BitOperatingSystem)"

Write-Host -ForegroundColor Blue "Script: " -NoNewline
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
$ScriptDate = '22.07.2025' # Created on
$ScriptUpdateDate = '' # Update on
$ScriptUpdateReason = '' # Update reason
$ScriptDepartment = 'GA & Workplace Team' # Department
$ScriptAuthor = 'Andreas Schilling' # Author

# Script Local Variables
$Error.Clear()
$SL = "================================================================================================================================================~"
$EL = "`n================================================================================================================================================~`n"
$DT = Get-Date -format G
$LogFilePath = "C:\OSDCloud\Logs"
$LogFile = $ScriptName -replace ".{3}$", "log"
$StartTime = Get-Date

Start-Transcript -Path (Join-Path $LogFilePath $LogFile) -ErrorAction Ignore
Write-Host -ForegroundColor Blue "[$($DT)] [Start] Script start at: " -NoNewline
Write-Host -ForegroundColor Cyan "$($StartTime)"

# Script Information
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "Name: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptName)"
Write-Host -ForegroundColor Blue "Description: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptDescription)"
Write-Host -ForegroundColor Blue "Version: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptVersion)"
Write-Host -ForegroundColor Blue "Created on: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptDate)"
Write-Host -ForegroundColor Blue "Update on: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptUpdateDate)"
Write-Host -ForegroundColor Blue "Update reason: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptUpdateReason)"
Write-Host -ForegroundColor Blue "Department: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptDepartment)"
Write-Host -ForegroundColor Blue "Author: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptAuthor)"
Write-Host -ForegroundColor Blue "Logfile Path: " -NoNewline
Write-Host -ForegroundColor Cyan "$($LogFilePath)"
Write-Host -ForegroundColor Blue "Logfile: " -NoNewline
Write-Host -ForegroundColor Cyan "$($LogFile)"
Write-Host -ForegroundColor DarkBlue $EL

# ================================================================================================================================================~
# [SECTION] UI
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] UI"
Write-Host -ForegroundColor DarkBlue $SL

$jsonpath = "C:\ProgramData\OSDeploy"
$jsonfile = "UIjson.json"
Write-Host -ForegroundColor Cyan "[$($DT)] [UI] Load $($jsonfile) file from $($jsonpath)"

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
$OSDWindowsUpdate = $($json.OSDWindowsUpdate)

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

Write-Host -ForegroundColor Blue "[$($DT)] [UI] Set TimeZone to: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDTimeZone)"
Set-TimeZone -Id $OSDTimeZone
tzutil.exe /s "$($OSDTimeZone)" 

if ($OSDComputername -ne $env:COMPUTERNAME) {
    Write-Host -ForegroundColor Blue "[$($DT)] [UI] Set Computername to: " -NoNewline
    Write-Host -ForegroundColor Cyan "$($OSDComputername)"
    Rename-Computer -NewName $OSDComputername
}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] UI"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] SECTION took " -NoNewline
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] Forescout
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] Forescout"
Write-Host -ForegroundColor DarkBlue $SL

try {
    Write-Host -ForegroundColor Blue "[$($DT)] [Forescout] Install Forescout Secure Connector"
    $MSIArguments = @(
        "/i"
        ('"{0}"' -f 'C:\Windows\Temp\SecureConnectorInstaller.msi')
        "MODE=AAAAAAAAAAAAAAAAAAAAAAoWAw8nE2tvKW7g1P8yKnqq6ZfnbnboiWRweKc1A4Tdz0m6pV4kBAAB1Sl1Nw-- /qn"
    )
    Start-Process -Wait "msiexec.exe" -ArgumentList $MSIArguments
    Start-Sleep -Seconds 60
    
    $SecCon = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "*SecureConnector*"} 
    if ($SecCon) {
        Write-Host -ForegroundColor Blue "[$($DT)] [Forescout] " -NoNewline
        Write-Host -ForegroundColor Cyan "$($SecCon.Name)" -NoNewline
        Write-Host -ForegroundColor Blue "Version " -NoNewline
        Write-Host -ForegroundColor Cyan "$($SecCon.Version)"  -NoNewline
        Write-Host -ForegroundColor Blue " successfully installed" 
        Start-Sleep 60
    }
    else {
        Write-Host -ForegroundColor Red "[$($DT)] [Forescout] Secure Connector is not installed"
    }
} 
catch {
    Write-Host -ForegroundColor Red "[$($DT)] [Forescout] Install Forescout Secure Connector failed with error: " -NoNewline
    Write-Host -ForegroundColor Yellow "$($_.Exception.Message)"
}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Forescout"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White   "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Cyan  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

<#
# ================================================================================================================================================~
# [SECTION] Wi-Fi
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] Wi-Fi"
Write-Host -ForegroundColor DarkBlue $SL

$XmlDirectory = "C:\OSDCloud\WiFi" # Path set by initial script
Write-Host -ForegroundColor Cyan "[$($DT)] [Wi-Fi] Import Wi-Fi profiles from "
Write-Host -ForegroundColor Cyan  "$($XmlDirectory)"

try {
    if (Test-Path $XmlDirectory) {
        Get-ChildItem $XmlDirectory | Where-Object {$_.extension -eq ".xml"} | ForEach-Object {netsh wlan add profile filename=($XmlDirectory+"\"+$_.name)}
    }
    else {
        Write-Host -ForegroundColor Yellow "[$($DT)] [Wi-Fi] No Wi-Fi profiles exists to import"
    }   
}
catch {
    Write-Host -ForegroundColor Red "[$($DT)] [Wi-Fi] Import Wi-Fi profiles failed with error: " -NoNewline
    Write-Host -ForegroundColor Yellow "$($_.Exception.Message)"
}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Wi-Fi"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor Cyan   "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL
#>

# ================================================================================================================================================~
# [SECTION] Network
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] Network"
Write-Host -ForegroundColor DarkBlue $SL

# Check Internet Connection
$AllNetConnectionProfiles = Get-NetConnectionProfile
$AllNetConnectionProfiles | Where-Object {$_.IPv4Connectivity -eq 'Internet' -or $_.IPv6Connectivity -eq 'Internet'}
if ($AllNetConnectionProfiles) { 
    Write-Host -ForegroundColor Green "[$($DT)] [Network] Internet connection succesfull"
    Write-Output $AllNetConnectionProfiles
}
else {
    Write-Host -ForegroundColor Red "[$($DT)] [Network] No Internet Connection. Start Wi-Fi setup."  
    Start-Process -FilePath C:\Windows\WirelessConnect.exe -Wait
    start-Sleep -Seconds 10
}

$IPConfig = Get-NetIPConfiguration
Write-Host -ForegroundColor Blue "[$($DT)] [Network] Get-NetIPConfiguration"
Write-Output $IPConfig

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Network"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White  "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] WindowsUpdate
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] WindowsUpdate"
Write-Host -ForegroundColor DarkBlue $SL

If ($OSDWindowsUpdate -eq "Yes" -or $OSDWindowsUpdate -eq "Yes") { 
    Write-Host -ForegroundColor Blue "[$($DT)] [WindowsUpdate] Windows Updates enabled: " -NoNewline
    Write-Host -ForegroundColor Cyan "$($OSDWindowsUpdate)"

    # Opt into Microsoft Update
    Write-Host -ForegroundColor Blue "[$($DT)] [WindowsUpdate] Opt computer in to the Microsoft Update service and then register that service with Automatic Updates"
    Write-Host -ForegroundColor Blue "[$($DT)] [WindowsUpdate] https://learn.microsoft.com/en-us/windows/win32/wua_sdk/opt-in-to-microsoft-update"
    $ServiceManager = New-Object -ComObject "Microsoft.Update.ServiceManager"

    # ServiceManager.Services
    Write-Host -ForegroundColor Blue "[$($DT)] [WindowsUpdate] Enable Windows Update for other Microsoft products"
    $ServiceID = "7971f918-a847-4430-9279-4a52d1efe18d"
    $ServiceManager.AddService2($ServiceId, 7, "") | Out-Null

    # Set query for updates
    Write-Host -ForegroundColor Blue "[$($DT)] [WindowsUpdate] Setup query for all available updates"
    $queries = @("IsInstalled=0 and Type='Software'", "IsInstalled=0 and Type='Driver'")

    # Create update collection 
    Write-Host -ForegroundColor Blue "[$($DT)] [WindowsUpdate] Creating empty collection of all updates to download"
    $WUUpdates = New-Object -ComObject Microsoft.Update.UpdateColl

    # Search udpates 
    Write-Host -ForegroundColor Blue "[$($DT)] [WindowsUpdate] Search updates and add to collection"        
    $queries | ForEach-Object {
        Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Getting $_ updates"      
        try {

            ((New-Object -ComObject Microsoft.Update.Session).CreateupdateSearcher().Search($_)).Updates | ForEach-Object {
                if (!$_.EulaAccepted) { $_.AcceptEula() }
                $featureUpdate = $_.Categories | Where-Object { $_.CategoryID -eq "3689BDC8-B205-4AF4-8D4A-A63924C5E9D5" }
                
                if ($featureUpdate) {
                    Write-Host -ForegroundColor Yellow "[$($DT)] [WindowsUpdate] Skipping feature update: $($_.Title)" 
                } 
                elseif ($_.Title -match "Preview") { 
                    Write-Host -ForegroundColor Yellow "[$($DT)] [WindowsUpdate] Skipping preview update: $($_.Title)" 
                } 
                else {
                    Write-Host -ForegroundColor Green "[$($DT)] [WindowsUpdate] Add $($_.Title) to collection" 
                    [void]$WUUpdates.Add($_)
                }
            }  

            if ($WUUpdates.Count -eq 0) {
                Write-Host -ForegroundColor Yellow "[$($DT)] [WindowsUpdate] No Updates Found" 
            } 
            else {
                Write-Host -ForegroundColor Green "[$($DT)] [WindowsUpdate] Updates found: $($WUUpdates.count)" 
                
                Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Start to install updates"    
                foreach ($update in $WUUpdates) {
                
                    Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Creating single update collection to download and install"
                    $singleUpdate = New-Object -ComObject Microsoft.Update.UpdateColl
                    $singleUpdate.Add($update) | Out-Null
                
                    $WUDownloader = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateDownloader()
                    $WUDownloader.Updates = $singleUpdate
                
                    $WUInstaller = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateInstaller()
                    $WUInstaller.Updates = $singleUpdate
                    $WUInstaller.ForceQuiet = $true
                
                    Write-Host -ForegroundColor Green "[$($DT)] [WindowsUpdate] Downloading update: $($update.Title)"
                    $Download = $WUDownloader.Download()
                    Write-Host -ForegroundColor Green "[$($DT)] [WindowsUpdate] Download result: $($Download.ResultCode) ($($Download.HResult))"
                
                    Write-Host -ForegroundColor Green "[$($DT)] [WindowsUpdate] Installing update: $($update.Title)"
                    $Results = $WUInstaller.Install()
                    Write-Host -ForegroundColor Green "[$($DT)] [WindowsUpdate] Install result: $($Results.ResultCode) ($($Results.HResult))"

                    if ($Results.ResultCode -eq 2) {
                        Write-Host -ForegroundColor Green "[$($DT)] [WindowsUpdate] All updates installed successfully" # result code 2 = success
                    }
                    else {
                        Write-Host -ForegroundColor Red "[$($DT)] [WindowsUpdate] Windows Updates failed"
                        Write-Host -ForegroundColor Red "[$($DT)] [WindowsUpdate] See result codes at: https://learn.microsoft.com/en-us/windows/win32/api/wuapi/ne-wuapi-operationresultcode"
                    }
                }
            } 
        } catch {
            # If this script is running during OOBE specialize, error 8024004A will happen:
            # 8024004A	Windows Update agent operations are not available while OS setup is running.
            Write-Host -ForegroundColor Red "[$($DT)] [WindowsUpdate] Unable to search for updates: $_" 
        }
    }
} 
else {    
    Write-Host -ForegroundColor Yellow "[$($DT)] [WindowsUpdate] No Updates will be installed"
}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] WindowsUpdate"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White  "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] Branding
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] Branding"
Write-Host -ForegroundColor DarkBlue $SL

try {
    # Install OneDrive per machine
    $dest = "C:\Windows\Temp\OneDriveSetup.exe"
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Copy OneDrive Setup from $($dest)"

    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Install OneDrive per machine"
    $proc = Start-Process $dest -ArgumentList "/allusers" -WindowStyle Hidden -PassThru
    $proc.WaitForExit()

    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] OneDriveSetup exit code: $($proc.ExitCode)"

    # Install Teams per machine
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Set Registry Keys"
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Changing OneDriveSetup value to point to the machine wide EXE"
    # Quotes are so problematic, we'll use the more risky approach and hope garbage collection cleans it up later
    & reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /f /reg:64 2>&1 | Out-Null
    & reg.exe query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /reg:64 2>&1 | Out-Null
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name OneDriveSetup -Value """C:\Program Files\Microsoft OneDrive\Onedrive.exe"" /background" | Out-Null
    
    $MsixDest = "C:\Windows\Temp\MSTeams-x64.msix"
    $TeamsDest = "C:\Windows\Temp\teamsbootstrapper.exe"
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Install Teams per machine"
    Write-Host -ForegroundColor Blue "Install Teams per machine"
    $proc = Start-Process $TeamsDest -ArgumentList "-p -o $MsixDest" -WindowStyle Hidden -PassThru
    $proc.WaitForExit()

    #===================================================================================================================================================
    #  Hide the widgets
    #  This will fail on Windows 11 24H2 due to UCPD, see https://kolbi.cz/blog/2024/04/03/userchoice-protection-driver-ucpd-sys/
    #  New Work Around tested with 24H2 to disable widgets as a preference
    #===================================================================================================================================================
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Hide the widgets"
    $ci = Get-ComputerInfo
    if ($ci.OsBuildNumber -ge 26100) {
        Write-Host -ForegroundColor Yellow "[$($DT)] [Branding] Attempting Widget Hiding workaround (TaskbarDa)"
        $regExePath = (Get-Command reg.exe).Source
        $tempRegExe = "$($env:TEMP)\reg1.exe"
        Copy-Item -Path $regExePath -Destination $tempRegExe -Force -ErrorAction Stop
        & $tempRegExe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f /reg:64 2>&1 | Out-Host
        Remove-Item $tempRegExe -Force -ErrorAction SilentlyContinue
        Write-Host -ForegroundColor Green "[$($DT)] [Branding] Widget Workaround Completed"
    } else {
        Write-Host -ForegroundColor Green "[$($DT)] [Branding] Hiding widgets with registry key"	
        & reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f /reg:64 2>&1 | Out-Host
    }

    #===================================================================================================================================================
    #  Disable Widgets (Grey out Settings Toggle)
    #  GPO settings below will completely disable Widgets, see:https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-newsandinterests#allownewsandinterests
    #===================================================================================================================================================
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Disable Widgets (Grey out Settings Toggle)"
    if (-not (Test-Path "HKLM:\Software\Policies\Microsoft\Dsh")) {
        New-Item -Path "HKLM:\Software\Policies\Microsoft\Dsh" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Dsh"  -Name "DisableWidgetsOnLockScreen" -Value 1
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Dsh"  -Name "DisableWidgetsBoard" -Value 1
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Dsh"  -Name "AllowNewsAndInterests" -Value 0

    #===================================================================================================================================================
    #   Don't let Edge create a desktop shortcut (roams to OneDrive, creates mess)
    #===================================================================================================================================================

    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Turning off (old) Edge desktop shortcut"
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v DisableEdgeDesktopShortcutCreation /t REG_DWORD /d 1 /f /reg:64 | Out-Host
    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "CreateDesktopShortcutDefault" /t REG_DWORD /d 0 /f /reg:64 | Out-Host

    #===================================================================================================================================================
    #   Remove Personal Teams
    #===================================================================================================================================================
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Remove Personal Teams"
    Get-AppxPackage -Name MicrosoftTeams -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue 

    #===================================================================================================================================================
    #   Disable network location fly-out
    #===================================================================================================================================================
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Disable network location fly-out"
    reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" /f

    #===================================================================================================================================================
    #   Stop Start menu from opening on first logon
    #===================================================================================================================================================
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Stop Start menu from opening on first logon"
    reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v StartShownOnUpgrade /t REG_DWORD /d 1 /f | Out-Host

    #===================================================================================================================================================
    #   Hide "Learn more about this picture" from the desktop
    #===================================================================================================================================================
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Hide 'Learn more about this picture' from the desktop"
    reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{2cc5ca98-6485-489a-920e-b3e88a6ccce3}" /t REG_DWORD /d 1 /f | Out-Host

    #===================================================================================================================================================
    #   Disable Windows Spotlight as per https://github.com/mtniehaus/AutopilotBranding/issues/13#issuecomment-2449224828
    #===================================================================================================================================================
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Disable Windows Spotlight"
    reg.exe add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v DisableSpotlightCollectionOnDesktop /t REG_DWORD /d 1 /f | Out-Host

    #===================================================================================================================================================
    #   Remediate Windows Update policy conflict for Autopatch
    #===================================================================================================================================================
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Remediate Windows Update policy conflict for Autopatch"
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
              Write-Host -ForegroundColor Yellow "[$($DT)] [Branding] $($setting.name) was not found"
        }
    }

    #===================================================================================================================================================
    #   Set registered user and organization
    #===================================================================================================================================================
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Set registered user and organization"
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOwner /t REG_SZ /d "Global IT" /f /reg:64 | Out-Host
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOrganization /t REG_SZ /d "SIGVARIS GROUP" /f /reg:64 | Out-Host

    #===================================================================================================================================================
    #   Configure OEM branding info
    #===================================================================================================================================================
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Configure OEM branding info"
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Manufacturer /t REG_SZ /d "SIGVARIS GROUP" /f /reg:64 | Out-Host
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Model /t REG_SZ /d "Autopilot" /f /reg:64 | Out-Host
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v SupportURL /t REG_SZ /d "https://sigvarisitcustomercare.saasiteu.com/Account/Login?ProviderName=AAD" /f /reg:64 | Out-Host
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Logo /t REG_SZ /d "C:\Windows\sigvaris.bmp" /f /reg:64 | Out-Host

    #===================================================================================================================================================
    #    Disable extra APv2 pages (too late to do anything about the EULA), see https://call4cloud.nl/autopilot-device-preparation-hide-privacy-settings/
    #===================================================================================================================================================
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Disable extra APv2 pages (too late to do anything about the EULA)"
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE"
    New-ItemProperty -Path $registryPath -Name "DisablePrivacyExperience" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "DisableVoice" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "PrivacyConsentStatus" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "ProtectYourPC" -Value 3 -PropertyType DWord -Force | Out-Null

    #===================================================================================================================================================
    #    Skip FSIA and turn off delayed desktop switch
    #===================================================================================================================================================
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Skip FSIA and turn off delayed desktop switch"
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    New-ItemProperty -Path $registryPath -Name "EnableFirstLogonAnimation" -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "DelayedDesktopSwitch" -Value 0 -PropertyType DWord -Force | Out-Null

    #===================================================================================================================================================
    #    Enable .NET Framework 3.5 for US, CA
    #===================================================================================================================================================
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Enable .NET Framework 3.5 for US, CA"
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
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Enable Printing-PrintToPDFServices-Features because of KB5058411"
    Disable-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features -NoRestart -ErrorAction SilentlyContinue
    Enable-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features -NoRestart -ErrorAction SilentlyContinue

    #===================================================================================================================================================
    #    Remove OSDCloudRegistration Certificate
    #===================================================================================================================================================
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Remove Import-Certificate.ps1 script"
    if (Test-Path -Path $env:SystemDrive\OSDCloud\Scripts\Import-Certificate.ps1) {
        Remove-Item -Path $env:SystemDrive\OSDCloud\Scripts\Import-Certificate.ps1 -Force
    }

    #===================================================================================================================================================
    #    Remove C:\Windows\Setup\Scripts\ Items
    #===================================================================================================================================================
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Remove C:\Windows\Setup\Scripts Items"
    Remove-Item C:\Windows\Setup\Scripts\*.* -Exclude *.TAG -Force | Out-Null

    #===================================================================================================================================================
    #    Copy OSDCloud logs and delete C:\OSDCloud folder
    #===================================================================================================================================================
    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Copy OSDCloud logs and delete C:\OSDCloud folder"
    Copy-Item -Path "C:\OSDCloud\Logs\*" -Destination "C:\ProgramData\OSDeploy" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    Remove-Item C:\OSDCloud -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item C:\ProgramData\OSDeploy\WiFi -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

    Write-Host -ForegroundColor Blue "[$($DT)] [Branding] Set Computername to $($OSDComputername)"
    Rename-Computer -NewName $OSDComputername

    # Exit code Soft Reboot
    Exit 3010
} 
catch [System.Exception] {
    Write-Host -ForegroundColor Red "[$($DT)] [Forescout] Branding failed with error: " -NoNewline
    Write-Host -ForegroundColor Yellow "$($_.Exception.Message)"
}    


$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Branding"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor Cyan  "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# End Script
# ================================================================================================================================================~
$EndTime = Get-Date
$ExecutionTime = $EndTime - $StartTime

Write-Host -ForegroundColor Blue "[$($DT)] [Start] Script end at: " -NoNewline
Write-Host -ForegroundColor Cyan "$($EndTime)"
Write-Host -ForegroundColor Blue "[$($DT)] [End] Script took " -NoNewline 
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes)"
Write-Host -ForegroundColor Blue " minutes to execute"

Stop-Transcript | Out-Null