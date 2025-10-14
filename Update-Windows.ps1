# Check if running in x64bit environment
Write-Host -ForegroundColor Gray "Is 64bit PowerShell: $([Environment]::Is64BitProcess)"
Write-Host -ForegroundColor Gray "Is 64bit OS: $([Environment]::Is64BitOperatingSystem)"

Write-Host -ForegroundColor Gray "Script: " -NoNewline
Write-Host -ForegroundColor Cyan "Update-Windows.ps1"

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
$ScriptName = 'Update-Windows.ps1' # Name
$ScriptDescription = 'This script uses the Windows Update COM objects to install the latest updates for Windows' # Description: https://github.com/mtniehaus/UpdateOS/blob/main/UpdateOS/UpdateOS.ps1
$ScriptVersion = '1.0' # Version
$ScriptDate = '14.10.2025' # Created on
$ScriptUpdateDate = '' # Update on
$ScriptUpdateReason = '' # Update reason
$ScriptDepartment = 'Workplace & GA Team' # Department
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
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] SECTION took " -NoNewline
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
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] SECTION took " -NoNewline
Write-Host -ForegroundColor Cyan  "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Gray  "minutes to execute."
Write-Host -ForegroundColor DarkGray $SL

# ================================================================================================================================================~
# [SECTION] WindowsUpdate
# ================================================================================================================================================~
If ($OSDDomainJoin -eq "Yes") { 
    $SectionStartTime = Get-Date
    Write-Host -ForegroundColor DarkGray $SL
    Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-Start][WindowsUpdate"
    Write-Host -ForegroundColor DarkGray $SL

    Write-Host -ForegroundColor Yellow "[$(Get-Date -Format G)] [WindowsUpdate] Windows updates must be installed before before domain join"

    # Opt into Microsoft Update
    Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [WindowsUpdate] Opt computer in to the Microsoft Update service and then register that service with Automatic Updates"
    Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [WindowsUpdate] https://learn.microsoft.com/en-us/windows/win32/wua_sdk/opt-in-to-microsoft-update"
    $ServiceManager = New-Object -ComObject "Microsoft.Update.ServiceManager"
    #$ServiceManager.Services
    Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [WindowsUpdate] Enable Windows Update for other Microsoft products"
    $ServiceID = "7971f918-a847-4430-9279-4a52d1efe18d"
    $ServiceManager.AddService2($ServiceId, 7, "") | Out-Null
    #$ServiceManager.Services

    # Set query for updates
    Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [WindowsUpdate] Setup query for all available updates and drivers"
    $queries = @("IsInstalled=0 and Type='Software'", "IsInstalled=0 and Type='Driver'")
    
    # Create update collection 
    Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [WindowsUpdate] Creating empty collection of all updates to download"
    $WUUpdates = New-Object -ComObject Microsoft.Update.UpdateColl
    
    # Search udpates 
    Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [WindowsUpdate] Search updates and add to collection"        
    $queries | ForEach-Object {
        Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [WindowsUpdate] Getting $_ updates"      
        try {
            ((New-Object -ComObject Microsoft.Update.Session).CreateupdateSearcher().Search($_)).Updates | ForEach-Object {
                if (!$_.EulaAccepted) { $_.AcceptEula() }
                $featureUpdate = $_.Categories | Where-Object { $_.CategoryID -eq "3689BDC8-B205-4AF4-8D4A-A63924C5E9D5" }
                if ($featureUpdate) {
                    Write-Host -ForegroundColor Yellow "[$(Get-Date -Format G)] [WindowsUpdate] Skipping feature update: $($_.Title)" 
                } elseif ($_.Title -match "Preview") { 
                    Write-Host -ForegroundColor Yellow "[$(Get-Date -Format G)] [WindowsUpdate] Skipping preview update: $($_.Title)" 
                } else {
                    Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [WindowsUpdate] Add $($_.Title) to collection" 
                    [void]$WUUpdates.Add($_)
                }

            
            }
        } catch {
            # If this script is running during OOBE specialize, error 8024004A will happen:
            # 8024004A	Windows Update agent operations are not available while OS setup is running.
            Write-Host -ForegroundColor Red "[$(Get-Date -Format G)] [WindowsUpdate] Unable to search for updates: $_" 
            Stop-Transcript | Out-Null
            Exit 1
        }
    }

    if ($WUUpdates.Count -eq 0) {
        Write-Host -ForegroundColor Yellow "[$(Get-Date -Format G)] [WindowsUpdate] No Updates Found" 
        Stop-Transcript | Out-Null
        Exit 0
    } else {
        Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [WindowsUpdate] Updates found: $($WUUpdates.count)" 
        
        Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [WindowsUpdate] Start to install updates"    
        foreach ($update in $WUUpdates) {
        
            Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [WindowsUpdate] Creating single update collection to download and install"
            $singleUpdate = New-Object -ComObject Microsoft.Update.UpdateColl
            $singleUpdate.Add($update) | Out-Null
        
            $WUDownloader = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateDownloader()
            $WUDownloader.Updates = $singleUpdate
        
            $WUInstaller = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateInstaller()
            $WUInstaller.Updates = $singleUpdate
            $WUInstaller.ForceQuiet = $true
        
            Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [WindowsUpdate] Downloading update: $($update.Title)"
            $Download = $WUDownloader.Download()
            Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [WindowsUpdate] Download result: $($Download.ResultCode) ($($Download.HResult))"
        
            Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [WindowsUpdate] Installing update: $($update.Title)"
            $Results = $WUInstaller.Install()
            Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [WindowsUpdate] Install result: $($Results.ResultCode) ($($Results.HResult))"

            # result code 2 = success, see https://learn.microsoft.com/en-us/windows/win32/api/wuapi/ne-wuapi-operationresultcode
        }
    }
} 

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] WindowsUpdate"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] SECTION took " -NoNewline
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
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes)" -NoNewline 
Write-Host -ForegroundColor Gray " minutes to execute"

start-Sleep -Seconds 10

Stop-Transcript | Out-Null