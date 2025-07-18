# Check if running in x64bit environment
Write-Host -ForegroundColor Green "Is 64bit PowerShell: $([Environment]::Is64BitProcess)"
Write-Host -ForegroundColor Green "Is 64bit OS: $([Environment]::Is64BitOperatingSystem)"

Write-Host -ForegroundColor Green "Install and set language: " -NoNewline
Write-Host -ForegroundColor Yellow "Set-Language.ps1"

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

If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null}
$Global:Transcript = "Set-Language.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

#=======================================================================
#   Load UIjson.json file
#=======================================================================
Write-Host -ForegroundColor Green "Load C:\ProgramData\OSDeploy\UIjson.json file"
$json = Get-Content -Path "C:\ProgramData\OSDeploy\UIjson.json" -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json

# Access JSON properties
$OSDLanguage = $json.OSDLanguage
$OSDDisplayLanguage = $json.OSDDisplayLanguage
$OSDLanguagePack = $json.OSDLanguagePack
$OSDKeyboard = $json.OSDKeyboard
$OSDGeoID = $json.OSDGeoID
$OSDTimeZone = $json.OSDTimeZone
$OSDWindowsUpdate = $json.OSDWindowsUpdate

Write-Host -ForegroundColor Green "OS Language: $OSDLanguage"
Write-Host -ForegroundColor Green "Display Language: $OSDDisplayLanguage"
Write-Host -ForegroundColor Green "Language Pack: $OSDLanguagePack"
Write-Host -ForegroundColor Green "Keyboard: $OSDKeyboard"
Write-Host -ForegroundColor Green "GeoID: $OSDGeoID"
Write-Host -ForegroundColor Green "TimeZone: $OSDTimeZone"
Write-Host -ForegroundColor Green "Windows Update: $OSDWindowsUpdate"

#===================================================================================================================================================
#  Install Language Modules
#===================================================================================================================================================
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

#===================================================================================================================================================
#  Install language pack and change the language of the OS on different places 
#===================================================================================================================================================
# Check currently installed languages
$InstalledLanguages = Get-InstalledLanguage
$InstalledLanguages = $InstalledLanguages | ForEach-Object { $_.LanguageID }
Write-Host -ForegroundColor Green "Current installed languages: $($InstalledLanguages)"


try {
    # Install an additional language pack including FODs. With CopyToSettings (optional), this will change language for non-Unicode program.  
    If ($OSDDisplayLanguage -ne 'en-US') {
        Write-Host "    Install OS Language: $($OSDLanguage)"
        Install-Language -Language $OSDLanguage
        Write-Host "    Add Language Features: $($OSDLanguagePack)"
        Add-WindowsCapability -Online -Name "$OSDLanguagePack"
    }
}
catch {
        Write-Host -ForegroundColor Red "Error installing language $($OSDDisplayLanguage). Error: $($_.Exception.Message). Exiting script"
}


# Set the language as the system preferred language
try {
    Set-SystemPreferredUILanguage $OSDLanguage -Verbose
    Write-Host -ForegroundColor Green "   Successfully set system preferred UI language to $($OSDLanguage)"
    
} catch {
    Write-Host -ForegroundColor Red "Error setting system preferred UI language to $($OSDLanguage). Error: $($_.Exception.Message)"
}

# Configure new language defaults under current user (system) after which it can be copied to system
try {
    Set-WinUILanguageOverride -Language $OSDDisplayLanguage -Verbose -ErrorAction Stop 
    Write-Host -ForegroundColor Green "   Successfully set WinUI language override to $($OSDDisplayLanguage)."
    
} catch {
    Write-Host -ForegroundColor Red "Error setting WinUI language override to $($OSDDisplayLanguage). Error: $($_.Exception.Message)"
}


