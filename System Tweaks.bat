@echo off
setlocal enabledelayedexpansion

:: ================================================================================
:: SELF-ELEVATION: Automatically Re-run as Administrator
:: ================================================================================
NET SESSION >nul 2>&1
if %errorLevel% neq 0 (
    echo [PROMPT] Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Set Date Variable
for /f "tokens=2-4 delims=/ " %%a in ('echo %date%') do set "curr_date=%%a-%%b-%%c"

echo ================================================================================
echo   ____           _                     _____                      _        
echo  / ___| _   _ ___| |_ ___ _ __ ___     |_   _|_      _____  __ _| |rc ___ 
echo  \___ \| | | / __| __/ _ \ '_ ` _ \ _____| | \ \ /\ / / _ \/ _` | |/ / __^|
echo   ___) | |_| \__ \ ||  __/ | | | | |_____| |  \ V  V /  __/ (_| |   <\__ \
echo  |____/ \__, |___/\__\___|_| |_| |_|     |_|   \_/\_/ \___|\__,_|_|\_\___/
echo         |___/                                                v.03-15-2026
echo ================================================================================
echo                          SYSTEM AND GPU OPTIMIZER
echo ================================================================================
echo  CREDITS:
echo  - Windows Utility by Chris Titus Tech (christitus.com)
echo  - Just the Browser by Corbin Davenport (://github.com)
echo  - Developed by Trigger911
echo  - https://github.com/Trigger911/Batch-System-Optimizer
echo ================================================================================

:: 1. Create Restore Point
echo [1/14] Creating System Restore Point: System Optimizer %curr_date%...
powershell -Command "Checkpoint-Computer -Description 'System Optimizer %curr_date%' -RestorePointType 'MODIFY_SETTINGS'" >nul 2>&1

:: 2. Chris Titus Debloat Integration
echo [2/14] Launching Chris Titus Utility in a NEW window...
start powershell -NoExit -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; irm https://christitus.com | iex"

echo.
echo [3/14] Resetting Network Stack...
netsh winsock reset >nul
netsh int ip reset >nul
netsh interface teredo set state default >nul

:: 4. Applying Timer Tweaks
echo [4/14] Applying Timer Tweaks ^(HPET ^& Dynamic Tick^)...
bcdedit /set useplatformclock no >nul 2>&1
bcdedit /set disabledynamictick yes >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice -FriendlyName 'High precision event timer' -ErrorAction SilentlyContinue | Disable-PnpDevice -Confirm:$false" >nul 2>&1

echo [5/14] Disabling Network and USB Power Saving...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-NetAdapter | Disable-NetAdapterPowerManagement -NoRestart -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance -ClassName MSPower_DeviceEnable -Namespace root/WMI | Where-Object { $_.InstanceName -match 'USB|PCI' } | Set-CimInstance -Property @{Enable = $false} -ErrorAction SilentlyContinue" >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Services\USB" /v "DisableSelectiveSuspend" /t REG_DWORD /d 1 /f >nul 2>&1

echo [6/14] Forcing High-Performance GPU Mode...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PowerSavingsDisabled" /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\DirectX" /v "UserGpuPreference" /t REG_DWORD /d 2 /f >nul

echo [7/14] Tweaking CPU Priority for Games...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xffffffff /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul

echo [8/14] Refining Mouse and Keyboard Response...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 22 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d 20 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d 20 /f >nul

echo [9/14] Smart RAM Optimization...
for /f "tokens=2 delims==" %%a in ('wmic computersystem get TotalPhysicalMemory /value') do set "RAM_BYTES=%%a"
set /a RAM_GB=!RAM_BYTES:~0,-10!
if !RAM_GB! GEQ 15 (
    echo    -- Detected !RAM_GB!GB RAM: Optimizing MMAgent and SvcHost...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Disable-MMAgent -mc" >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d 16777216 /f >nul
)

echo [10/14] Purging Extended Bloatware...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$apps = @('*BingWeather*', '*Spotify*', '*Zune*', '*Xbox*', '*Microsoft.MixedReality*', '*QuickAssist*', '*WindowsFeedbackHub*', '*Copilot*', '*MicrosoftFamily*', '*MicrosoftOfficeHub*', '*BingSearch*', '*Clipchamp*', '*MSTeams*', '*Todos*', '*StickyNotes*', '*BingNews*', '*OutlookForWindows*', '*WindowsAlarms*', '*SolitaireCollection*'); foreach ($app in $apps) { Get-AppxPackage -AllUsers $app | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like $app } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue }" >nul 2>&1

:: 10b. Optional "Just the Browser" Tweak
echo.
set /p browser_choice="Apply 'Just the Browser' (Stripped down Chrome/Edge/Firefox)? (Y/N): "
if /i "%browser_choice%"=="Y" (
    echo    -- Running Corbin Davenport's Just the Browser script...
    start /wait powershell -NoExit -NoProfile -ExecutionPolicy Bypass -Command "irm https://justthebrowser.com | iex"
)

echo.
echo [11/14] Running Network Speed ^& Latency Optimizer...
netsh int tcp set global autotuninglevel=normal >nul
netsh int tcp set global chimney=enabled >nul
netsh int tcp set global dca=enabled >nul
netsh int tcp set global netdma=enabled >nul
netsh int tcp set global ecncapability=enabled >nul
netsh int tcp set global timestamps=disabled >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-NetAdapter | Set-NetAdapterPowerManagement -AllowComputerToTurnOffDevice Disabled" >nul 2>&1
powershell -Command "Get-NetAdapterAdvancedProperty -DisplayName '*Energy Efficient Ethernet*' | Set-NetAdapterAdvancedProperty -RegistryValue '0'" >nul 2>&1
powershell -Command "Get-NetAdapterAdvancedProperty -DisplayName '*Green Ethernet*' | Set-NetAdapterAdvancedProperty -RegistryValue '0'" >nul 2>&1
powershell -Command "Get-NetAdapterAdvancedProperty -DisplayName '*Interrupt Moderation*' | Set-NetAdapterAdvancedProperty -RegistryValue '0'" >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DODownloadMode" /t REG_DWORD /d 0 /f >nul
echo.
set /p userdns="Would you like to change DNS to Cloudflare (Primary) ^& Google (Secondary)? (Y/N): "
if /i "%userdns%"=="Y" (
    echo    -- Setting DNS to 1.1.1.1 and 8.8.8.8...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Set-DnsClientServerAddress -ServerAddresses ('1.1.1.1', '8.8.8.8')"
    ipconfig /flushdns >nul
)

echo.
echo [12/14] Cleaning Temporary Files and System Cache...
del /q /f /s %TEMP%\* >nul 2>&1
del /q /f /s C:\Windows\Temp\* >nul 2>&1
del /q /f /s C:\Windows\Prefetch\* >nul 2>&1

echo [13/14] Applying Extreme Latency Tweaks (VBS/Hibernate)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d 0 /f >nul 2>&1
bcdedit /set hypervisorlaunchtype off >nul 2>&1
powercfg -h off >nul 2>&1

echo [14/14] Finalizing Optimization...
ipconfig /flushdns >nul

echo.
echo ================================================================================
echo                  SUCCESS: Hardware optimized by Trigger911.
echo ================================================================================
set /p choice="Optimization complete. Would you like to RESTART now? (Y/N): "
if /i "%choice%"=="Y" shutdown /r /t 5
if /i "%choice%"=="N" echo Please remember to restart manually. & pause
exit
