#=============================================================================================================================
#
# Script Name:     Update-Windows.ps1
# Description:     Install Windows Updates
# Link:            https://github.com/mtniehaus/UpdateOS/blob/main/UpdateOS/UpdateOS.ps1
# Created:         06/18/2025
# Version:         1.0
#
#=============================================================================================================================

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

If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null}
$Global:Transcript = "Update-Windows.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

#=======================================================================
#   Load UIjson.json file
#=======================================================================
Write-Host -ForegroundColor Green "Load C:\ProgramData\OSDeploy\UIjson.json file"
$json = Get-Content -Path "C:\ProgramData\OSDeploy\UIjson.json" -Raw | ConvertFrom-Json

# Access JSON properties
$OSDWindowsUpdate = $json.OSDWindowsUpdate
$OSDTimeZone = $json.OSDTimeZone

#===================================================================================================================================================
#  Set TimeZone
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Set TimeZone to $($OSDTimeZone)"
Set-TimeZone -Id $OSDTimeZone
tzutil.exe /s "$($OSDTimeZone)"  

try {

    If ($OSDWindowsUpdate -eq "Yes") {    
        
        # Params
        $ExcludeDrivers = $false
        $ExcludeUpdates = $false

        # Main logic
        $script:needReboot = $false

        # Opt into Microsoft Update
        $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
        Write-Host -ForegroundColor Green "$ts Opting into Microsoft Update"
        $ServiceManager = New-Object -ComObject "Microsoft.Update.ServiceManager"
        $ServiceID = "7971f918-a847-4430-9279-4a52d1efe18d"
        $ServiceManager.AddService2($ServiceId, 7, "") | Out-Null

        # Install all available updates
        $WUDownloader = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateDownloader()
        $WUInstaller = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateInstaller()
        if ($ExcludeDrivers) {
            # Updates only
            Write-Host "$ts Only Windows updates will be installed"
            $queries = @("IsInstalled=0 and Type='Software'")
        }
        elseif ($ExcludeUpdates) {
            # Drivers only
            Write-Host "$ts Only drivers will be installed"
            $queries = @("IsInstalled=0 and Type='Driver'")
        } else {
            # Both
            Write-Host "$ts Drivers and Windows updates will be installed"
            $queries = @("IsInstalled=0 and Type='Software'", "IsInstalled=0 and Type='Driver'")
        }

        $WUUpdates = New-Object -ComObject Microsoft.Update.UpdateColl
        $queries | ForEach-Object {
        $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
        Write-Host -ForegroundColor Green "$ts Getting $_ updates."        
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
            }
        }

        $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
        if ($WUUpdates.Count -eq 0) {
            Write-Host -ForegroundColor Green "$ts No Updates Found"
            Stop-Transcript | Out-Null
            Exit 0
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

        }
    }
    else {
        Write-Host -ForegroundColor Yellow "No Windows Updates installed"
        Stop-Transcript | Out-Null
    }
} 
catch [System.Exception] {
    Write-Host -ForegroundColor Red "Windows Updates failed with error: $($_.Exception.Message)"
    Stop-Transcript | Out-Null
    exit 1
}
