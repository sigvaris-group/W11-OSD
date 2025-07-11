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
$ScriptName = 'Install_Pre_Apps-Dev.ps1' # Name
$ScriptDescription = 'Install prerequired apps' # Description
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

try {

    Write-Host -ForegroundColor Green "Install Forescout Secure Connector"
    $MSIArguments = @(
        "/i"
        ('"{0}"' -f 'C:\Windows\Temp\SecureConnectorInstaller.msi')
        "MODE=AAAAAAAAAAAAAAAAAAAAAAoWAw8nE2tvKW7g1P8yKnqq6ZfnbnboiWRweKc1A4Tdz0m6pV4kBAAB1Sl1Nw-- /qn"
    )
    Start-Process -Wait "msiexec.exe" -ArgumentList $MSIArguments -Verbose

    Start-Sleep -Seconds 60

    $IPConfig = Get-NetIPConfiguration
    Write-host -ForegroundColor Green "IPConfig after install Forescout"
    Write-Output $IPConfig

    Stop-Transcript | Out-Null
} 
catch [System.Exception] {
    Write-Host -ForegroundColor Red "Install PreApps failed with error: $($_.Exception.Message)"
    Stop-Transcript | Out-Null
    exit 1
}

$EndTime = Get-Date
$ExecutionTime = $EndTime - $StartTime

Write-Host -ForegroundColor Green "[$($DT)] [End] Script ended $($EndTime)"
Write-Host -ForegroundColor Green "[$($DT)] [End] Script took $($ExecutionTime.Minutes) minutes to execute"

Stop-Transcript | Out-Null