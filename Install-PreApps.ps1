# Check if running in x64bit environment
Write-Host -ForegroundColor Gray "Is 64bit PowerShell: $([Environment]::Is64BitProcess)"
Write-Host -ForegroundColor Gray "Is 64bit OS: $([Environment]::Is64BitOperatingSystem)"

Write-Host -ForegroundColor Gray "Script: " -NoNewline
Write-Host -ForegroundColor Cyan "Install-PreApps.ps1"

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
$ScriptName = 'Install-PreApps.ps1' # Name
$ScriptDescription = 'This script installs applications before OOBE' # Description:
$ScriptVersion = '1.0' # Version
$ScriptDate = '14.10.2025' # Created on
$ScriptUpdateDate = '' # Update on
$ScriptUpdateReason = '' # Update reason
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
$OSDComputername = $($json.OSDComputername)
$OSDLocation = $($json.OSDLocation)
$OSDLanguage = $($json.OSDLanguage)
$OSDDisplayLanguage = $($json.OSDDisplayLanguage)
$OSDLanguagePack = $($json.OSDLanguagePack)
$OSDKeyboard = $($json.OSDKeyboard)
$OSDKeyboardLocale = $($json.OSDKeyboardLocale)
$OSDGeoID = $($json.OSDGeoID)
$OSDTimeZone = $($json.OSDTimeZone)
$OSDDomainJoin = $($json.OSDDomainJoin)

Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [UI] Your Settings are:"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [UI] Computername: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDComputername)"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [UI] Location: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDLocation)"
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
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [UI] Active Directory Domain Join: " -NoNewline
Write-Host -ForegroundColor Cyan "$($OSDDomainJoin)"

if ($OSDComputername -ne $env:COMPUTERNAME) {
    Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [UI] Set Computername to: " -NoNewline
    Write-Host -ForegroundColor Cyan "$($OSDComputername)"
    Rename-Computer -NewName $OSDComputername
}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] UI"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] SECTION took " -NoNewline
Write-Host -ForegroundColor Cyan "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Gray  "minutes to execute."
Write-Host -ForegroundColor DarkGray $SL

# ================================================================================================================================================~
# [SECTION] Forescout
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-Start] Forescout"
Write-Host -ForegroundColor DarkGray $SL

try {
    Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Forescout] Install Forescout Secure Connector"
    $MSIArguments = @(
        "/i"
        ('"{0}"' -f 'C:\Windows\Temp\SecureConnectorInstaller.msi')
        "MODE=AAAAAAAAAAAAAAAAAAAAAAoWAw8nE2tvKW7g1P8yKnqq6ZfnbnboiWRweKc1A4Tdz0m6pV4kBAAB1Sl1Nw-- /qn"
    )
    Start-Process -Wait "msiexec.exe" -ArgumentList $MSIArguments
    Start-Sleep -Seconds 30
    
    $SecCon = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "*SecureConnector*"} 
    if ($SecCon) {
        Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [Forescout] " -NoNewline
        Write-Host -ForegroundColor Cyan "$($SecCon.Name)" -NoNewline
        Write-Host -ForegroundColor Gray " Version " -NoNewline
        Write-Host -ForegroundColor Cyan "$($SecCon.Version)"  -NoNewline
        Write-Host -ForegroundColor Gray " successfully installed" 
        Start-Sleep 60
    }
    else {
        Write-Host -ForegroundColor Red "[$(Get-Date -Format G)] [Forescout] Secure Connector is not installed"
    }
} 
catch {
    Write-Host -ForegroundColor Red "[$(Get-Date -Format G)] [Forescout] Install Forescout Secure Connector failed with error: " -NoNewline
    Write-Host -ForegroundColor Yellow "$($_.Exception.Message)"
}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkGray $SL
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] Forescout"
Write-Host -ForegroundColor Gray "[$(Get-Date -Format G)] [SECTION-End] SECTION took " -NoNewline
Write-Host -ForegroundColor Cyan   "$($ExecutionTime.Minutes) " -NoNewline
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