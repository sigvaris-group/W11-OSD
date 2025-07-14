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

# Script Information
$ScriptName = 'OS_Install.ps1' # Name
$ScriptDescription = 'This script install the Operation System based on the initial script' # Description:
$ScriptVersion = '1.0' # Version
$ScriptDate = '10.07.2025' # Created on
$ScriptUpdateDate = '' # Update on
$ScriptUpdateReason = '' # Update reason
$ScriptDepartment = 'Global IT' # Department
$ScriptAuthor = 'Andreas Schilling' # Author

# Script Local Variables
$Error.Clear()
$SL = "================================================================================================================================================~"
$EL = "`n================================================================================================================================================~`n"
$DT = Get-Date -format G
$LogFilePath = "C:\OSDCloud\Logs"
$LogFile = $ScriptName -replace ".{3}$", "log"
$StartTime = Get-Date

# Script Information
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Cyan "Name:             $($ScriptName)"
Write-Host -ForegroundColor Cyan "Description:      $($ScriptDescription)"
Write-Host -ForegroundColor Cyan "Version:          $($ScriptVersion)"
Write-Host -ForegroundColor Cyan "Created on:       $($ScriptDate)"
Write-Host -ForegroundColor Cyan "Update on:        $($ScriptUpdateDate)"
Write-Host -ForegroundColor Cyan "Update reason:    $($ScriptUpdateReason )"
Write-Host -ForegroundColor Cyan "Department:       $($ScriptDepartment)"
Write-Host -ForegroundColor Cyan "Author:           $($ScriptAuthor)"
Write-Host -ForegroundColor Cyan "Logfile Path:     $($LogFilePath)"
Write-Host -ForegroundColor Cyan "Logfile:          $($LogFile)"
Write-Host -ForegroundColor DarkBlue $EL

If (!(Test-Path $LogFilePath)) { New-Item $LogFilePath -ItemType Directory -Force | Out-Null }
Start-Transcript -Path (Join-Path $LogFilePath $LogFile) -ErrorAction Ignore
Write-Host -ForegroundColor Green "[$($DT)] [Start] Script started $($StartTime)"

# ================================================================================================================================================~
# [SECTION] UI
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] UI"
Write-Host -ForegroundColor DarkBlue $SL

$jsonpath = "C:\ProgramData\OSDeploy\UIjson.json"
Write-Host -ForegroundColor Cyan "[$($DT)] [UI] Load UIjson.json file from $($jsonpath)"

$json = Get-Content -Path $jsonpath  -Raw | ConvertFrom-Json
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
$OSDWindowsUpdate = $($json.OSDWindowsUpdate)

Write-Host -ForegroundColor Green "Computername: $($OSDComputername)"
Write-Host -ForegroundColor Green "Location: $($OSDLocation)"
Write-Host -ForegroundColor Green "OS Language: $($OSDLanguage)"
Write-Host -ForegroundColor Green "Display Language: $($OSDDisplayLanguage)"
Write-Host -ForegroundColor Green "Language Pack: $($OSDLanguagePack)"
Write-Host -ForegroundColor Green "Keyboard: $($OSDKeyboard)"
Write-Host -ForegroundColor Green "KeyboardLocale: $($OSDKeyboardLocale)"
Write-Host -ForegroundColor Green "GeoID: $($OSDGeoID)"
Write-Host -ForegroundColor Green "TimeZone: $($OSDTimeZone)"
Write-Host -ForegroundColor Green "Active Directory Domain Join: $($OSDDomainJoin)"
Write-Host -ForegroundColor Green "Windows Updates: $($OSDWindowsUpdate)"

Write-Host -ForegroundColor Cyan "[$($DT)] [UI] Set TimeZone to $($OSDTimeZone)"
Set-TimeZone -Id $OSDTimeZone
tzutil.exe /s "$($OSDTimeZone)" 

if ($OSDComputername -ne $env:COMPUTERNAME) {
    Write-Host -ForegroundColor Cyan "[$($DT)] [UI] Set Computername to $($OSDComputername)"
    Rename-Computer -NewName $OSDComputername
}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] UI"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White   "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] Forescout
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] Forescout"
Write-Host -ForegroundColor DarkBlue $SL

