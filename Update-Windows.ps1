# Check if running in x64bit environment
Write-Host -ForegroundColor Green "Is 64bit PowerShell: $([Environment]::Is64BitProcess)"
Write-Host -ForegroundColor Green "Is 64bit OS: $([Environment]::Is64BitOperatingSystem)"

Write-Host -ForegroundColor Green "Install Windows Updates: " -NoNewline
Write-Host -ForegroundColor Yellow "Update-Windows.ps1"

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

start-Sleep -Seconds 10

# Check Internet Connection
$AllNetConnectionProfiles = Get-NetConnectionProfile
$AllNetConnectionProfiles | Where-Object {$_.IPv4Connectivity -eq 'Internet' -or $_.IPv6Connectivity -eq 'Internet'}
if ($AllNetConnectionProfiles) { 
    Write-Host -ForegroundColor Green "Internet connection succesfull"
    Write-Output $AllNetConnectionProfiles
}
else {
    Write-Host -ForegroundColor Yellow "No Internet Connection. Start Wi-Fi setup."  
    Start-Process -FilePath C:\Windows\WirelessConnect.exe -Wait
    start-Sleep -Seconds 10
}

# Script Local Variables
$DT = Get-Date -format G
$LogFilePath = "C:\ProgramData\OSDeploy"
$LogFile = "Update-Windows.log"

If (!(Test-Path $LogFilePath)) { New-Item $LogFilePath -ItemType Directory -Force | Out-Null }
Start-Transcript -Path (Join-Path $LogFilePath $LogFile) -ErrorAction Ignore

Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Windows Updates enabled: $($OSDWindowsUpdate)"

# Opt into Microsoft Update
Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Opt computer in to the Microsoft Update service and then register that service with Automatic Updates"
Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] https://learn.microsoft.com/en-us/windows/win32/wua_sdk/opt-in-to-microsoft-update"
$ServiceManager = New-Object -ComObject "Microsoft.Update.ServiceManager"

# ServiceManager.Services
Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Enable Windows Update for other Microsoft products"
$ServiceID = "7971f918-a847-4430-9279-4a52d1efe18d"
$ServiceManager.AddService2($ServiceId, 7, "") | Out-Null

# Set query for updates
Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Setup query for all available updates"
$queries = @("IsInstalled=0 and Type='Software'")

# Create update collection 
Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Creating empty collection of all updates to download"
$WUUpdates = New-Object -ComObject Microsoft.Update.UpdateColl

# Search udpates 
Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Search updates and add to collection"        
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
                    Write-Host -ForegroundColor Yellow "[$($DT)] [WindowsUpdate] Windows Updates failed"
                    Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] See result codes at: https://learn.microsoft.com/en-us/windows/win32/api/wuapi/ne-wuapi-operationresultcode"
                }
            }
        } 

        # Uninstall blocking language Update
        # Microsoft Community notes that after installing KB5050009, 
        # users might experience situations where the new display language 
        # isn't fully applied, leaving some elements of the UI, 
        # such as the Settings side panel or desktop icon labels, 
        # in English or a different language. This is particularly noticeable 
        # if additional languages were previously installed
        #Write-Host -ForegroundColor Yellow "[$($DT)] [WindowsUpdate] Uninstall KB5050009 because of the display language issue"
        #wusa /uninstall /kb:5050009 /quiet /norestart 

    } catch {
        # If this script is running during OOBE specialize, error 8024004A will happen:
        # 8024004A	Windows Update agent operations are not available while OS setup is running.
        Write-Host -ForegroundColor Red "[$($DT)] [WindowsUpdate] Unable to search for updates: $_" 
    }
}

Stop-Transcript | Out-Null