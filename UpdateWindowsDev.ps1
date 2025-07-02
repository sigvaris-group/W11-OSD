$Title = "Install Windows Updates"
$host.UI.RawUI.WindowTitle = $Title
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

$env:APPDATA = "C:\Windows\System32\Config\SystemProfile\AppData\Roaming"
$env:LOCALAPPDATA = "C:\Windows\System32\Config\SystemProfile\AppData\Local"
$Env:PSModulePath = $env:PSModulePath+";C:\Program Files\WindowsPowerShell\Scripts"
$env:Path = $env:Path+";C:\Program Files\WindowsPowerShell\Scripts"

# Check if running in x64bit environment
Write-Host -ForegroundColor Green "Is 64bit PowerShell: $([Environment]::Is64BitProcess)"
Write-Host -ForegroundColor Green "Is 64bit OS: $([Environment]::Is64BitOperatingSystem)"

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
$ScriptName = 'UpdateWindowsDev.ps1' # Name
$ScriptDescription = 'This script uses the Windows Update COM objects to install the latest updates for Windows 11.' # Description
$ScriptEnv = 'Development' # Environment: Production, Offline, Development
$ScriptVersion = '1.0' # Version
$ScriptDate = '02.07.2025' # Created on
$ScriptURL = 'https://github.com/mtniehaus/UpdateOS/blob/main/UpdateOS/UpdateOS.ps1' # Copied from 
$ScriptUpdateDate = '' # Update on
$ScriptUpdateReason = '' # Update reason
$ScriptDepartment = 'Global IT' # Department
$ScriptAuthor = 'Andreas Schilling' # Author

# Updates
$UpdateNews = @(
"02.07.2025 [TEST] Install Windows Updates"
)

# Script Local Variables
$Error.Clear()
$SL = "================================================================================================================================================~"
$EL = "`n================================================================================================================================================~`n"
$DT = Get-Date -format G
$LogFilePath = 'C:\ProgramData\OSDeploy'
$LogFile = $ScriptName -replace ".{3}$", "log"
$StartTime = Get-Date

If (!(Test-Path $LogFilePath)) { New-Item $LogFilePath -ItemType Directory -Force | Out-Null }
Start-Transcript -Path (Join-Path $LogFilePath $LogFile) -ErrorAction Ignore
Write-Host -ForegroundColor Green "[$($DT)] [Start]  Script started $($StartTime)"

# Script Information
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [Start]  Install Windows Updates"
Write-Host -ForegroundColor Cyan "Name:             $($ScriptName)"
Write-Host -ForegroundColor Cyan "Description:      $($ScriptDescription)"
Write-Host -ForegroundColor Cyan "Environment:      $($ScriptEnv)"
Write-Host -ForegroundColor Cyan "Version:          $($ScriptVersion)"
Write-Host -ForegroundColor Cyan "Created on:       $($ScriptDate)"
Write-Host -ForegroundColor Cyan "Copied from:      $($ScriptURL)"
Write-Host -ForegroundColor Cyan "Update on:        $($ScriptUpdateDate)"
Write-Host -ForegroundColor Cyan "Update reason:    $($ScriptUpdateReason )"
Write-Host -ForegroundColor Cyan "Department:       $($ScriptDepartment)"
Write-Host -ForegroundColor Cyan "Author:           $($ScriptAuthor)"
Write-Host -ForegroundColor Cyan "Logfile Path:     $($LogFilePath)"
Write-Host -ForegroundColor Cyan "Logfile:          $($LogFile)"
Write-Host -ForegroundColor Cyan "Start time:       $($StartTime)"
Write-Host -ForegroundColor DarkBlue $EL

# Updates
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [Updates] Below you find the newest updates of the script"
Write-Host -ForegroundColor DarkBlue $SL
foreach ($UpdateNew in $UpdateNews) {
    Write-Host -ForegroundColor Green "$($UpdateNew)"
}
Write-Host -ForegroundColor DarkBlue $EL


# IPConfig 
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [Network] Network information"
Write-Host -ForegroundColor DarkBlue $SL
$IPConfig = Get-NetIPConfiguration
Write-Host -ForegroundColor Cyan "[$($DT)] [Network] Get-NetIPConfiguration"
Write-Output $IPConfig
Write-Host -ForegroundColor DarkBlue $EL


# Load UIjson.json file
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [UI] Load UIjson.json file"
Write-Host -ForegroundColor DarkBlue $SL
$json = Get-Content -Path "C:\ProgramData\OSDeploy\UIjson.json" -Raw | ConvertFrom-Json
$OSDWindowsUpdate = $json.OSDWindowsUpdate
$OSDTimeZone = $json.OSDTimeZone

Write-Host -ForegroundColor Cyan "[$($DT)] [UI] Your Settings are:"
Write-Host -ForegroundColor Green "Windows Updates: $OSDWindowsUpdate"
Write-Host -ForegroundColor Green "TimeZone: $OSDTimeZone "


# Set TimeZone
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [TimeZone] Set TimeZone"
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Cyan "[$($DT)] [TimeZone] Set TimeZone to $($OSDTimeZone)"
Set-TimeZone -Id $OSDTimeZone
tzutil.exe /s "$($OSDTimeZone)"  