try {
    Write-Host -ForegroundColor Cyan "[$($DT)] [Forescout] Install Forescout Secure Connector"
    $MSIArguments = @(
        "/i"
        ('"{0}"' -f 'C:\Windows\Temp\SecureConnectorInstaller.msi')
        "MODE=AAAAAAAAAAAAAAAAAAAAAAoWAw8nE2tvKW7g1P8yKnqq6ZfnbnboiWRweKc1A4Tdz0m6pV4kBAAB1Sl1Nw-- /qn"
    )
    Start-Process -Wait "msiexec.exe" -ArgumentList $MSIArguments
    $SecCon = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "*SecureConnector*"} 
    if ($SecCon) {
        Write-Host -ForegroundColor Green "[$($DT)] [Forescout] $($SecCon.Name) Version $($SecCon.Version) successfully installed" 
        Start-Sleep 60
    }
    else {
        Write-Host -ForegroundColor Red "[$($DT)] [Forescout] Forescout Secure Connector is not installed"
    }
} 
catch {
    Write-Host -ForegroundColor Red "[$($DT)] [Forescout] Install Forescout Secure Connector failed with error: " -NoNewline
    Write-Host -ForegroundColor Yellow "$($_.Exception.Message)"
}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Forescout"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White   "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] Wi-Fi
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] Wi-Fi"
Write-Host -ForegroundColor DarkBlue $SL

$XmlDirectory = "C:\OSDCloud\WiFi" # Path set by initial script
Write-Host -ForegroundColor Cyan "[$($DT)] [Wi-Fi] Import Wi-Fi profiles from $($XmlDirectory)"

try {
    if (Test-Path $XmlDirectory) {
        Get-ChildItem $XmlDirectory | Where-Object {$_.extension -eq ".xml"} | ForEach-Object {netsh wlan add profile filename=($XmlDirectory+"\"+$_.name)}
    }
    else {
        Write-Host -ForegroundColor Yellow "[$($DT)] [Wi-Fi] No Wi-Fi profiles exists to import"
    }   
}
catch {
    Write-Host -ForegroundColor Red "[$($DT)] [Wi-Fi] Import Wi-Fi profiles failed with error: " -NoNewline
    Write-Host -ForegroundColor Yellow "$($_.Exception.Message)"
}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Wi-Fi"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White   "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] Network
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] Network"
Write-Host -ForegroundColor DarkBlue $SL

$IPConfig = Get-NetIPConfiguration
Write-Host -ForegroundColor Cyan "[$($DT)] [Network] Get-NetIPConfiguration"
Write-Output $IPConfig

$CheckDomain = 'techcommunity.microsoft.com'
$CheckIP = '23.63.114.210'
Write-Host -ForegroundColor Cyan "[$($DT)] [Network] Check Internet Connection: $($CheckDomain)"

#$ping = Test-NetConnection $CheckDomain -Hops 4
$port = Test-NetConnection $CheckIP -Port 443 -InformationLevel Detailed
if ($ping.PingSucceeded -eq $false -or $port.TcpTestSucceeded -eq $false) {
    Write-Host -ForegroundColor Red "[$($DT)] [Network] No Internet Connection" 
    Start-Process -FilePath C:\Windows\WirelessConnect.exe -Wait
}
else {
    Write-Host -ForegroundColor Green "[$($DT)] [Network] Successfull connected to Internet"      
}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Network"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White  "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] Autopilot
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] Autopilot"
Write-Host -ForegroundColor DarkBlue $SL

Write-Host -ForegroundColor Cyan "[$($DT)] [Autopilot] Start Autopilot registration"
Start-Process /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\scripts\W11_Autopilot.ps1

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Autopilot"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White  "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] WindowsUpdate
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] WindowsUpdate"
Write-Host -ForegroundColor DarkBlue $SL

