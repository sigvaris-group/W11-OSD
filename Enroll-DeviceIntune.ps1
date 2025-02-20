#=============================================================================================================================
#
# Script Name:     Enroll-DeviceIntune.ps1
# Description:     Enroll the device into Intune
# Created:         02/20/2025
# Updated:         
# Version:         1.0
#
#=============================================================================================================================

$Title = "Enroll the device into Intune"
$host.UI.RawUI.WindowTitle = $Title
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

$env:APPDATA = "C:\Windows\System32\Config\SystemProfile\AppData\Roaming"
$env:LOCALAPPDATA = "C:\Windows\System32\Config\SystemProfile\AppData\Local"
$Env:PSModulePath = $env:PSModulePath+";C:\Program Files\WindowsPowerShell\Scripts"
$env:Path = $env:Path+";C:\Program Files\WindowsPowerShell\Scripts"

Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null}
$Global:Transcript = "Enroll-DeviceIntune.log"
Start-Transcript -Path (Join-Path "C:\ProgramData\OSDeploy\" $Global:Transcript) -ErrorAction Ignore

#=======================================================================
#   Load UIjson.json file
#=======================================================================
Write-Host -ForegroundColor Green "Load C:\ProgramData\OSDeploy\UIjson.json file"
$json = Get-Content -Path "C:\ProgramData\OSDeploy\UIjson.json" -Raw | ConvertFrom-Json

# Access JSON properties
$OSDDomainJoin = $json.OSDDomainJoin

Write-Host -ForegroundColor Green "Windows Updates $OSDWindowsUpdate"

If ($OSDDomainJoin -eq "Yes") {
    Write-Host -ForegroundColor Yellow "Device is Hyprid joined"    
    # Set MDM Enrollment URL's
    $key = 'SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\*'
    try {
        $keyinfo = Get-Item "HKLM:\$key"
        if ($keyinfo) {
            <# Action to perform if the condition is true #>
            $url = $keyinfo.name
            $url = $url.Split("\")[-1]
            $path = "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\$url"
            if (!(Test-Path $path)){
                Write-Host "KEY $path not found!"
            }
            else {
                try {
                    Get-ItemProperty $path -Name MdmEnrollmentUrl
                }
                catch {
                    Write_Host "MDM Enrollment registry keys not found. Registering now..."
                    New-ItemProperty -LiteralPath $path -Name 'MdmEnrollmentUrl' -Value 'https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc' -PropertyType String -Force -ea SilentlyContinue;
                    New-ItemProperty -LiteralPath $path -Name 'MdmTermsOfUseUrl' -Value 'https://portal.manage.microsoft.com/TermsofUse.aspx' -PropertyType String -Force -ea SilentlyContinue;
                    New-ItemProperty -LiteralPath $path -Name 'MdmComplianceUrl' -Value 'https://portal.manage.microsoft.com/?portalAction=Compliance' -PropertyType String -Force -ea SilentlyContinue;
                }
                finally {
                # Trigger AutoEnroll with the deviceenroller
                    try {
                        C:\Windows\system32\deviceenroller.exe /c /AutoEnrollMDM
                        Write-Host -ForegroundColor Green "Device is performing the MDM enrollment!"
                    }
                    catch {
                        Write-Host -ForegroundColor Red "Something went wrong (C:\Windows\system32\deviceenroller.exe)"      
                    }
                }
            }            
        }
    }
    catch {
        Write-Host "Tenant ID is not found!"
    }
}
else {
    Write-Host -ForegroundColor Green "Device is Entra ID joined"
}

Stop-Transcript | Out-Null