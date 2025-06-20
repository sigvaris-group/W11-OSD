#=============================================================================================================================
#
# Script Name:     Set-LanguageOff.ps1
# Description:     Set Language, Keyboard and TimeZone
# Created:         06/14/2025
# Version:         3.0
#
#=============================================================================================================================

$Title = "Set Language Offline"
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
$Global:Transcript = "Set-LanguageOff.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

$IPConfig = Get-NetIPConfiguration
Write-host -ForegroundColor Green "IPConfig"
Write-Output $IPConfig

$TestDomain = Test-NetConnection sigvaris-group.com -TraceRoute -InformationLevel Detailed -Verbose -ErrorAction SilentlyContinue
Write-host -ForegroundColor Green "Test Domain Connection"
Write-Output $TestDomain

#=======================================================================
#   Load UIjson.json file
#=======================================================================
Write-Host -ForegroundColor Green "Load C:\ProgramData\OSDeploy\UIjson.json file"
$json = Get-Content -Path "C:\ProgramData\OSDeploy\UIjson.json" -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json

# Access JSON properties
$OSDLanguage = $json.OSDLanguage
$OSDDisplayLanguage = $json.OSDDisplayLanguage
$OSDKeyboard = $json.OSDKeyboard
$OSDGeoID = $json.OSDGeoID
$OSDTimeZone = $json.OSDTimeZone

Write-Host -ForegroundColor Green "OS Language: $OSDLanguage"
Write-Host -ForegroundColor Green "Display Language: $OSDDisplayLanguage"
Write-Host -ForegroundColor Green "Keyboard: $OSDKeyboard"
Write-Host -ForegroundColor Green "GeoID: $OSDGeoID"
Write-Host -ForegroundColor Green "TimeZone: $OSDTimeZone"

# Install Language Modules
# Check if module "LanguagePackManagement" is installed
$module = Get-Module -ListAvailable LanguagePackManagement
# If module not installed, install it
if (-not $module) {
    Write-Host -ForegroundColor Yellow "The module 'LanguagePackManagement' will be installed."
    Install-Module -Name LanguagePackManagement -Scope AllUsers -Force -ErrorAction Stop
}     else {
    Write-Host -ForegroundColor Green "The module 'LanguagePackManagement' is already installed."
}
# Check if module "International" is installed
$module = Get-Module -ListAvailable International
# If module not installed, install it
if (-not $module) {
    Write-Host -ForegroundColor Yellow "The module 'International' will be installed."
    Install-Module -Name International -Scope AllUsers -Force -ErrorAction Stop
}     else {
    Write-Host -ForegroundColor Green "The module 'International' is already installed."
}
Import-Module International
Import-Module LanguagePackManagement

#=======================================================================
#   Set Language
#=======================================================================

# Install language pack and change the language of the OS on different places
# Install an additional language pack including FODs. With CopyToSettings (optional), this will change language for non-Unicode program. 
try {        

    If ($OSDDisplayLanguage -eq 'de-CH') {
        # Add Language Feature Pack from USB
        Write-Host -ForegroundColor Green "Install language pack $($OSDLanguage) in addition because of system settings"
        Add-WindowsPackage -Online -PackagePath "C:\OSDCloud\Config\Languages\$OSDLanguage" -IgnoreCheck -NoRestart
        Write-Host -ForegroundColor Green "Install language Feature pack $($OSDDisplayLanguage)"
        Add-WindowsPackage -Online -PackagePath "C:\OSDCloud\Config\Languages\$OSDDisplayLanguage" -IgnoreCheck -NoRestart
    } 
    elseif ($OSDDisplayLanguage -eq 'de-AT') {
        Write-Host -ForegroundColor Green "Install language pack $($OSDLanguage) in addition because of system settings"
        Add-WindowsPackage -Online -PackagePath "C:\OSDCloud\Config\Languages\$OSDLanguage" -IgnoreCheck -NoRestart
    } 

    # Configure new language defaults under current user (system) after which it can be copied to system
    Write-Host -ForegroundColor Green "Configure new language $($OSDDisplayLanguage) defaults under current user (system) after which it can be copied to system"
    Set-WinUILanguageOverride -Language $OSDDisplayLanguage -Verbose

    # Configure new language defaults under current user (system) after which it can be copied to system
    Write-Host -ForegroundColor Green "Set Win User Language $($OSDDisplayLanguage) List, sets the current user language settings"
    $OldList = Get-WinUserLanguageList
    Write-Host -ForegroundColor Green "Old WinUserLanguageList: $($OldList.LanguageTag)"
    $UserLanguageList = New-WinUserLanguageList -Language $OSDDisplayLanguage -Verbose
    Write-Host -ForegroundColor Green "New-WinUserLanguageList: $($UserLanguageList.LanguageTag)"
    #$UserLanguageList += $OldList
    Set-WinUserLanguageList -LanguageList $UserLanguageList -Force -Verbose
    $NewUserLanguageList = Get-WinUserLanguageList
    Write-Host -ForegroundColor Green "WinUserLanguageList: $($NewUserLanguageList.LanguageTag)"

    # Set Win Home Location, sets the home location setting for the current user. This is for Region location 
    Write-Host -ForegroundColor Green "Set Win Home Location GeoID $($OSDGeoID)"
    Set-WinHomeLocation -GeoId $OSDGeoID -Verbose

    # Set Culture, sets the user culture for the current user account. This is for Region format
    Write-Host -ForegroundColor Green "Set Culture $($OSDDisplayLanguage), sets the user culture for the current user account"
    Set-Culture -CultureInfo $OSDDisplayLanguage -Verbose

    # Copy User International Settings from current user to System, including Welcome screen and new user
    Write-Host -ForegroundColor Green "Copy User International Settings from current user to System, including Welcome screen and new user"
    Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True -Verbose

    # Set the locale for the region and language
    Write-Host -ForegroundColor Green "Set System Locale Language $($OSDDisplayLanguage)"
    Set-WinSystemLocale $OSDDisplayLanguage -Verbose

    #===================================================================================================================================================
    #  Set TimeZone
    #===================================================================================================================================================
    Write-Host -ForegroundColor Green "Set TimeZone to $($OSDTimeZone)"
    Set-TimeZone -Id $OSDTimeZone
    tzutil.exe /s "$($OSDTimeZone)"    

    Stop-Transcript | Out-Null

    # Exit code Soft Reboot
    Exit 3010
} 
catch [System.Exception] {
    Write-Host -ForegroundColor Red "$($OSDDisplayLanguage) install failed with error: $($_.Exception.Message)"
    Stop-Transcript | Out-Null
    exit 1
}