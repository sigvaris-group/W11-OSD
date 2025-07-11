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
# [SECTION] Load UIjson.json file
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

Write-Host -ForegroundColor Cyan "[$($DT)] [UI] Set Computername to $($OSDComputername)"
Rename-Computer -NewName $OSDComputername

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] UI"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White   "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] Install Forescout Secure Connect
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] Forescout Secure Connect"
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
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Forescout Secure Connect"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White   "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] Import Wi-Fi profiles
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] Import Wi-Fi profiles"
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
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Import Wi-Fi profiles"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White   "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] Check Internet Connection
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] Check Internet Connection"
Write-Host -ForegroundColor DarkBlue $SL

$CheckDomain = 'techcommunity.microsoft.com'
$CheckIP = '23.63.114.210'
Write-Host -ForegroundColor Cyan "[$($DT)] [Network] Check Internet Connection: $($CheckDomain)"

$ping = Test-NetConnection $CheckDomain -Hops 4
$port = Test-NetConnection $CheckIP -Port 443 -InformationLevel Detailed
if ($ping.PingSucceeded -eq $false -or $port.TcpTestSucceeded -eq $false) {
    Write-Host -ForegroundColor Yellow "[$($DT)] [Network] No Internet Connection. Start Wi-Fi setup."  
    Start-Process -FilePath C:\Windows\WirelessConnect.exe -Wait
    start-Sleep -Seconds 10 
}

$IPConfig = Get-NetIPConfiguration
Write-Host -ForegroundColor Cyan "[$($DT)] [Network] Get-NetIPConfiguration"
Write-Output $IPConfig

$ping = Test-NetConnection $CheckDomain
if ($ping.PingSucceeded -eq $false) {
    Write-Host -ForegroundColor Red "[$($DT)] [Network] No Internet Connection" 
    Write-Host -ForegroundColor Red "[$($DT)] [Network] OS Installation canceled"

    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup("Verify if the device has Internet Connection and restart the installation",0,"OS INSTALLATION CANCELED","16")
    Exit 1
}
else {
    Write-Host -ForegroundColor Green "[$($DT)] [Network] Successfull connected to Internet"      
}

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Check Internet Connection"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White  "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] Register Device in Autopilot
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] Register Device in Autopilot"
Write-Host -ForegroundColor DarkBlue $SL

Write-Host -ForegroundColor Cyan "[$($DT)] [Autopilot] Start Autopilot registration"
Start-Process /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\scripts\W11_Autopilot.ps1

$SectionEndTime = Get-Date
$ExecutionTime = $SectionEndTime - $SectionStartTime
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Register Device in Autopilot"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White  "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] Windows Updates
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] Windows Updates"
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
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Windows Updates"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White  "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] Install Language Packs
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] Install Language Packs"
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
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Install Language Packs"
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Script took " -NoNewline
Write-Host -ForegroundColor White  "$($ExecutionTime.Minutes) " -NoNewline
Write-Host -ForegroundColor Blue  "minutes to execute."
Write-Host -ForegroundColor DarkBlue $SL

# ================================================================================================================================================~
# [SECTION] Domain Join
# ================================================================================================================================================~
$SectionStartTime = Get-Date
Write-Host -ForegroundColor DarkBlue $SL
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-Start] Domain Join"
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
Write-Host -ForegroundColor Blue "[$($DT)] [SECTION-End] Domain Join"
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