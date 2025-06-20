#=============================================================================================================================
#
# Script Name:     Install-PreApps.ps1
# Description:     Install prerequired apps
# Created:         06/14/2025
# Version:         3.0
#
#=============================================================================================================================

$Title = "Install prerequired apps"
$host.UI.RawUI.WindowTitle = $Title
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

$env:APPDATA = "C:\Windows\System32\Config\SystemProfile\AppData\Roaming"
$env:LOCALAPPDATA = "C:\Windows\System32\Config\SystemProfile\AppData\Local"
$Env:PSModulePath = $env:PSModulePath+";C:\Program Files\WindowsPowerShell\Scripts"
$env:Path = $env:Path+";C:\Program Files\WindowsPowerShell\Scripts"

# Check if running in x64bit environment
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

If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null}
$Global:Transcript = "Install-PreApps.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

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