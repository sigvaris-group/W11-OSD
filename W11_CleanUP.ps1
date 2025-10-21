# Check if running in x64bit environment
Write-Host -ForegroundColor Gray "Is 64bit PowerShell: $([Environment]::Is64BitProcess)"
Write-Host -ForegroundColor Gray "Is 64bit OS: $([Environment]::Is64BitOperatingSystem)"

Write-Host -ForegroundColor Gray "Script: " -NoNewline
Write-Host -ForegroundColor Cyan "W11_CleanUP.ps1"

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
$ScriptName = 'W11_CleanUP.ps1' # Name
$ScriptDescription = 'Execute OSDCloud Cleanup Script' # Description:
$ScriptVersion = '1.0' # Version
$ScriptDate = '14.10.2025' # Created on
$ScriptUpdateDate = '21.10.2025' # Update on
$ScriptUpdateReason = 'Change logfile path' # Update reason
$ScriptDepartment = 'Workplace & GA Team' # Department
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
# [SECTION] CleanUp
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-Start] CleanUp"
Write-Host -ForegroundColor DarkGray $SL

#===================================================================================================================================================
#    Remove OSDCloudRegistration Certificate
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [CleanUp] Remove Import-Certificate.ps1 script"
if (Test-Path -Path $env:SystemDrive\OSDCloud\Scripts\Import-Certificate.ps1) {
    Remove-Item -Path $env:SystemDrive\OSDCloud\Scripts\Import-Certificate.ps1 -Force -ErrorAction SilentlyContinue
}

#===================================================================================================================================================
#    Remove C:\Windows\Setup\Scripts\ Items
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] CleanUp] Remove C:\Windows\Setup\Scripts Items"
Remove-Item C:\Windows\Setup\Scripts\*.* -Exclude *.TAG -Force | Out-Null

#===================================================================================================================================================
#    Copy OSDCloud logs and cleanup directories
#===================================================================================================================================================
Write-Host -ForegroundColor Cyan "[$(Get-Date -Format G)] [CleanUp] Copy OSDCloud logs and cleanup directories"
If (Test-Path -Path 'C:\OSDCloud\Logs') {
    Move-Item 'C:\OSDCloud\Logs' -Destination 'C:\ProgramData\OSDeploy' -Force -ErrorAction SilentlyContinue
}
#Move-Item 'C:\ProgramData\OSDeploy' -Destination 'C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\OSD' -Force -ErrorAction SilentlyContinue

If (Test-Path -Path 'C:\OSDCloud') { Remove-Item -Path 'C:\OSDCloud' -Recurse -Force -ErrorAction SilentlyContinue}
If (Test-Path -Path 'C:\Drivers') { Remove-Item 'C:\Drivers' -Recurse -Force -ErrorAction SilentlyContinue}
If (Test-Path -Path 'C:\Intel') { Remove-Item 'C:\Intel' -Recurse -Force -ErrorAction SilentlyContinue}
#If (Test-Path -Path 'C:\ProgramData\OSDeploy') { Remove-Item 'C:\ProgramData\OSDeploy' -Recurse -Force -ErrorAction SilentlyContinue}
If (Test-Path -Path 'C:\ProgramData\OSDeploy\WiFi') { Remove-Item 'C:\ProgramData\OSDeploy\WiFi' -Recurse -Force -ErrorAction SilentlyContinue}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] CleanUp"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] SECTION took " -NoNewline
Write-Host -ForegroundColor Cyan  "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Gray  "minutes to execute."
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