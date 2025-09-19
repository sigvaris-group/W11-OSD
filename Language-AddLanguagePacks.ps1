# Check if running in x64bit environment
Write-Host -ForegroundColor Blue "Is 64bit PowerShell: $([Environment]::Is64BitProcess)"
Write-Host -ForegroundColor Blue "Is 64bit OS: $([Environment]::Is64BitOperatingSystem)"

Write-Host -ForegroundColor Blue "Script: " -NoNewline
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
Write-Host -ForegroundColor Blue "[$($DT)] [Start] Script start at: " -NoNewline
Write-Host -ForegroundColor Cyan "$($StartTime)"

# Script Information
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "Name: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptName)"
Write-Host -ForegroundColor Blue "Description: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptDescription)"
Write-Host -ForegroundColor Blue "Version: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptVersion)"
Write-Host -ForegroundColor Blue "Created on: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptDate)"
Write-Host -ForegroundColor Blue "Update on: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptUpdateDate)"
Write-Host -ForegroundColor Blue "Update reason: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptUpdateReason)"
Write-Host -ForegroundColor Blue "Department: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptDepartment)"
Write-Host -ForegroundColor Blue "Author: " -NoNewline
Write-Host -ForegroundColor Cyan "$($ScriptAuthor)"
Write-Host -ForegroundColor Blue "Logfile Path: " -NoNewline
Write-Host -ForegroundColor Cyan "$($LogFilePath)"
Write-Host -ForegroundColor Blue "Logfile: " -NoNewline
Write-Host -ForegroundColor Cyan "$($LogFile)"
Write-Host -ForegroundColor DarkBlue $EL

# ================================================================================================================================================~
# [SECTION] UI
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] UI"
Write-Host -ForegroundColor DarkBlue $SL

$jsonpath = "C:\ProgramData\OSDeploy"
$jsonfile = "UIjson.json"
Write-Host -ForegroundColor Cyan "[$($DT)] [UI] Load $($jsonfile) file from $($jsonpath)"

$json = Get-Content -Path (Join-Path $jsonpath $jsonfile) -Raw | ConvertFrom-Json
$OSDDisplayLanguage = $($json.OSDDisplayLanguage)

Write-Host -ForegroundColor Blue "[$($DT)] [UI] Your Settings are:"
Write-Host -ForegroundColor Blue "Display Language: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDDisplayLanguage)"

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] UI"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] SECTION took " -NoNewline
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] LanguagePack
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] LanguagePack"
Write-Host -ForegroundColor DarkBlue $SL

Write-Host -ForegroundColor Blue "Add Language pack: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDDisplayLanguage)"
if ($OSDDisplayLanguage -ne 'en-US') { 
    Dism /Online /Add-Package /PackagePath:C:\OSDCloud\Config\$($OSDDisplayLanguage)    
}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] LanguagePack"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White   "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Cyan  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# End Script
# ================================================================================================================================================~
$EndTime = Get-Date
$ExecutionTime = $EndTime - $StartTime

Write-Host -ForegroundColor Blue "[$($DT)] [Start] Script end at: " -NoNewline
Write-Host -ForegroundColor Cyan "$($EndTime)"
Write-Host -ForegroundColor Blue "[$($DT)] [End] Script took " -NoNewline 
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes)"
Write-Host -ForegroundColor Blue " minutes to execute"

Stop-Transcript | Out-Null