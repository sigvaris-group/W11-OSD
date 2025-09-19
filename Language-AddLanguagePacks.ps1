# Check if running in x64bit environment
Write-Host -ForegroundColor Gray "Is 64bit PowerShell: $([Environment]::Is64BitProcess)"
Write-Host -ForegroundColor Gray "Is 64bit OS: $([Environment]::Is64BitOperatingSystem)"

Write-Host -ForegroundColor Gray "Script: " -NoNewline
Write-Host -ForegroundColor Cyan "Language-AddLanguagePacks.ps1"

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
$ScriptName = 'Language-AddLanguagePacks.ps1' # Name
$ScriptDescription = 'This script add Language packs based on the UI' # Description:
$ScriptVersion = '1.0' # Version
$ScriptDate = '18.09.2025' # Created on
$ScriptUpdateDate = '' # Update on
$ScriptUpdateReason = '' # Update reason
$ScriptDepartment = 'Workplace Team & GA Team' # Department
$ScriptAuthor = 'Andreas Schilling' # Author

# Script Local Variables
$Error.Clear()
$SL = "================================================================================================================================================~"
$EL = "`n================================================================================================================================================~`n"
$DT = Get-Date -format G
$LogFilePath = "C:\OSDCloud\Logs"
$LogFile = $ScriptName -replace ".{3}$", "log"
$StartTime = Get-Date

Start-Transcript -Path (Join-Path $LogFilePath $LogFile) -ErrorAction Ignore
Write-Host -ForegroundColor Gray "[$($DT)] [Start] Script start at: " -NoNewline
Write-Host -ForegroundColor Cyan "$($StartTime)"

# Script Information
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "Name: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptName)"
Write-Host -ForegroundColor Gray "Description: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptDescription)"
Write-Host -ForegroundColor Gray "Version: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptVersion)"
Write-Host -ForegroundColor Gray "Created on: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptDate)"
Write-Host -ForegroundColor Gray "Update on: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptUpdateDate)"
Write-Host -ForegroundColor Gray "Update reason: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptUpdateReason)"
Write-Host -ForegroundColor Gray "Department: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptDepartment)"
Write-Host -ForegroundColor Gray "Author: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptAuthor)"
Write-Host -ForegroundColor Gray "Logfile Path: " -NoNewline
Write-Host -ForegroundColor Cyan "$($LogFilePath)"
Write-Host -ForegroundColor Gray "Logfile: " -NoNewline
Write-Host -ForegroundColor Cyan "$($LogFile)"
Write-Host -ForegroundColor DarkGray $EL

# ================================================================================================================================================~
# [SECTION] UI
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$($DT)] [SECTION-Start] UI"
Write-Host -ForegroundColor DarkGray $SL

$jsonpath = "C:\ProgramData\OSDeploy"
$jsonfile = "UIjson.json"
Write-Host -ForegroundColor Cyan "[$($DT)] [UI] Load $($jsonfile) file from $($jsonpath)"

$json = Get-Content -Path (Join-Path $jsonpath $jsonfile) -Raw | ConvertFrom-Json
$OSDLanguage = $($json.OSDLanguage)
$OSDDisplayLanguage = $($json.OSDDisplayLanguage)
$OSDKeyboard = $($json.OSDKeyboard)
$OSDKeyboardLocale = $($json.OSDKeyboardLocale)
$OSDGeoID = $($json.OSDGeoID)
$OSDTimeZone = $json.OSDTimeZone

Write-Host -ForegroundColor Gray "[$($DT)] [UI] Your Settings are:"
Write-Host -ForegroundColor Gray "OS Language: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDLanguage)"
Write-Host -ForegroundColor Gray "Display Language: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDDisplayLanguage)"
Write-Host -ForegroundColor Gray "Keyboard: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDKeyboard)"
Write-Host -ForegroundColor Gray "KeyboardLocale: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDKeyboardLocale)"
Write-Host -ForegroundColor Gray "GeoID: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDGeoID)"
Write-Host -ForegroundColor Gray "TimeZone: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDTimeZone)"

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$($DT)] [SECTION-End] UI"
Write-Host -ForegroundColor Gray "[$($DT)] [SECTION-End] SECTION took " -NoNewline
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Gray  "minutes to execute."
Write-Host -ForegroundColor DarkGray $SL

# ================================================================================================================================================~
# [SECTION] LanguagePack
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$($DT)] [SECTION-Start] LanguagePack"
Write-Host -ForegroundColor DarkGray $SL

$InstalledLanguages = Get-InstalledLanguage
$InstalledLanguages = $InstalledLanguages | ForEach-Object { $_.LanguageID }
Write-Host -ForegroundColor Gray "Current installed languages: " -NoNewline
Write-Host -ForegroundColor Cyan "$($InstalledLanguages)"

Write-Host -ForegroundColor Gray "Add Language pack: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDDisplayLanguage)"
if ($OSDDisplayLanguage -ne 'en-US') { 
    Dism /Online /Add-Package /PackagePath:C:\OSDCloud\Config\LP\$($OSDDisplayLanguage)    
}

Write-Host -ForegroundColor Gray "Add Language Feature packs: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDDisplayLanguage)"
if ($OSDDisplayLanguage -ne 'en-US') { 
    Dism /Online /Add-Capability /Source:C:\OSDCloud\Config\LP\Feature\$($OSDDisplayLanguage) /LimitAccess
}   

Write-Host -ForegroundColor Gray "Set TimeZone to " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDTimeZone)"
Set-TimeZone -Id $OSDTimeZone
tzutil.exe /s "$($OSDTimeZone)"  

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$($DT)] [SECTION-End] LanguagePack"
Write-Host -ForegroundColor Gray "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White   "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Cyan  "minutes to execute."
Write-Host -ForegroundColor DarkGray $SL

# ================================================================================================================================================~
# End Script
# ================================================================================================================================================~
$EndTime = Get-Date
$ExecutionTime = $EndTime - $StartTime

Write-Host -ForegroundColor Gray "[$($DT)] [Start] Script end at: " -NoNewline
Write-Host -ForegroundColor Cyan "$($EndTime)"
Write-Host -ForegroundColor Gray "[$($DT)] [End] Script took " -NoNewline 
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes)"
Write-Host -ForegroundColor Gray " minutes to execute"

Stop-Transcript | Out-Null