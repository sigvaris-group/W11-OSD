#=============================================================================================================================
#
# Script Name:     Update-Windows.ps1
# Description:     Install Windows Updates
# Created:         01/30/2025
# Updated:         02/20/2025 Query if Windows Updates selected
# Version:         1.1
#
#=============================================================================================================================

$Title = "Install Windows Updates"
$host.UI.RawUI.WindowTitle = $Title
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
$Global:Transcript = "Update-Windows.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

#=======================================================================
#   Load UIjson.json file
#=======================================================================
Write-Host -ForegroundColor Green "Load C:\ProgramData\OSDeploy\UIjson.json file"
$json = Get-Content -Path "C:\ProgramData\OSDeploy\UIjson.json" -Raw | ConvertFrom-Json

# Access JSON properties
$OSDWindowsUpdate = $json.OSDWindowsUpdate

If ($OSDWindowsUpdate -eq "Yes") {
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
        #Install-WindowsUpdate -ForceInstall -AcceptAll -IgnoreReboot 

        # Get a list of available updates
        $updates = Get-WindowsUpdate -Verbose
        Write-Host -ForegroundColor Green "  Updates available: $($updates.count)"

        # Filter for a specific title
        $update = $updates | Where-Object {$_.Title -like '*Cumulative Update for Windows 11 Version 24H2 for x64-based Systems*'}

        # Install the update (replace with the correct update object)
        if ($update) {
                Write-Host -ForegroundColor Green "  Install update: $($update.Title)"
                $update | Install-WindowsUpdate -KBArticleID $($update.KB) -AcceptAll -IgnoreReboot -Verbose
        }
        else {
                Write-Host -ForegroundColor Green "  Install all updates"
                Install-WindowsUpdate -ForceInstall -AcceptAll -IgnoreReboot 
        }        
       
        # Uninstall blocking language Update
        # Microsoft Community notes that after installing KB5050009, 
        # users might experience situations where the new display language 
        # isn't fully applied, leaving some elements of the UI, 
        # such as the Settings side panel or desktop icon labels, 
        # in English or a different language. This is particularly noticeable 
        # if additional languages were previously installed
        Write-Host -ForegroundColor Green "Uninstall KB5050009"
        Remove-WindowsUpdate -KBArticleID KB5050009 -IgnoreReboot
}
else {
        Write-Host -ForegroundColor Yellow "No Windows Updates installed"
}

Stop-Transcript | Out-Null