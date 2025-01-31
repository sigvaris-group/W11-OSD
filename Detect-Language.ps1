#=============================================================================================================================
#
# Script Name:     Detect-Language.ps1
# Description:     Check if the right language is installed
# Created:         01/31/2024
# Updated:         
# Version:         1.0
#
#=============================================================================================================================

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

#=======================================================================
#   Create logfile
#=======================================================================
If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null}
$Global:Transcript = "Detect-Language.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

#=======================================================================
#   Load UIjson.json file
#=======================================================================
Write-Host -ForegroundColor Green "Load C:\ProgramData\OSDeploy\UIjson.json file"
$json = Get-Content -Path "C:\ProgramData\OSDeploy\UIjson.json" -Raw | ConvertFrom-Json

# Access JSON properties
$OSDLanguage = $json.OSDLanguage
$OSDKeyboard = $json.OSDKeyboard
$OSDGeoID = $json.OSDGeoID

Write-Host -ForegroundColor Green "Language: $OSDLanguage"
Write-Host -ForegroundColor Green "Keyboard: $OSDKeyboard"
Write-Host -ForegroundColor Green "GeoID: $OSDGeoID"

# Import modules
Import-Module International
Import-Module LanguagePackManagement

if (Get-Command Install-Language) {
    $Languages = Get-InstalledLanguage
    $LanguagePresent = $false
    foreach ($Language in $Languages) {
        Write-Host -ForegroundColor Green "Found installed language $($Language.LanguageId)"
        if ($Language.LanguageId -eq $OSDLanguage) {
            $LanguagePresent = $true
        }
    }
    
    if ($LanguagePresent -eq $false) {
        Write-Host -ForegroundColor Red "$OSDLanguage is not installed"
        Stop-Transcript
        Exit 1
    }
} else {
    Write-Host -ForegroundColor Red "Missing language install command"
    Exit 1
}

$UIPreferred = Get-SystemPreferredUILanguage
if ($UIPreferred -ne $OSDLanguage) {
    Write-Host -ForegroundColor Red "Preferred UI language is not $OSDLanguage"
    Stop-Transcript
    Exit 1
}

$Locale = (Get-WinSystemLocale).Name
if ($Locale -ne $OSDLanguage) {
    Write-Host -ForegroundColor Red "Locale is not $OSDLanguage"
    Stop-Transcript
    Exit 1
}

Write-Host -ForegroundColor Green "All tests passed!"
Stop-Transcript | Out-Null
Exit 0