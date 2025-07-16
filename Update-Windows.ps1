# Check if running in x64bit environment
Write-Host -ForegroundColor Green "Is 64bit PowerShell: $([Environment]::Is64BitProcess)"
Write-Host -ForegroundColor Green "Is 64bit OS: $([Environment]::Is64BitOperatingSystem)"

Write-Host -ForegroundColor Green "Install Windows Updates: " -NoNewline
Write-Host -ForegroundColor Yellow "Update-Windows.ps1"

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
$Global:Transcript = "Update-Windows.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

# Check Internet Connection
$AllNetConnectionProfiles = Get-NetConnectionProfile
$AllNetConnectionProfiles | Where-Object {$_.IPv4Connectivity -eq 'Internet' -or $_.IPv6Connectivity -eq 'Internet'}
if ($AllNetConnectionProfiles) { 
    Write-Host -ForegroundColor Green "Internet connection succesfull"
    Write-Output $AllNetConnectionProfiles
}
else {
    Write-Host -ForegroundColor Yellow "No Internet Connection. Start Wi-Fi setup."  
    Start-Process -FilePath C:\Windows\WirelessConnect.exe -Wait
    start-Sleep -Seconds 10
}

$IPConfig = Get-NetIPConfiguration
Write-host -ForegroundColor Green "IPConfig"
Write-Output $IPConfig

try {

    # Install latest NuGet package provider
    Write-Host -ForegroundColor Green "Install latest NuGet package provider"
    Install-PackageProvider -Name "NuGet" -Force -ErrorAction SilentlyContinue -Verbose:$true

    # Ensure default PSGallery repository is registered
    Write-Host -ForegroundColor Green "Ensure default PSGallery repository is registered"
    Register-PSRepository -Default -ErrorAction SilentlyContinue

    # Attempt to get the installed PowerShellGet module
    Write-Host -ForegroundColor Green "Attempt to get the installed PowerShellGet module"
    $PowerShellGetInstalledModule = Get-InstalledModule -Name "PowerShellGet" -ErrorAction SilentlyContinue -Verbose:$true
    if ($PowerShellGetInstalledModule) {
        # Attempt to locate the latest available version of the PowerShellGet module from repository
        Write-Host -ForegroundColor Green "Attempt to locate the latest available version of the PowerShellGet module from repository"
        $PowerShellGetLatestModule = Find-Module -Name "PowerShellGet" -ErrorAction SilentlyContinue -Verbose:$true
        if ($PowerShellGetLatestModule) {
            if ($PowerShellGetInstalledModule.Version -lt $PowerShellGetLatestModule.Version) {
                Update-Module -Name "PowerShellGet" -Scope "AllUsers" -Force -ErrorAction SilentlyContinue -Confirm:$false -Verbose:$true
            }
        }
    }
    else {
        # PowerShellGet module was not found, attempt to install from repository
        Write-Host -ForegroundColor Yellow "PowerShellGet module was not found, attempt to install from repository"
        Install-Module -Name "PackageManagement" -Force -Scope AllUsers -AllowClobber -ErrorAction SilentlyContinue -Verbose:$true
        Install-Module -Name "PowerShellGet" -Force -Scope AllUsers -AllowClobber -ErrorAction SilentlyContinue -Verbose:$true
    }

    Write-Host -ForegroundColor Green "Install Module PSWindowsUpdate"
    Install-Module -Name PSWindowsUpdate -Force -Scope AllUsers -AllowClobber
    Import-Module PSWindowsUpdate -Scope Global

    Write-Host -ForegroundColor Green "Install Windows Updates"
    Install-WindowsUpdate -AcceptAll -IgnoreReboot

    # Uninstall blocking language Update
    # Microsoft Community notes that after installing KB5050009, 
    # users might experience situations where the new display language 
    # isn't fully applied, leaving some elements of the UI, 
    # such as the Settings side panel or desktop icon labels, 
    # in English or a different language. This is particularly noticeable 
    # if additional languages were previously installed
    Write-Host -ForegroundColor Green "Uninstall KB5050009"
    Remove-WindowsUpdate -KBArticleID KB5050009 -IgnoreReboot   
    
    Stop-Transcript | Out-Null
} 
catch [System.Exception] {
    Write-Host -ForegroundColor Red "Windows Updates failed with error: $($_.Exception.Message)"
    Stop-Transcript | Out-Null
}