If ($OSDWindowsUpdate -eq "Yes") { 
    Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Windows Updates enabled: $($OSDWindowsUpdate)"

    # Opt into Microsoft Update
    Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Opt computer in to the Microsoft Update service and then register that service with Automatic Updates"
    Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] https://learn.microsoft.com/en-us/windows/win32/wua_sdk/opt-in-to-microsoft-update"
    $ServiceManager = New-Object -ComObject "Microsoft.Update.ServiceManager"
    
    #$ServiceManager.Services
    Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Enable Windows Update for other Microsoft products"
    $ServiceID = "7971f918-a847-4430-9279-4a52d1efe18d"
    $ServiceManager.AddService2($ServiceId, 7, "") | Out-Null

    # Set query for updates
    Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Setup query for all available updates and drivers"
    $queries = @("IsInstalled=0 and Type='Software'", "IsInstalled=0 and Type='Driver'")
    
    # Create update collection 
    Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Creating empty collection of all updates to download"
    $WUUpdates = New-Object -ComObject Microsoft.Update.UpdateColl
    
    # Search udpates 
    Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Search updates and add to collection"        
    $queries | ForEach-Object {
        Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Getting $_ updates"      
        try {

            ((New-Object -ComObject Microsoft.Update.Session).CreateupdateSearcher().Search($_)).Updates | ForEach-Object {
                if (!$_.EulaAccepted) { $_.AcceptEula() }
                $featureUpdate = $_.Categories | Where-Object { $_.CategoryID -eq "3689BDC8-B205-4AF4-8D4A-A63924C5E9D5" }
                
                if ($featureUpdate) {
                    Write-Host -ForegroundColor Yellow "[$($DT)] [WindowsUpdate] Skipping feature update: $($_.Title)" 
                } 
                elseif ($_.Title -match "Preview") { 
                    Write-Host -ForegroundColor Yellow "[$($DT)] [WindowsUpdate] Skipping preview update: $($_.Title)" 
                } 
                else {
                    Write-Host -ForegroundColor Green "[$($DT)] [WindowsUpdate] Add $($_.Title) to collection" 
                    [void]$WUUpdates.Add($_)
                }
            }  

            if ($WUUpdates.Count -eq 0) {
                Write-Host -ForegroundColor Yellow "[$($DT)] [WindowsUpdate] No Updates Found" 
            } 
            else {
                Write-Host -ForegroundColor Green "[$($DT)] [WindowsUpdate] Updates found: $($WUUpdates.count)" 
                
                Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Start to install updates"    
                foreach ($update in $WUUpdates) {
                
                    Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Creating single update collection to download and install"
                    $singleUpdate = New-Object -ComObject Microsoft.Update.UpdateColl
                    $singleUpdate.Add($update) | Out-Null
                
                    $WUDownloader = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateDownloader()
                    $WUDownloader.Updates = $singleUpdate
                
                    $WUInstaller = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateInstaller()
                    $WUInstaller.Updates = $singleUpdate
                    $WUInstaller.ForceQuiet = $true
                
                    Write-Host -ForegroundColor Green "[$($DT)] [WindowsUpdate] Downloading update: $($update.Title)"
                    $Download = $WUDownloader.Download()
                    Write-Host -ForegroundColor Green "[$($DT)] [WindowsUpdate] Download result: $($Download.ResultCode) ($($Download.HResult))"
                
                    Write-Host -ForegroundColor Green "[$($DT)] [WindowsUpdate] Installing update: $($update.Title)"
                    $Results = $WUInstaller.Install()
                    Write-Host -ForegroundColor Green "[$($DT)] [WindowsUpdate] Install result: $($Results.ResultCode) ($($Results.HResult))"

                    if ($Results.ResultCode -eq 2) {
                        Write-Host -ForegroundColor Green "[$($DT)] [WindowsUpdate] All updates installed successfully" # result code 2 = success
                    }
                    else {
                        Write-Host -ForegroundColor Yellow "[$($DT)] [WindowsUpdate] Windows Updates failed"
                        Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] See result codes at: https://learn.microsoft.com/en-us/windows/win32/api/wuapi/ne-wuapi-operationresultcode"
                    }
                }
                # Uninstall blocking language Update
                # Microsoft Community notes that after installing KB5050009, 
                # users might experience situations where the new display language 
                # isn't fully applied, leaving some elements of the UI, 
                # such as the Settings side panel or desktop icon labels, 
                # in English or a different language. This is particularly noticeable 
                # if additional languages were previously installed
                Write-Host -ForegroundColor Yellow "[$($DT)] [WindowsUpdate] Uninstall KB5050009 because of the display language issue"
                wusa /uninstall /kb:5050009 /quiet /norestart 
            } 

        } catch {
            # If this script is running during OOBE specialize, error 8024004A will happen:
            # 8024004A	Windows Update agent operations are not available while OS setup is running.
            Write-Host -ForegroundColor Red "[$($DT)] [WindowsUpdate] Unable to search for updates: $_" 
        }
    }
} 
else {    
    Write-Host -ForegroundColor Cyan "[$($DT)] [WindowsUpdate] Windows Updates enabled: $($OSDWindowsUpdate)"
    Write-Host -ForegroundColor Yellow "[$($DT)] [WindowsUpdate] No Updates will be installed"
}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] WindowsUpdate"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White  "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] Language
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] Language"
Write-Host -ForegroundColor DarkBlue $SL

