# Check if running in x64bit environment
Write-Host -ForegroundColor Green "Is 64bit PowerShell: $([Environment]::Is64BitProcess)"
Write-Host -ForegroundColor Green "Is 64bit OS: $([Environment]::Is64BitOperatingSystem)"

Write-Host -ForegroundColor Green "Windows Branding: " -NoNewline
Write-Host -ForegroundColor Yellow "AutopilotBranding.ps1"

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

If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null}
$Global:Transcript = "AutopilotBranding.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

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


#===================================================================================================================================================
#   Load UIjson.json file
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Load C:\ProgramData\OSDeploy\UIjson.json file"
$json = Get-Content -Path "C:\ProgramData\OSDeploy\UIjson.json" -Raw | ConvertFrom-Json

# Access JSON properties
$OSDTimeZone = $json.OSDTimeZone
$OSDComputername = $json.OOSDComputername

try {
    #===================================================================================================================================================
    #    Install OneDrive per machine
    #===================================================================================================================================================
    # Copy OneDriveSetup.exe local
    #Write-Host -ForegroundColor Green "Downloading OneDriveSetup.exe file"
    $dest = "C:\Windows\Temp\OneDriveSetup.exe"
    #Invoke-WebRequest "https://go.microsoft.com/fwlink/?linkid=844652" -OutFile $dest -Verbose
    Write-Host -ForegroundColor Green "Install OneDrive per machine"
    $proc = Start-Process $dest -ArgumentList "/allusers" -WindowStyle Hidden -PassThru
    $proc.WaitForExit()
    Write-Host -ForegroundColor Yellow "  OneDriveSetup exit code: $($proc.ExitCode)"
    Write-Host -ForegroundColor Yellow "  Making sure the Run key exists"
    & reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /f /reg:64 2>&1 | Out-Null
    & reg.exe query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /reg:64 2>&1 | Out-Null
    Write-Host -ForegroundColor Yellow "  Changing OneDriveSetup value to point to the machine wide EXE"
    # Quotes are so problematic, we'll use the more risky approach and hope garbage collection cleans it up later
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name OneDriveSetup -Value """C:\Program Files\Microsoft OneDrive\Onedrive.exe"" /background" | Out-Null

    #===================================================================================================================================================
    #    Install Teams per machine
    #===================================================================================================================================================
    #Write-Host -ForegroundColor Green "Downloading Msix file"
    #$Msixx64Url = 'https://go.microsoft.com/fwlink/?linkid=2196106'
    $MsixDest = "C:\Windows\Temp\MSTeams-x64.msix"
    #Invoke-WebRequest $Msixx64Url -OutFile $MsixDest -Verbose
    #Write-Host -ForegroundColor Green "Downloading teamsbootstrapper file"
    #$Teamsx64Url = 'https://go.microsoft.com/fwlink/?linkid=2243204'
    $TeamsDest = "C:\Windows\Temp\teamsbootstrapper.exe"
    #Invoke-WebRequest $Teamsx64Url -OutFile $TeamsDest -Verbose
    Write-Host -ForegroundColor Green "Install Teams per machine"
    $proc = Start-Process $TeamsDest -ArgumentList "-p -o $MsixDest" -WindowStyle Hidden -PassThru
    $proc.WaitForExit()

    <#
    #===================================================================================================================================================
    #   Enable location services so the time zone will be set automatically (even when skipping the privacy page in OOBE) when an administrator signs in
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Enable location services to automatically set the time zone"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type "String" -Value "Allow" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type "DWord" -Value 1 -Force -ErrorAction SilentlyContinue
    Start-Service -Name "lfsvc" -ErrorAction SilentlyContinue
    #>

    #===================================================================================================================================================
    #  Hide the widgets
    #  This will fail on Windows 11 24H2 due to UCPD, see https://kolbi.cz/blog/2024/04/03/userchoice-protection-driver-ucpd-sys/
    #  New Work Around tested with 24H2 to disable widgets as a preference
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Hide the widgets"
    $ci = Get-ComputerInfo
    if ($ci.OsBuildNumber -ge 26100) {
        Write-Host -ForegroundColor Yellow "  Attempting Widget Hiding workaround (TaskbarDa)"
        $regExePath = (Get-Command reg.exe).Source
        $tempRegExe = "$($env:TEMP)\reg1.exe"
        Copy-Item -Path $regExePath -Destination $tempRegExe -Force -ErrorAction Stop
        & $tempRegExe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f /reg:64 2>&1 | Out-Host
        Remove-Item $tempRegExe -Force -ErrorAction SilentlyContinue
        Write-Host -ForegroundColor Green "Widget Workaround Completed"
    } else {
        Write-Host -ForegroundColor Green "Hiding widgets"	
        & reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f /reg:64 2>&1 | Out-Host
    }

    #===================================================================================================================================================
    #  Disable Widgets (Grey out Settings Toggle)
    #  GPO settings below will completely disable Widgets, see:https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-newsandinterests#allownewsandinterests
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Disable Widgets (Grey out Settings Toggle)"
    if (-not (Test-Path "HKLM:\Software\Policies\Microsoft\Dsh")) {
        New-Item -Path "HKLM:\Software\Policies\Microsoft\Dsh" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Dsh"  -Name "DisableWidgetsOnLockScreen" -Value 1
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Dsh"  -Name "DisableWidgetsBoard" -Value 1
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Dsh"  -Name "AllowNewsAndInterests" -Value 0

    #===================================================================================================================================================
    #   Don't let Edge create a desktop shortcut (roams to OneDrive, creates mess)
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Turning off (old) Edge desktop shortcut"
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v DisableEdgeDesktopShortcutCreation /t REG_DWORD /d 1 /f /reg:64 | Out-Host
    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "CreateDesktopShortcutDefault" /t REG_DWORD /d 0 /f /reg:64 | Out-Host

    #===================================================================================================================================================
    #   Remove Personal Teams
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Remove Personal Teams"
    Get-AppxPackage -Name MicrosoftTeams -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue 

    #===================================================================================================================================================
    #   Disable network location fly-out
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Disable network location fly-out"
    reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" /f

    #===================================================================================================================================================
    #   Stop Start menu from opening on first logon
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Stop Start menu from opening on first logon"
    reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v StartShownOnUpgrade /t REG_DWORD /d 1 /f | Out-Host

    #===================================================================================================================================================
    #   Hide "Learn more about this picture" from the desktop
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Hide 'Learn more about this picture' from the desktop"
    reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{2cc5ca98-6485-489a-920e-b3e88a6ccce3}" /t REG_DWORD /d 1 /f | Out-Host

    #===================================================================================================================================================
    #   Disable Windows Spotlight as per https://github.com/mtniehaus/AutopilotBranding/issues/13#issuecomment-2449224828
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Disable Windows Spotlight"
    reg.exe add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v DisableSpotlightCollectionOnDesktop /t REG_DWORD /d 1 /f | Out-Host

    #===================================================================================================================================================
    #   Remediate Windows Update policy conflict for Autopatch
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Remediate Windows Update policy conflict for Autopatch"
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
            write-host "$($setting.name) was not found"
        }
    }

    #===================================================================================================================================================
    #   Set registered user and organization
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Set registered user and organization"
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOwner /t REG_SZ /d "Global IT" /f /reg:64 | Out-Host
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOrganization /t REG_SZ /d "SIGVARIS GROUP" /f /reg:64 | Out-Host

    #===================================================================================================================================================
    #   Configure OEM branding info
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Configure OEM branding info"
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Manufacturer /t REG_SZ /d "SIGVARIS GROUP" /f /reg:64 | Out-Host
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Model /t REG_SZ /d "Autopilot" /f /reg:64 | Out-Host
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v SupportURL /t REG_SZ /d "https://sigvarisitcustomercare.saasiteu.com/Account/Login?ProviderName=AAD" /f /reg:64 | Out-Host
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Logo /t REG_SZ /d "C:\Windows\sigvaris.bmp" /f /reg:64 | Out-Host

    #===================================================================================================================================================
    #    Disable extra APv2 pages (too late to do anything about the EULA), see https://call4cloud.nl/autopilot-device-preparation-hide-privacy-settings/
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Disable extra APv2 pages (too late to do anything about the EULA)"
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE"
    New-ItemProperty -Path $registryPath -Name "DisablePrivacyExperience" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "DisableVoice" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "PrivacyConsentStatus" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "ProtectYourPC" -Value 3 -PropertyType DWord -Force | Out-Null

    #===================================================================================================================================================
    #    Skip FSIA and turn off delayed desktop switch
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green 'Skip FSIA and turn off delayed desktop switch'
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    New-ItemProperty -Path $registryPath -Name "EnableFirstLogonAnimation" -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "DelayedDesktopSwitch" -Value 0 -PropertyType DWord -Force | Out-Null

    #===================================================================================================================================================
    #    Enable .NET Framework 3.5 for US, CA
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green 'Enable .NET Framework 3.5 for US, CA'
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
    Write-Host -ForegroundColor Green 'Enable Printing-PrintToPDFServices-Features because of KB5058411'
    Disable-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features -NoRestart -ErrorAction SilentlyContinue
    Enable-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features -NoRestart -ErrorAction SilentlyContinue

    #===================================================================================================================================================
    #    Remove OSDCloudRegistration Certificate
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Remove Import-Certificate.ps1 script"
    if (Test-Path -Path $env:SystemDrive\OSDCloud\Scripts\Import-Certificate.ps1) {
        Remove-Item -Path $env:SystemDrive\OSDCloud\Scripts\Import-Certificate.ps1 -Force
    }

    #===================================================================================================================================================
    #    Remove C:\Windows\Setup\Scripts\ Items
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Remove C:\Windows\Setup\Scripts Items"
    Remove-Item C:\Windows\Setup\Scripts\*.* -Exclude *.TAG -Force | Out-Null

    #===================================================================================================================================================
    #    Copy OSDCloud logs and delete C:\OSDCloud folder
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Copy OSDCloud logs and delete C:\OSDCloud folder"
    Copy-Item -Path "C:\OSDCloud\Logs\*" -Destination "C:\ProgramData\OSDeploy" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    Remove-Item C:\OSDCloud -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item C:\ProgramData\OSDeploy\WiFi -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

    #Write-Host -ForegroundColor Green "Set Computername $($OSDComputername)"
    #Rename-Computer -NewName $OSDComputername

    Stop-Transcript | Out-Null

    #Restart-Computer -Force -Wait 5
    # Exit code Soft Reboot
    #Exit 0
} 
catch [System.Exception] {
    Write-Host -ForegroundColor Red "Autopilot Branding failed with error: $($_.Exception.Message)"
    Stop-Transcript | Out-Null
    exit 1
}    
