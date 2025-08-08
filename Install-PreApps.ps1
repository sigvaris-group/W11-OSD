# Check if running in x64bit environment
Write-Host -ForegroundColor Green "Is 64bit PowerShell: $([Environment]::Is64BitProcess)"
Write-Host -ForegroundColor Green "Is 64bit OS: $([Environment]::Is64BitOperatingSystem)"

Write-Host -ForegroundColor Green "Install prerequired apps: " -NoNewline
Write-Host -ForegroundColor Yellow "Install-PreApps.ps1"

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

start-Sleep -Seconds 30

If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null}
$Global:Transcript = "Install-PreApps.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

# Check Internet Connection
$AllNetConnectionProfiles = Get-NetConnectionProfile
Write-Output $AllNetConnectionProfiles
$AllNetConnectionProfiles | Where-Object {$_.IPv4Connectivity -eq 'Internet' -or $_.IPv6Connectivity -eq 'Internet'}
if ($AllNetConnectionProfiles) { 
    Write-Host -ForegroundColor Green "Internet connection succesfull"
}
else {
    Write-Host -ForegroundColor Yellow "No Internet Connection. Start Wi-Fi setup."  
    Start-Process -FilePath C:\Windows\WirelessConnect.exe -Wait
    start-Sleep -Seconds 10
}

$IPConfig = Get-NetIPConfiguration
Write-host -ForegroundColor Green "IPConfig before install Forescout"
Write-Output $IPConfig

try {

    Write-Host -ForegroundColor Green "Install Forescout Secure Connector"
    $MSIArguments = @(
        "/i"
        ('"{0}"' -f 'C:\Windows\Temp\SecureConnectorInstaller.msi')
        "MODE=AAAAAAAAAAAAAAAAAAAAAAoWAw8nE2tvKW7g1P8yKnqq6ZfnbnboiWRweKc1A4Tdz0m6pV4kBAAB1Sl1Nw-- /qn"
    )
    Start-Process -Wait "msiexec.exe" -ArgumentList $MSIArguments -Verbose
    $SecCon = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "*SecureConnector*"} 
    if ($SecCon) {
        Write-Host -ForegroundColor Green "Forescout Version $($SecCon.Version) successfully installed" 
    }
    else {
        Write-Host -ForegroundColor Red "Forescout Secure Connector is not installed"
    }

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