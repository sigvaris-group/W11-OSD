# Check if running in x64bit environment
Write-Host -ForegroundColor Green "Is 64bit PowerShell: $([Environment]::Is64BitProcess)"
Write-Host -ForegroundColor Green "Is 64bit OS: $([Environment]::Is64BitOperatingSystem)"

Write-Host -ForegroundColor Green "Import Wi-Fi Profiles if exists: " -NoNewline
Write-Host -ForegroundColor Yellow "Import-WiFiProfiles.ps1"

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

start-Sleep -Seconds 10

If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null}
$Global:Transcript = "Import-WiFiProfiles.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

Write-Host -ForegroundColor Cyan "Starting WlanSvc Service" -NoNewline
if (Get-Service -Name WlanSvc) {
    if ((Get-Service -Name WlanSvc).Status -ne 'Running') {
        Get-Service -Name WlanSvc | Start-Service
        Start-Sleep -Seconds 10

    }
}
Write-Host -ForegroundColor Green 'OK'

Write-Host -ForegroundColor Green "Import Wi-Fi profiles"
$XmlDirectory = "C:\ProgramData\OSDeploy\WiFi"
Get-ChildItem $XmlDirectory | Where-Object {$_.extension -eq ".xml"} | ForEach-Object {netsh wlan add profile filename=($XmlDirectory+"\"+$_.name)}

<#
Write-Host -ForegroundColor Green "Start Wi-Fi connection"
$profiles = Get-ChildItem $XmlDirectory | Where-Object {$_.extension -eq ".xml"}
foreach ($profile in $profiles) {
    [xml]$wifiProfile = Get-Content -path $profile.fullname
    $SSID = $wifiProfile.WLANProfile.SSIDConfig.SSID.name
    $ProfileName = $profile.Name
    netsh wlan connect ssid="$($SSID)" name="$($ProfileName)"
}
#>

Stop-Transcript | Out-Null