#=============================================================================================================================
#
# Script Name:     AutopilotBrandingTeams.ps1
# Description:     Configure Windows Autopilot Branding for TEAMS devices
# Created:         06/19/2025
# Version:         1.0
#
#=============================================================================================================================

$Title = "Configure Windows Autopilot Branding for TEAMS devices"
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
$Global:Transcript = "AutopilotBrandingTeams.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

#===================================================================================================================================================
#   Load UIjson.json file
#===================================================================================================================================================
Write-Host -ForegroundColor Green "Load C:\ProgramData\OSDeploy\UIjson.json file"
$json = Get-Content -Path "C:\ProgramData\OSDeploy\UIjson.json" -Raw | ConvertFrom-Json

# Access JSON properties
$OSDTimeZone = $json.OSDTimeZone

try {

    #===================================================================================================================================================
    #  Set TimeZone
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Set TimeZone to $($OSDTimeZone)"
    Set-TimeZone -Id $OSDTimeZone
    tzutil.exe /s "$($OSDTimeZone)"

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
    Copy-Item -Path "C:\OSDCloud\Logs\*" -Destination "C:\ProgramData\OSDeploy" -Recurse -ErrorAction SilentlyContinue
    Remove-Item C:\OSDCloud -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

    Stop-Transcript | Out-Null

    Restart-Computer -Force -Wait 5
    # Exit code Soft Reboot
    Exit 3010    
} 
catch [System.Exception] {
    Write-Host -ForegroundColor Red "Autopilot Branding failed with error: $($_.Exception.Message)"
    Stop-Transcript | Out-Null
    exit 1
}    
