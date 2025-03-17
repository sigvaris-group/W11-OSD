#=============================================================================================================================
#
# Script Name:     Set-Language.ps1
# Description:     Set Language, Keyboard and TimeZone
# Created:         12/20/2024
# Updated:         01/31/2024 Moved to an Intune app which is used by the ESP
# Version:         1.0
#
#=============================================================================================================================

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

#=======================================================================
#   Create logfile
#=======================================================================
If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null}
$Global:Transcript = "Set-Language.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

#=======================================================================
#   Load UIjson.json file
#=======================================================================
Write-Host -ForegroundColor Green "Load C:\ProgramData\OSDeploy\UIjson.json file"
$json = Get-Content -Path "C:\ProgramData\OSDeploy\UIjson.json" -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json

If ($json) {

    # Access JSON properties
    $OSDLanguage = $json.OSDLanguage
    $OSDDisplayLanguage = $json.OSDDisplayLanguage
    $OSDKeyboard = $json.OSDKeyboard
    $OSDGeoID = $json.OSDGeoID

    Write-Host -ForegroundColor Green "OS Language: $OSDLanguage"
    Write-Host -ForegroundColor Green "Display Language: $OSDDisplayLanguage"
    Write-Host -ForegroundColor Green "Keyboard: $OSDKeyboard"
    Write-Host -ForegroundColor Green "GeoID: $OSDGeoID"

    # Import modules
    Import-Module International
    Import-Module LanguagePackManagement

    # Stop the Windows Update service
    Write-Host -ForegroundColor Green "Stop the Windows Update service"
    Stop-Service -Name wuauserv -ErrorAction SilentlyContinue

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

    #=======================================================================
    #   Set Language
    #=======================================================================

    # Install language pack and change the language of the OS on different places
    # Install an additional language pack including FODs. With CopyToSettings (optional), this will change language for non-Unicode program. 
    try {
        
        Write-Host -ForegroundColor Green "Install language pack $($OSDDisplayLanguage) and change the language of the OS on different places"
        Install-Language $OSDDisplayLanguage -CopyToSettings -Verbose

        # Set reboot for InTune based on the return code
        $RebootRequired = $true
                
        # Configure new language defaults under current user (system) after which it can be copied to system
        Write-Host -ForegroundColor Green "Configure new language $($OSDDisplayLanguage) defaults under current user (system) after which it can be copied to system"
        Set-WinUILanguageOverride -Language $OSDDisplayLanguage -Verbose

        # Configure new language defaults under current user (system) after which it can be copied to system
        Write-Host -ForegroundColor Green "Set Win User Language $($OSDDisplayLanguage) List, sets the current user language settings"
        $OldList = Get-WinUserLanguageList
        Write-Host -ForegroundColor Green "Old WinUserLanguageList: $($OldList.LanguageTag)"
        $UserLanguageList = New-WinUserLanguageList -Language $OSDDisplayLanguage -Verbose
        Write-Host -ForegroundColor Green "New-WinUserLanguageList: $($UserLanguageList.LanguageTag)"
        $UserLanguageList += $OldList
        Set-WinUserLanguageList -LanguageList $UserLanguageList -Force -Verbose
        $NewUserLanguageList = Get-WinUserLanguageList
        Write-Host -ForegroundColor Green "New WinUserLanguageList: $($NewUserLanguageList.LanguageTag)"

        # Set Win Home Location, sets the home location setting for the current user. This is for Region location 
        Write-Host -ForegroundColor Green "Set Win Home Location GeoID $($OSDGeoID)"
        Set-WinHomeLocation -GeoId $OSDGeoID -Verbose

        # Set Culture, sets the user culture for the current user account. This is for Region format
        Write-Host -ForegroundColor Green "Set Culture $($OSDDisplayLanguage), sets the user culture for the current user account"
        Set-Culture -CultureInfo $OSDDisplayLanguage -Verbose

        # Set the locale for the region and language
        Write-Host -ForegroundColor Green "Set System Locale Language $($OOSDDisplayLanguage)"
        Set-WinSystemLocale $OSDDisplayLanguage -Verbose

        # Sets the provided language as the System Preferred UI Language
        #Write-Host -ForegroundColor Green "Set System Preferred UI Language $($OSDDisplayLanguage)"
        #Set-SystemPreferredUILanguage $OSDDisplayLanguage -Verbose

        # Copy User International Settings from current user to System, including Welcome screen and new user
        Write-Host -ForegroundColor Green "Copy User International Settings from current user to System, including Welcome screen and new user"
        Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True -Verbose

        if ($RebootRequired -eq $true) {
            Write-Host -ForegroundColor Green "Reboot required"
        }

        #===================================================================================================================================================
        #   Create registry keys to detect this was installed
        #===================================================================================================================================================
        Write-Host -ForegroundColor Green "Create registry keys to detect this was installed"
        $currentDateTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss" 
        New-Item -Path 'HKLM:\SOFTWARE\' -Name 'SIGVARIS' -ErrorAction SilentlyContinue
        New-Item -Path 'HKLM:\SOFTWARE\SIGVARIS' -Name 'Autopilot' -ErrorAction SilentlyContinue
        New-Item -Path 'HKLM:\SOFTWARE\SIGVARIS\Autopilot' -Name 'Language' -ErrorAction SilentlyContinue
        $RegPath = "HKLM:\SOFTWARE\SIGVARIS\Autopilot\Language"
        New-ItemProperty -Path  $RegPath -Name OSDLanguage -Value $OSDLanguage -Force -ErrorAction SilentlyContinue
        New-ItemProperty -Path  $RegPath -Name OSDDisplayLanguage -Value $OSDDisplayLanguage -Force -ErrorAction SilentlyContinue
        New-ItemProperty -Path  $RegPath -Name OSDKeyboard -Value $OSDKeyboard -Force -ErrorAction SilentlyContinue
        New-ItemProperty -Path  $RegPath -Name OSDGeoID -Value $OSDGeoID -Force -ErrorAction SilentlyContinue
        New-ItemProperty -Path  $RegPath -Name InstallDateTime -Value $currentDateTime -Force -ErrorAction SilentlyContinue           
    } 
    catch [System.Exception] {
        Write-Host -ForegroundColor Red "$($OSDDisplayLanguage) install failed with error: $($_.Exception.Message)"
        Stop-Transcript | Out-Null
        exit 1
    }
} else {
    Write-Host -ForegroundColor Green "No OSDCLOUD Windows 11 Instalaltion"
    #===================================================================================================================================================
    #   Create registry keys to detect this was installed
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Create registry keys to detect this was installed"
    $currentDateTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss" 
    New-Item -Path 'HKLM:\SOFTWARE\' -Name 'SIGVARIS' -ErrorAction SilentlyContinue
    New-Item -Path 'HKLM:\SOFTWARE\SIGVARIS' -Name 'Autopilot' -ErrorAction SilentlyContinue
    New-Item -Path 'HKLM:\SOFTWARE\SIGVARIS\Autopilot' -Name 'Language' -ErrorAction SilentlyContinue
    $RegPath = "HKLM:\SOFTWARE\SIGVARIS\Autopilot\Language"
    New-ItemProperty -Path  $RegPath -Name OSDLanguage -Value $OSDLanguage -Force -ErrorAction SilentlyContinue
    New-ItemProperty -Path  $RegPath -Name OSDDisplayLanguage -Value $OSDDisplayLanguage -Force -ErrorAction SilentlyContinue
    New-ItemProperty -Path  $RegPath -Name OSDKeyboard -Value $OSDKeyboard -Force -ErrorAction SilentlyContinue
    New-ItemProperty -Path  $RegPath -Name OSDGeoID -Value $OSDGeoID -Force -ErrorAction SilentlyContinue
    New-ItemProperty -Path  $RegPath -Name InstallDateTime -Value $currentDateTime -Force -ErrorAction SilentlyContinue     
} 

Stop-Transcript | Out-Null

if ($RebootRequired -eq $true) {
    Exit 3010
} else {
    Exit 0
}