Write-Host -ForegroundColor Cyan "[$($DT)] [Language] Install Language Modules"

# Check if module "LanguagePackManagement" is installed
$module = Get-Module -ListAvailable LanguagePackManagement
# If module not installed, install it
if (-not $module) {
    Write-Host -ForegroundColor Yellow "[$($DT)] [Language] The module 'LanguagePackManagement' will be installed."
    Install-Module -Name LanguagePackManagement -Scope AllUsers -Force -ErrorAction Stop
}
else {
    Write-Host -ForegroundColor Green "[$($DT)] [Language] The module 'LanguagePackManagement' is already installed."
}

# Check if module "International" is installed
$module = Get-Module -ListAvailable International
# If module not installed, install it
if (-not $module) {
    Write-Host -ForegroundColor Yellow "[$($DT)] [Language] The module 'International' will be installed."
    Install-Module -Name International -Scope AllUsers -Force -ErrorAction Stop
}
else {
    Write-Host -ForegroundColor Green "[$($DT)] [Language] The module 'International' is already installed."
}

Import-Module International
Import-Module LanguagePackManagement

Write-Host -ForegroundColor Cyan "[$($DT)] [Language] Install language pack and change the language of the OS on different places ."

# Check currently installed languages
$InstalledLanguages = Get-InstalledLanguage
$InstalledLanguages = $InstalledLanguages | ForEach-Object { $_.LanguageID }
Write-Host -ForegroundColor Cyan "[$($DT)] [Language] Current installed languages: $($InstalledLanguages)"

try {
    Write-Host -ForegroundColor Cyan "[$($DT)] [Language] Install an additional language pack including FODs. With CopyToSettings (optional), this will change language for non-Unicode program."
    If ($OSDDisplayLanguage -ne 'en-US') {
        Write-Host -ForegroundColor Cyan "[$($DT)] [Language] Install OS Language: " -NoNewline
        Write-Host -ForegroundColor Yellow "$($OSDLanguage)"
        Install-Language -Language $OSDLanguage
        
        Write-Host -ForegroundColor Cyan "[$($DT)] [Language] Add Language Features: " -NoNewline
        Write-Host -ForegroundColor Yellow "$($OSDLanguagePack)"
        Add-WindowsCapability -Online -Name "$OSDLanguagePack"
    }
}
catch {
        Write-Host -ForegroundColor Red "[$($DT)] [Language] Error installing language $($OSDDisplayLanguage). Error: " -NoNewline
        Write-Host -ForegroundColor Yellow "$($_.Exception.Message)"

        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Language installation failed. Please check the logfile and if needed contact the GA Workplace Team",0,"LANGUAGE INSTALLATION FAILED","16")
        Exit 1
}

