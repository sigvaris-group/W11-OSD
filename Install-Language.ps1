# Check if running in x64bit environment
Write-Host -ForegroundColor Gray "Is 64bit PowerShell: $([Environment]::Is64BitProcess)"
Write-Host -ForegroundColor Gray "Is 64bit OS: $([Environment]::Is64BitOperatingSystem)"

Write-Host -ForegroundColor Gray "Script: " -NoNewline
Write-Host -ForegroundColor Cyan "Install-Language.ps1"

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
$ScriptName = 'Install-Language.ps1' # Name
$ScriptDescription = 'This script add Language packs based on the UI' # Description:
$ScriptVersion = '1.0' # Version
$ScriptDate = '18.09.2025' # Created on
$ScriptUpdateDate = '' # Update on
$ScriptUpdateReason = '' # Update reason
$ScriptDepartment = 'Workplace Team & GA Team' # Department
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
$OSDLanguage = $($json.OSDLanguage)
$OSDDisplayLanguage = $($json.OSDDisplayLanguage)
$OSDLanguagePack = $json.OSDLanguagePack
$OSDKeyboard = $($json.OSDKeyboard)
$OSDKeyboardLocale = $($json.OSDKeyboardLocale)
$OSDGeoID = $($json.OSDGeoID)
$OSDTimeZone = $json.OSDTimeZone

Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [UI] Your Settings are:"
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

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] UI"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] SECTION took " -NoNewline
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Gray  "minutes to execute."
Write-Host -ForegroundColor DarkGray $SL

# ================================================================================================================================================~
# [SECTION] LanguagePack
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-Start] LanguagePack"
Write-Host -ForegroundColor DarkGray $SL

$InstalledLanguages = Get-InstalledLanguage
$InstalledLanguages = $InstalledLanguages | ForEach-Object { $_.LanguageID }
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [LanguagePack] Current installed languages: " -NoNewline
Write-Host -ForegroundColor Cyan "$($InstalledLanguages)"

# ================================================================================================================================================~
# [SECTION] LanguagePack
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-Start] LanguagePack"
Write-Host -ForegroundColor DarkGray $SL

$InstalledLanguages = Get-InstalledLanguage
$InstalledLanguages = $InstalledLanguages | ForEach-Object { $_.LanguageID }
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [LanguagePack] Current installed languages: " -NoNewline
Write-Host -ForegroundColor Cyan "$($InstalledLanguages)"

if ($OSDDisplayLanguage -ne 'en-US') {

    Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [LanguagePack] Add Language pack: " -NoNewline
    Write-Host -ForegroundColor Cyan "$($OSDDisplayLanguage)"
    Dism /Online /Add-Package /PackagePath:C:\ProgramData\OSDeploy\LP\$($OSDDisplayLanguage) /NoRestart

    Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [LanguagePack] Add Language Feature packs: " -NoNewline
    Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [LanguagePack] $($OSDDisplayLanguage)"
    $FeatureFolder = "C:\ProgramData\OSDeploy\LP\Feature\$($OSDDisplayLanguage)"
    $FeaturePacks = Get-ChildItem $FeatureFolder -File
    foreach ($Feature in $FeaturePacks) {
        Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [LanguagePack] Add Feature: " -NoNewline
        Write-Host -ForegroundColor Cyan "$($Feature.Name)"
        Add-WindowsCapability -Online -Name $($Feature.Name) -Source "$FeatureFolder" -LimitAccess -ErrorAction SilentlyContinue
    }

    <#
    # Set the language as the system preferred language
    Set-SystemPreferredUILanguage $OSDLanguage -ErrorAction SilentlyContinue
    Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [LanguagePack] Successfully set system preferred UI language to " -NoNewline
    Write-Host -ForegroundColor Cyan "$($OSDLanguage)"
    #>

    # Set system locale to en-US, because we want the default system locale to be English (United States) for compatibility with various applications.
    # non-Unicode program. Some old or bad applications don’t support Unicode, it might need to change the language to help show the correct characters.
    Set-WinSystemLocale $($OSDLanguage) 
    
    # Configure new language defaults under current user (system) after which it can be copied to system
    Set-WinUILanguageOverride -Language $OSDDisplayLanguage -ErrorAction SilentlyContinue
    Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [LanguagePack] Successfully set WinUI language override to " -NoNewline
    Write-Host -ForegroundColor Cyan "$($OSDDisplayLanguage)"

    # Configure new language defaults under current user (system) after which it can be copied to system
    $OldUserLanguageList = Get-WinUserLanguageList
    Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [LanguagePack] Old-WinUserLanguageList: " -NoNewline
    Write-Host -ForegroundColor Cyan "$($OldUserLanguageList.LanguageTag)"

    $NewUserLanguageList = New-WinUserLanguageList -Language $OSDDisplayLanguage -ErrorAction SilentlyContinue
     if ($OSDLanguage -eq 'pl-PL') {$NewUserLanguageList = 'pl-PL'}
    Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [LanguagePack] New-WinUserLanguageList: " -NoNewline
    Write-Host -ForegroundColor Cyan "$($NewUserLanguageList.LanguageTag)"
    
    $NewUserLanguageList += $OldUserLanguageList
    Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [LanguagePack] Display Languages: " -NoNewline
    Write-Host -ForegroundColor Cyan "$($NewUserLanguageList.LanguageTag)"

    Set-WinUserLanguageList -LanguageList $NewUserLanguageList -Force -ErrorAction SilentlyContinue

    $UserLanguageList = Get-WinUserLanguageList
    Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [LanguagePack] Successfully set WinUserLanguageList to " -NoNewline
    Write-Host -ForegroundColor Cyan "$($UserLanguageList.LanguageTag)"

    # Set Culture, sets the user culture for the current user account. This is for Region format
    Set-Culture -CultureInfo $OSDDisplayLanguage -ErrorAction SilentlyContinue
    Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [LanguagePack] Culture successfully set to " -NoNewline
    Write-Host -ForegroundColor Cyan "$($OSDDisplayLanguage)"

    # Set Win Home Location (GeoID), sets the home location setting for the current user. This is for Region location 
    Set-WinHomeLocation -GeoId $OSDGeoID -ErrorAction SilentlyContinue
    Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [LanguagePack] Culture successfully set to " -NoNewline
    Write-Host -ForegroundColor Cyan "$($OSDGeoID)"

    # Copy User International Settings from current user to System, including Welcome screen and new user
    Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True
    Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [LanguagePack] Copying user international settings to system." -NoNewline

    Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [LanguagePack] Set TimeZone to " -NoNewline
    Write-Host -ForegroundColor Cyan "$($OSDTimeZone)"
    Set-TimeZone -Id $OSDTimeZone
    tzutil.exe /s "$($OSDTimeZone)"  
}
else {
    Write-Host -ForegroundColor Green "[$(Get-Date -Format G)] [LanguagePack] en-US is installed" -NoNewline    
}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] LanguagePack"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] SECTION took " -NoNewline
Write-Host -ForegroundColor White   "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Cyan  "minutes to execute."
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