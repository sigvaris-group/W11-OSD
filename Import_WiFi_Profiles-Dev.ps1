# Check if running in x64bit environment
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
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

# Script Informationa
$ScriptName = 'Import_WiFi_Profiles-Dev.ps1' # Name
$ScriptDescription = 'Import WiFi Profiles' # Description
$ScriptEnv = 'TEST' # Environment: TEST, PRODUCTION, OFFLINE
$ScriptVersion = '1.0' # Version
$ScriptDate = '08.07.2025' # Created on
$ScriptUpdateDate = '' # Update on
$ScriptUpdateReason = '' # Update reason
$ScriptDepartment = 'Global IT' # Department
#$ScriptAuthor = 'Andreas Schilling' # Author

# Script Local Variables
$Error.Clear()
$SL = "================================================================================================================================================~"
$EL = "`n================================================================================================================================================~`n"
$DT = Get-Date -format G
$LogFilePath = "C:\OSDCloud\Logs"
$LogFile = $ScriptName -replace ".{3}$", "log"
$StartTime = Get-Date

Start-Transcript -Path (Join-Path $LogFilePath $LogFile) -ErrorAction Ignore
Write-Host -ForegroundColor Green "[$($DT)] [Start] Script started $($StartTime)"

# Script Information
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [$($ScriptEnv)] Script"
Write-Host -ForegroundColor Cyan "Name:             $($ScriptName)"
Write-Host -ForegroundColor Cyan "Description:      $($ScriptDescription)"
Write-Host -ForegroundColor Cyan "Environment:      $($ScriptEnv)"
Write-Host -ForegroundColor Cyan "Version:          $($ScriptVersion)"
Write-Host -ForegroundColor Cyan "Created on:       $($ScriptDate)"
Write-Host -ForegroundColor Cyan "Update on:        $($ScriptUpdateDate)"
Write-Host -ForegroundColor Cyan "Update reason:    $($ScriptUpdateReason )"
Write-Host -ForegroundColor Cyan "Department:       $($ScriptDepartment)"
#Write-Host -ForegroundColor Cyan "Author:           $($ScriptAuthor)"
Write-Host -ForegroundColor Cyan "Logfile Path:     $($LogFilePath)"
Write-Host -ForegroundColor Cyan "Logfile:          $($LogFile)"
Write-Host -ForegroundColor DarkBlue $EL

# Start Import Wi-Fi profiles
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [Wi-Fi] Start Import Wi-Fi profiles"
Write-Host -ForegroundColor DarkBlue $SL

$XmlDirectory = "C:\OSDCloud\WiFi" 
if (Test-Path $XmlDirectory) {
    Write-Host -ForegroundColor Green "[$($DT)] [Wi-Fi] Import Wi-Fi profiles from $($XmlDirectory)"
    Get-ChildItem $XmlDirectory | Where-Object {$_.extension -eq ".xml"} | ForEach-Object {netsh wlan add profile filename=($XmlDirectory+"\"+$_.name)}
}
else {
    Write-Host -ForegroundColor Cyan "[$($DT)] [Wi-Fi] No Wi-Fi profiles exists."
}

# Check Internet Connection 
$CheckDomain = 'techcommunity.microsoft.com'
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [Network] Check Internet Connection: $($CheckDomain)"
Write-Host -ForegroundColor DarkBlue $SL

$ping = Test-NetConnection $CheckDomain
if ($ping.PingSucceeded -eq $false) {
    Write-Host -ForegroundColor Red "[$($DT)] [Network] No Internet Connection. Start Wi-Fi setup."  
    Start-Process -FilePath C:\Windows\WirelessConnect.exe -Wait
    start-Sleep -Seconds 10   
}
else {
    Write-Host -ForegroundColor Green "[$($DT)] [Network] Internet connection to $($CheckDomain) succesfull"
}

Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [Network] Network information"
Write-Host -ForegroundColor DarkBlue $SL
$IPConfig = Get-NetIPConfiguration
Write-Host -ForegroundColor Cyan "[$($DT)] [Network] Get-NetIPConfiguration"
Write-Output $IPConfig
Write-Host -ForegroundColor DarkBlue $EL

$EndTime = Get-Date
$ExecutionTime = $EndTime - $StartTime

Write-Host -ForegroundColor Green "[$($DT)] [End] Script ended $($EndTime)"
Write-Host -ForegroundColor Green "[$($DT)] [End] Script took $($ExecutionTime.Minutes) minutes to execute"

Stop-Transcript | Out-Null