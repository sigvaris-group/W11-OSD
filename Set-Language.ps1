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
$json = Get-Content -Path "C:\ProgramData\OSDeploy\UIjson.json" -Raw | ConvertFrom-Json

# Access JSON properties
$OSDLanguage = $json.OSDLanguage
$OSDKeyboard = $json.OSDKeyboard
$OSDGeoID = $json.OSDGeoID

Write-Host -ForegroundColor Green "Language: $OSDLanguage"
Write-Host -ForegroundColor Green "Keyboard: $OSDKeyboard"
Write-Host -ForegroundColor Green "GeoID: $OSDGeoID"

# Set reboot for InTune based on the return code
$RebootRequired = $false

# Import modules
Import-Module International
Import-Module LanguagePackManagement

#=======================================================================
#   Set Language
#=======================================================================

# Check if language installed
$Languages = Get-InstalledLanguage
$LanguagePresent = $false
foreach ($Language in $Languages) {
    Write-Host $Language.LanguageId
    if ($Language.Language -eq $OSDLanguage) {
        $LanguagePresent = $true
    }
}

if ($LanguagePresent -eq $false) {
    Write-Host -ForegroundColor Green "Install language pack $($OSDLanguage) and change the language of the OS on different places"
    Install-Language $OSDLanguage -CopyToSettings
    $RebootRequired = $true
}

if ($(Get-WinSystemLocale).Name -ne $OSDLanguage) {
    Write-Host -ForegroundColor Green "Set System Locale Language $($OSDLanguage)"
    Set-WinSystemLocale $OSDLanguage
    $RebootRequired = $true
}

if ($(Get-SystemPreferredUILanguage) -ne $OSDLanguage) {
    Write-Host -ForegroundColor Green "Set System Preferred UI Language $($OSDLanguage)"
    Set-SystemPreferredUILanguage $OSDLanguage
    $RebootRequired = $true
}

if ($(Get-WinUserLanguageList).LanguageTag -ne $OSDLanguage) {
    Write-Host -ForegroundColor Green "Set Win User Language $($OSDLanguage) List, sets the current user language settings"
    $OldList = Get-WinUserLanguageList
    $UserLanguageList = New-WinUserLanguageList -Language $OSDLanguage
    $UserLanguageList += $OldList
    Set-WinUserLanguageList -LanguageList $UserLanguageList -Force
    $RebootRequired = $true
}

if ($(Get-Culture).Name -ne $OSDKeyboard) {
    Write-Host -ForegroundColor Green "Set Culture $($OSDKeyboard), sets the user culture for the current user account"
    Set-Culture -CultureInfo $OSDKeyboard
    $RebootRequired = $true
}

if ($(Get-WinHomeLocation).GeoId -ne $OSDGeoID) {
    Write-Host -ForegroundColor Green "Set Win Home Location GeoID $($OSDGeoID)"
    Set-WinHomeLocation -GeoId $OSDGeoID
    $RebootRequired = $true
}

Write-Host -ForegroundColor Green "Configure new language $($OSDLanguage) defaults under current user (system) after which it can be copied to system"
Set-WinUILanguageOverride -Language $OSDLanguage

Write-Host -ForegroundColor Green "Copy User International Settings from current user to System, including Welcome screen and new user"
Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True

if ($RebootRequired -eq $true) {
    Write-Host -ForegroundColor Green "Reboot required"
}

Stop-Transcript | Out-Null

if ($RebootRequired -eq $true) {
    Exit 3010
} else {
    Exit 0
}