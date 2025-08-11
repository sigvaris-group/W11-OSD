# Check if running in x64bit environment
Write-Host -ForegroundColor Green "Is 64bit PowerShell: $([Environment]::Is64BitProcess)"
Write-Host -ForegroundColor Green "Is 64bit OS: $([Environment]::Is64BitOperatingSystem)"

Write-Host -ForegroundColor Green "Script: " -NoNewline
Write-Host -ForegroundColor Yellow "Check-DomainConnection.ps1"

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
$ScriptName = 'Check-DomainConnection.ps1' # Name
$ScriptDescription = 'This script checks to connection to the central domain controller siemdc02.sigvaris-group.com' # Description:
$ScriptVersion = '1.0' # Version
$ScriptDate = '11.08.2025' # Created on
$ScriptUpdateDate = '' # Update on
$ScriptUpdateReason = '' # Update reason
$ScriptDepartment = 'GA & Workplace Team' # Department
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
$OSDComputername = $($json.OSDComputername)
$OSDLocation = $($json.OSDLocation)
$OSDDomainJoin = $($json.OSDDomainJoin)

Write-Host -ForegroundColor Blue "[$($DT)] [UI] Your Settings are:"
Write-Host -ForegroundColor Blue "Computername: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDComputername)"
Write-Host -ForegroundColor Blue "Location: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDLocation)"
Write-Host -ForegroundColor Blue "Active Directory Domain Join: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDDomainJoin)"

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] UI"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] SECTION took " -NoNewline
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================
# [SECTION] DomainConnection
# ================================================================================================================================================

# Check if domain join set to Yes
if ($OSDDomainJoin -eq 'Yes') {

    $SectionStartTime = Get-Date
    Write-Host -ForegroundColor DarkBlue $SL
    Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] DomainConnection"
    Write-Host -ForegroundColor DarkBlue $SL

    $CheckDC = 'siemdc02.sigvaris-group.com'
    Write-Host -ForegroundColor Blue "[$($DT)] [DomainConnection] Check if Domain Controller " -NoNewline
    Write-Host -ForegroundColor Cyan "$($CheckDC)"
    Write-Host -ForegroundColor Blue " available"
    Write-Host -ForegroundColor Blue "[$($DT)] [DomainConnection] Start PowerShell test: " -NoNewline
    Write-Host -ForegroundColor Cyan 'Test-NetConnection siemdc02.sigvaris-group.com -Port 135'

    $ping = Test-NetConnection $CheckDC -Port 135
    if ($ping.TcpTestSucceeded -eq $false) {
        Write-Host -ForegroundColor Red "[$($DT)] [DomainConnection] Domain Controller $($CheckDC) is not reachable."  
        Write-Host -ForegroundColor Red "[$($DT)] [DomainConnection] Script "$($ScriptName)" will be canceled."
        Write-Host -ForegroundColor Red "[$($DT)] [DomainConnection] Make sure that the device is wired connected and can access the $($CheckDC)" 
    
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Domain Join will be failed because domain controller $($CheckDC) is not reachable.",0,"DOMAIN JOIN FAILED","16")
        Exit 1   
    }
    else {
        Write-Host -ForegroundColor Green "[$($DT)] [DomainConnection] Connection to domain controller $($CheckDC) is succesfull"
    }
  }
else {
    Write-Host -ForegroundColor Cyan "[$($DT)] [DomainConnection] Device will not be domain joined"    
}   

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