try {
    Write-Host -ForegroundColor Cyan "[$($DT)] [Language] Configure new language defaults under current user (system) after which it can be copied to system."
    Set-WinUILanguageOverride -Language $OSDDisplayLanguage -Verbose -ErrorAction Stop 
    Write-Host -ForegroundColor Cyan "[$($DT)] [Language] SSet WinUI language to: " -NoNewline
    Write-Host -ForegroundColor Yellow "$($OSDDisplayLanguage)"
    
} catch {
    Write-Host -ForegroundColor Red "[$($DT)] [Language] Error setting WinUI language override to $($OSDDisplayLanguage). Error: " -NoNewline
    Write-Host -ForegroundColor Yellow "$($_.Exception.Message)"
}

try {
    Write-Host -ForegroundColor Cyan "[$($DT)] [Language] Configure new language defaults under current user (system) after which it can be copied to system."
    $OldUserLanguageList = Get-WinUserLanguageList
    Write-Host -ForegroundColor Cyan "[$($DT)] [Language] Get-WinUserLanguageList: " -NoNewline
    Write-Host -ForegroundColor Yellow "$($OldUserLanguageList.LanguageTag)"
    Write-Host "    Old-WinUserLanguageList: $($OldUserLanguageList.LanguageTag)"

    $NewUserLanguageList = New-WinUserLanguageList -Language $OSDDisplayLanguage
    Write-Host -ForegroundColor Cyan "[$($DT)] [Language] New-WinUserLanguageList: " -NoNewline
    Write-Host -ForegroundColor Yellow "$($NewUserLanguageList.LanguageTag)"

    if ($OSDDisplayLanguage -eq 'pl-PL') {
        Write-Host -ForegroundColor Cyan "[$($DT)] [Language] Set-WinUserLanguageList: " -NoNewline
        Write-Host -ForegroundColor Yellow "pl-PL"
        Set-WinUserLanguageList -LanguageList 'pl-PL' -Force
    } 
    else {
        Write-Host -ForegroundColor Cyan "[$($DT)] [Language] Set-WinUserLanguageList: " -NoNewline
        Write-Host -ForegroundColor Yellow "$($OSDDisplayLanguage)"
        Set-WinUserLanguageList -LanguageList $OSDDisplayLanguage -Force
    }
    
    $UserLanguageList = Get-WinUserLanguageList
    Write-Host -ForegroundColor Cyan "[$($DT)] [Language] Get-WinUserLanguageList: " -NoNewline
    Write-Host -ForegroundColor Yellow "$($UserLanguageList.LanguageTag)"
 
} catch {
    Write-Host -ForegroundColor Red "[$($DT)] [Language] Error setting WinUserLanguageList to $($OSDDisplayLanguage). Failure: " -NoNewline
    Write-Host -ForegroundColor Yellow "$_"
}

try {
    Write-Host -ForegroundColor Cyan "[$($DT)] [Language] Set Culture, sets the user culture for the current user account. This is for Region format."
    Set-Culture -CultureInfo $OSDDisplayLanguage
    Write-Host -ForegroundColor Cyan "[$($DT)] [Language] Set-Culture: " -NoNewline
    Write-Host -ForegroundColor Yellow "$($OSDDisplayLanguage)"
}
catch {
    Write-Host -ForegroundColor Red "[$($DT)] [Language] Error setting culture: " -NoNewline
    Write-Host -ForegroundColor Yellow "$_"
}

try {
    Write-Host -ForegroundColor Cyan "[$($DT)] [Language] Set Win Home Location (GeoID), sets the home location setting for the current user. This is for Region location."
    Set-WinHomeLocation -GeoId $OSDGeoID
    Write-Host -ForegroundColor Cyan "[$($DT)] [Language] Set-WinHomeLocation: " -NoNewline
    Write-Host -ForegroundColor Yellow "$($OSDGeoID)"
}
catch {
    Write-Host -ForegroundColor Red "[$($DT)] [Language] Error setting home location: " -NoNewline
    Write-Host -ForegroundColor Yellow "$($_.Exception.Message)"    
}