# Configure new language defaults under current user (system) after which it can be copied to system
try {
    $OldUserLanguageList = Get-WinUserLanguageList
    Write-Host "    Old-WinUserLanguageList: $($OldUserLanguageList.LanguageTag)"
    
    $NewUserLanguageList = New-WinUserLanguageList -Language $OSDDisplayLanguage -Verbose
    Write-Host "    New-WinUserLanguageList: $($NewUserLanguageList.LanguageTag)"

    if ($OSDDisplayLanguage -eq 'pl-PL') {
        Set-WinUserLanguageList -LanguageList 'pl-PL' -Force -Verbose
    } 
    else {
        #$NewUserLanguageList += $OldUserLanguageList
        Set-WinUserLanguageList -LanguageList $OSDDisplayLanguage -Force -Verbose
    }
    
    $UserLanguageList = Get-WinUserLanguageList
    Write-Host -ForegroundColor Green "   Successfully set WinUserLanguageList to $($UserLanguageList.LanguageTag)"    
} catch {
    Write-Host -ForegroundColor Red "Error setting WinUserLanguageList to $($OSDDisplayLanguage). Failure: $_"
}


# Set Culture, sets the user culture for the current user account. This is for Region format
try {
    Set-Culture -CultureInfo $OSDDisplayLanguage -Verbose
    Write-Host -ForegroundColor Green "   Culture successfully set to $($OSDDisplayLanguage)"
}
catch {
    Write-Host -ForegroundColor Red "Error setting culture: $_"
}

# Set Win Home Location (GeoID), sets the home location setting for the current user. This is for Region location 
try {
    Set-WinHomeLocation -GeoId $OSDGeoID -Verbose
    Write-Host -ForegroundColor Green "   Home location successfully set to GeoID $($OSDGeoID)"
}
catch {
    Write-Host -ForegroundColor Red "Error setting home location: $($_.Exception.Message)"
}

# Copy User International Settings from current user to System, including Welcome screen and new user
try {
    Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True
    Write-Host -ForegroundColor Green "   Copying user international settings to system."
} catch {
    Write-Host -ForegroundColor Red "Error copying user international settings to system. Error: $($_.Exception.Message)"
}

<#
# change registry key 
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\Language"
Write-Host -ForegroundColor Green "   Set registry key"
Switch ($OSDDisplayLanguage) {
    'en-CA' {Set-ItemProperty -Path $registryPath -Name "InstallLanguage" -Value "1009";Set-ItemProperty -Path $registryPath -Name "Default" -Value "1009";break}
    'en-GB' {Set-ItemProperty -Path $registryPath -Name "InstallLanguage" -Value "0809";Set-ItemProperty -Path $registryPath -Name "Default" -Value "0809";break}
    'de-DE' {Set-ItemProperty -Path $registryPath -Name "InstallLanguage" -Value "0407";Set-ItemProperty -Path $registryPath -Name "Default" -Value "0407";break}
    'de-CH' {Set-ItemProperty -Path $registryPath -Name "InstallLanguage" -Value "0807";Set-ItemProperty -Path $registryPath -Name "Default" -Value "0807";break}
    'de-AT' {Set-ItemProperty -Path $registryPath -Name "InstallLanguage" -Value "0c07";Set-ItemProperty -Path $registryPath -Name "Default" -Value "0c07";break}
    'fr-FR' {Set-ItemProperty -Path $registryPath -Name "InstallLanguage" -Value "040c";Set-ItemProperty -Path $registryPath -Name "Default" -Value "040c";break}
    'it-IT' {Set-ItemProperty -Path $registryPath -Name "InstallLanguage" -Value "0410";Set-ItemProperty -Path $registryPath -Name "Default" -Value "0410";break}
    'pl-PL' {Set-ItemProperty -Path $registryPath -Name "InstallLanguage" -Value "0415";Set-ItemProperty -Path $registryPath -Name "Default" -Value "0415";break}
    'en-AU' {Set-ItemProperty -Path $registryPath -Name "InstallLanguage" -Value "0c09";Set-ItemProperty -Path $registryPath -Name "Default" -Value "0c09";break}
    'pt-BR' {Set-ItemProperty -Path $registryPath -Name "InstallLanguage" -Value "0416";Set-ItemProperty -Path $registryPath -Name "Default" -Value "0416";break}
    'pt-PT' {Set-ItemProperty -Path $registryPath -Name "InstallLanguage" -Value "0816";Set-ItemProperty -Path $registryPath -Name "Default" -Value "0816";break}
    'es-MX' {Set-ItemProperty -Path $registryPath -Name "InstallLanguage" -Value "080a";Set-ItemProperty -Path $registryPath -Name "Default" -Value "080a";break}
}
#>

Stop-Transcript | Out-Null