# Start Windows Updates 
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [WindowsUpdate] Start Windows Update Process"
Write-Host -ForegroundColor DarkBlue $SL
If ($OSDWindowsUpdate -eq "Yes") { 
    Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Windows Updates enabled: $($OSDWindowsUpdate)"

    try {

        # Opt into Microsoft Update
        Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Opt computer in to the Microsoft Update service and then register that service with Automatic Updates"
        Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] https://learn.microsoft.com/en-us/windows/win32/wua_sdk/opt-in-to-microsoft-update"
        $ServiceManager = New-Object -ComObject "Microsoft.Update.ServiceManager"
        Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Add the Microsoft Update Service, GUID"
        $ServiceID = "7971f918-a847-4430-9279-4a52d1efe18d"
        $ServiceManager.AddService2($ServiceId, 7, "") | Out-Null

        # Install all available updates
        Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Install all available updates and drivers"
        $WUDownloader = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateDownloader()
        $WUInstaller = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateInstaller()
        $queries = @("IsInstalled=0 and Type='Software'", "IsInstalled=0 and Type='Driver'")
        $WUUpdates = New-Object -ComObject Microsoft.Update.UpdateColl

        $queries | ForEach-Object {
            Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Getting $_ updates"      
            try {
                ((New-Object -ComObject Microsoft.Update.Session).CreateupdateSearcher().Search($_)).Updates | ForEach-Object {
                    if (!$_.EulaAccepted) { $_.AcceptEula() }
                    $featureUpdate = $_.Categories | Where-Object { $_.CategoryID -eq "3689BDC8-B205-4AF4-8D4A-A63924C5E9D5" }
                    if ($featureUpdate) {
                        $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
                        Write-Host -ForegroundColor Green "$ts Skipping feature update: $($_.Title)"
                    } elseif ($_.Title -match "Preview") { 
                        $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
                        Write-Host -ForegroundColor Green "$ts Skipping preview update: $($_.Title)"
                    } else {
                        [void]$WUUpdates.Add($_)
                    }
                }
            } catch {
                # If this script is running during specialize, error 8024004A will happen:
                # 8024004A	Windows Update agent operations are not available while OS setup is running.
                $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
                Write-Warning "$ts Unable to search for updates: $_"
                $PSWU = $false
            }
        }
    }
    catch {
        <#Do this if a terminating exception happens#>
    }
    finally {
        <#Do this after the try block regardless of whether an exception occurred or not#>
    }
}
    
        ((New-Object -ComObject Microsoft.Update.Session).CreateupdateSearcher().Search($_)).Updates | ForEach-Object {
            if (!$_.EulaAccepted) { $_.AcceptEula() }
            $featureUpdate = $_.Categories | Where-Object { $_.CategoryID -eq "3689BDC8-B205-4AF4-8D4A-A63924C5E9D5" }
            if ($featureUpdate) {
                $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
                Write-Host -ForegroundColor Green "$ts Skipping feature update: $($_.Title)"
            } elseif ($_.Title -match "Preview") { 
                $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
                Write-Host -ForegroundColor Green "$ts Skipping preview update: $($_.Title)"
            } else {
                [void]$WUUpdates.Add($_)
            }
        }

        $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
        if ($WUUpdates.Count -eq 0) {
            Write-Host -ForegroundColor Green "$ts No Updates found: Use PSWindowsUpdate Module"
            $PSWU = $true 
            
        } else {
            Write-Host -ForegroundColor Green "$ts Updates found: $($WUUpdates.count)"
        }
        
        foreach ($update in $WUUpdates) {
        
            $singleUpdate = New-Object -ComObject Microsoft.Update.UpdateColl
            $singleUpdate.Add($update) | Out-Null
        
            $WUDownloader = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateDownloader()
            $WUDownloader.Updates = $singleUpdate
        
            $WUInstaller = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateInstaller()
            $WUInstaller.Updates = $singleUpdate
            $WUInstaller.ForceQuiet = $true
        
            $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
            Write-Host -ForegroundColor Green "$ts Downloading update: $($update.Title)"
            $Download = $WUDownloader.Download()
            $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
            Write-Host -ForegroundColor Green "$ts   Download result: $($Download.ResultCode) ($($Download.HResult))"
        
            $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
            Write-Host -ForegroundColor Green "$ts Installing update: $($update.Title)"
            $Results = $WUInstaller.Install()
            $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
            Write-Host -ForegroundColor Green "$ts   Install result: $($Results.ResultCode) ($($Results.HResult))"

            # result code 2 = success, see https://learn.microsoft.com/en-us/windows/win32/api/wuapi/ne-wuapi-operationresultcode

            Stop-Transcript | Out-Null  
        }
    }
    catch {
        <#Do this if a terminating exception happens#>
    }
    finally {
        Write-Host -ForegroundColor DarkBlue $SL
        Write-Host -ForegroundColor Blue "[$($DT)] [End] Install Windows Updates"
        Write-Host -ForegroundColor DarkBlue $SL

        $EndTime = Get-Date
        $ExecutionTime = $EndTime - $StartTime

        Write-Host -ForegroundColor Green "[$($DT)] [End] Script ended $($EndTime)"
        Write-Host -ForegroundColor Green "[$($DT)] [End] Script took $($ExecutionTime.Minutes) minutes to execute"
        Stop-Transcript | Out-Null  
    }
}