try {
    Write-Host -ForegroundColor Cyan "[$($DT)] [Language] Copy User International Settings from current user to System, including Welcome screen and new user."
    Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True
    Write-Host -ForegroundColor Cyan "[$($DT)] [Language] Copy-UserInternationalSettingsToSystem: "
} catch {
    Write-Host -ForegroundColor Red "[$($DT)] [Language] Error copying user international settings to system. Error: " -NoNewline
    Write-Host -ForegroundColor Yellow "$($_.Exception.Message)"     
}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Language"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White  "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] DomainJoin
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] DomainJoin"
Write-Host -ForegroundColor DarkBlue $SL

If ($OSDDomainJoin -eq "Yes") {
    Write-Host -ForegroundColor Cyan "[$($DT)] [DomainJoin] Join computer into Active Directory domain"
    Start-Process /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\Computer-DomainJoin.ps1
}
else {
    Write-Host -ForegroundColor Yellow "[$($DT)] [DomainJoin] Computer is Entra ID only"
}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] DomainJoin"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White  "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] Branding
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] Branding"
Write-Host -ForegroundColor DarkBlue $SL

try {
    # Install OneDrive per machine
    $dest = "C:\Windows\Temp\OneDriveSetup.exe"
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Copy OneDrive Setup from $($dest)"

    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Install OneDrive per machine"
    $proc = Start-Process $dest -ArgumentList "/allusers" -WindowStyle Hidden -PassThru
    $proc.WaitForExit()

    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] OneDriveSetup exit code: $($proc.ExitCode)"

    # Install Teams per machine
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Set Registry Keys"
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Changing OneDriveSetup value to point to the machine wide EXE"
    # Quotes are so problematic, we'll use the more risky approach and hope garbage collection cleans it up later
    & reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /f /reg:64 2>&1 | Out-Null
    & reg.exe query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /reg:64 2>&1 | Out-Null
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name OneDriveSetup -Value """C:\Program Files\Microsoft OneDrive\Onedrive.exe"" /background" | Out-Null
    
    $MsixDest = "C:\Windows\Temp\MSTeams-x64.msix"
    $TeamsDest = "C:\Windows\Temp\teamsbootstrapper.exe"
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Install Teams per machine"
    Write-Host -ForegroundColor Green "Install Teams per machine"
    $proc = Start-Process $TeamsDest -ArgumentList "-p -o $MsixDest" -WindowStyle Hidden -PassThru
    $proc.WaitForExit()

    #===================================================================================================================================================
    #  Hide the widgets
    #  This will fail on Windows 11 24H2 due to UCPD, see https://kolbi.cz/blog/2024/04/03/userchoice-protection-driver-ucpd-sys/
    #  New Work Around tested with 24H2 to disable widgets as a preference
    #===================================================================================================================================================
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Hide the widgets"
    $ci = Get-ComputerInfo
    if ($ci.OsBuildNumber -ge 26100) {
        Write-Host -ForegroundColor Yellow "[$($DT)] [Branding] Attempting Widget Hiding workaround (TaskbarDa)"
        $regExePath = (Get-Command reg.exe).Source
        $tempRegExe = "$($env:TEMP)\reg1.exe"
        Copy-Item -Path $regExePath -Destination $tempRegExe -Force -ErrorAction Stop
        & $tempRegExe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f /reg:64 2>&1 | Out-Host
        Remove-Item $tempRegExe -Force -ErrorAction SilentlyContinue
        Write-Host -ForegroundColor Green "[$($DT)] [Branding] Widget Workaround Completed"
    } else {
        Write-Host -ForegroundColor Green "[$($DT)] [Branding] Hiding widgets with registry key"	
        & reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f /reg:64 2>&1 | Out-Host
    }

    #===================================================================================================================================================
    #  Disable Widgets (Grey out Settings Toggle)
    #  GPO settings below will completely disable Widgets, see:https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-newsandinterests#allownewsandinterests
    #===================================================================================================================================================
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Disable Widgets (Grey out Settings Toggle)"
    if (-not (Test-Path "HKLM:\Software\Policies\Microsoft\Dsh")) {
        New-Item -Path "HKLM:\Software\Policies\Microsoft\Dsh" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Dsh"  -Name "DisableWidgetsOnLockScreen" -Value 1
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Dsh"  -Name "DisableWidgetsBoard" -Value 1
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Dsh"  -Name "AllowNewsAndInterests" -Value 0

    #===================================================================================================================================================
    #   Don't let Edge create a desktop shortcut (roams to OneDrive, creates mess)
    #===================================================================================================================================================

    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Turning off (old) Edge desktop shortcut"
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v DisableEdgeDesktopShortcutCreation /t REG_DWORD /d 1 /f /reg:64 | Out-Host
    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "CreateDesktopShortcutDefault" /t REG_DWORD /d 0 /f /reg:64 | Out-Host

    #===================================================================================================================================================
    #   Remove Personal Teams
    #===================================================================================================================================================
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Remove Personal Teams"
    Get-AppxPackage -Name MicrosoftTeams -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue 

    #===================================================================================================================================================
    #   Disable network location fly-out
    #===================================================================================================================================================
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Disable network location fly-out"
    reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" /f

    #===================================================================================================================================================
    #   Stop Start menu from opening on first logon
    #===================================================================================================================================================
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Stop Start menu from opening on first logon"
    reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v StartShownOnUpgrade /t REG_DWORD /d 1 /f | Out-Host

    #===================================================================================================================================================
    #   Hide "Learn more about this picture" from the desktop
    #===================================================================================================================================================
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Hide 'Learn more about this picture' from the desktop"
    reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{2cc5ca98-6485-489a-920e-b3e88a6ccce3}" /t REG_DWORD /d 1 /f | Out-Host

    #===================================================================================================================================================
    #   Disable Windows Spotlight as per https://github.com/mtniehaus/AutopilotBranding/issues/13#issuecomment-2449224828
    #===================================================================================================================================================
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Disable Windows Spotlight"
    reg.exe add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v DisableSpotlightCollectionOnDesktop /t REG_DWORD /d 1 /f | Out-Host

    #===================================================================================================================================================
    #   Remediate Windows Update policy conflict for Autopatch
    #===================================================================================================================================================
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Remediate Windows Update policy conflict for Autopatch"
    # initialize the array
    [PsObject[]]$regkeys = @()
    # populate the array with each object
    $regkeys += [PsObject]@{ Name = "DoNotConnectToWindowsUpdateInternetLocations"; path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"}
    $regkeys += [PsObject]@{ Name = "DisableWindowsUpdateAccess"; path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"}
    $regkeys += [PsObject]@{ Name = "WUServer"; path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"}
    $regkeys += [PsObject]@{ Name = "UseWUServer"; path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\"}
    $regkeys += [PsObject]@{ Name = "NoAutoUpdate"; path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\"}

    foreach ($setting in $regkeys)
    {
        write-host "checking $($setting.name)"
        if((Get-Item $setting.path -ErrorAction Ignore).Property -contains $setting.name)
        {
            write-host "remediating $($setting.name)"
            Remove-ItemProperty -Path $setting.path -Name $($setting.name)
        }
        else
        {
            write-host "$($setting.name) was not found"
        }
    }

    #===================================================================================================================================================
    #   Set registered user and organization
    #===================================================================================================================================================
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Set registered user and organization"
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOwner /t REG_SZ /d "Global IT" /f /reg:64 | Out-Host
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOrganization /t REG_SZ /d "SIGVARIS GROUP" /f /reg:64 | Out-Host

    #===================================================================================================================================================
    #   Configure OEM branding info
    #===================================================================================================================================================
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Configure OEM branding info"
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Manufacturer /t REG_SZ /d "SIGVARIS GROUP" /f /reg:64 | Out-Host
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Model /t REG_SZ /d "Autopilot" /f /reg:64 | Out-Host
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v SupportURL /t REG_SZ /d "https://sigvarisitcustomercare.saasiteu.com/Account/Login?ProviderName=AAD" /f /reg:64 | Out-Host
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Logo /t REG_SZ /d "C:\Windows\sigvaris.bmp" /f /reg:64 | Out-Host

    #===================================================================================================================================================
    #    Disable extra APv2 pages (too late to do anything about the EULA), see https://call4cloud.nl/autopilot-device-preparation-hide-privacy-settings/
    #===================================================================================================================================================
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Disable extra APv2 pages (too late to do anything about the EULA)"
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE"
    New-ItemProperty -Path $registryPath -Name "DisablePrivacyExperience" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "DisableVoice" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "PrivacyConsentStatus" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "ProtectYourPC" -Value 3 -PropertyType DWord -Force | Out-Null

    #===================================================================================================================================================
    #    Skip FSIA and turn off delayed desktop switch
    #===================================================================================================================================================
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Skip FSIA and turn off delayed desktop switch"
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    New-ItemProperty -Path $registryPath -Name "EnableFirstLogonAnimation" -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "DelayedDesktopSwitch" -Value 0 -PropertyType DWord -Force | Out-Null

    #===================================================================================================================================================
    #    Enable .NET Framework 3.5 for US, CA
    #===================================================================================================================================================
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Enable .NET Framework 3.5 for US, CA"
    $DeviceName = $env:COMPUTERNAME.Substring(0,6)
    Switch ($DeviceName) {
        'SICAMO' {Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -NoRestart;break}
        'SIUSGA' {Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -NoRestart;break}
        'SIUSMI' {Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -NoRestart;break}
    }

    #===================================================================================================================================================
    #    Enable Printing-PrintToPDFServices-Features because of KB5058411
    #    https://support.microsoft.com/en-us/topic/may-13-2025-kb5058411-os-build-26100-4061-356568c2-c730-469e-819d-b680d43b1265
    #===================================================================================================================================================
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Enable Printing-PrintToPDFServices-Features because of KB5058411"
    Disable-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features -NoRestart -ErrorAction SilentlyContinue
    Enable-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features -NoRestart -ErrorAction SilentlyContinue

    #===================================================================================================================================================
    #    Remove OSDCloudRegistration Certificate
    #===================================================================================================================================================
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Remove Import-Certificate.ps1 script"
    if (Test-Path -Path $env:SystemDrive\OSDCloud\Scripts\Import-Certificate.ps1) {
        Remove-Item -Path $env:SystemDrive\OSDCloud\Scripts\Import-Certificate.ps1 -Force
    }

    #===================================================================================================================================================
    #    Remove C:\Windows\Setup\Scripts\ Items
    #===================================================================================================================================================
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Remove C:\Windows\Setup\Scripts Items"
    Remove-Item C:\Windows\Setup\Scripts\*.* -Exclude *.TAG -Force | Out-Null

    #===================================================================================================================================================
    #    Copy OSDCloud logs and delete C:\OSDCloud folder
    #===================================================================================================================================================
    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Copy OSDCloud logs and delete C:\OSDCloud folder"
    Copy-Item -Path "C:\OSDCloud\Logs\*" -Destination "C:\ProgramData\OSDeploy" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    Remove-Item C:\OSDCloud -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item C:\ProgramData\OSDeploy\WiFi -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

    Write-Host -ForegroundColor Cyan "[$($DT)] [Branding] Set Computername to $($OSDComputername)"
    Rename-Computer -NewName $OSDComputername

    # Exit code Soft Reboot
    Exit 3010
} 
catch [System.Exception] {
    Write-Host -ForegroundColor Red "[$($DT)] [Forescout] Branding failed with error: " -NoNewline
    Write-Host -ForegroundColor Yellow "$($_.Exception.Message)"
}    


$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Branding"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White  "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# End Script
# ================================================================================================================================================~
$EndTime = Get-Date
$ExecutionTime = $EndTime - $StartTime

Write-Host -ForegroundColor Green "[$($DT)] [End] Script ended $($EndTime)"
Write-Host -ForegroundColor Green "[$($DT)] [End] Script took $($ExecutionTime.Minutes) minutes to execute"

Stop-Transcript | Out-Null