@echo off
setlocal enabledelayedexpansion

:: Check for Administrator privileges
NET SESSION >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run this script as an administrator.
    pause
    exit /b 1
)

:: Set Date Variable
for /f "tokens=2-4 delims=/ " %%a in ('echo %date%') do set "curr_date=%%a-%%b-%%c"

echo ================================================================================
echo                     AUTO-DETECTING SYSTEM AND GPU OPTIMIZER
echo ================================================================================
echo                         Created by Trigger911 on 03-15-2026
echo ================================================================================
echo  CREDITS:
echo  - Windows Utility by Chris Titus Tech (christitus.com)
echo  - Just the Browser by Corbin Davenport (://github.com)
echo ================================================================================

:: 1. Create Restore Point
echo [1/12] Creating System Restore Point: System Optimizer %curr_date%...
powershell -Command "Checkpoint-Computer -Description 'System Optimizer %curr_date%' -RestorePointType 'MODIFY_SETTINGS'" >nul 2>&1

:: 2. Chris Titus Debloat Integration (Forced TLS 1.2 & Fallback)
echo [2/12] Launching Chris Titus Utility...
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; try { irm https://christitus.com | iex } catch { irm https://github.com | iex }"

echo.
echo [3/12] Resetting Network Stack and Disabling Teredo...
netsh winsock reset >nul
netsh int ip reset >nul
netsh interface teredo set state disabled >nul

echo [4/12] Applying Timer Tweaks (HPET & Dynamic Tick)...
bcdedit /set useplatformclock no >nul 2>&1
bcdedit /set disabledynamictick yes >nul 2>&1
powershell -Command "Get-PnpDevice -FriendlyName 'High precision event timer' -ErrorAction SilentlyContinue | Disable-PnpDevice -Confirm:$false" >nul 2>&1

echo [5/12] Disabling Network and USB Power Saving...
powershell -Command "Get-NetAdapter | Disable-NetAdapterPowerManagement -NoRestart -ErrorAction SilentlyContinue" >nul 2>&1
powershell -Command "Get-CimInstance -ClassName MSPower_DeviceEnable -Namespace root/WMI | Where-Object { $_.InstanceName -match 'USB|PCI' } | Set-CimInstance -Property @{Enable = $false} -ErrorAction SilentlyContinue" >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Services\USB" /v "DisableSelectiveSuspend" /t REG_DWORD /d 1 /f >nul 2>&1

echo [6/12] Forcing High-Performance GPU Mode...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PowerSavingsDisabled" /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\DirectX" /v "UserGpuPreference" /t REG_DWORD /d 2 /f >nul

echo [7/12] Tweaking CPU Priority for Games...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xffffffff /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul

echo [8/12] Refining Mouse and Keyboard Response...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 22 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d 20 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d 20 /f >nul

echo [9/12] Smart RAM Optimization...
for /f "tokens=2 delims==" %%a in ('wmic computersystem get TotalPhysicalMemory /value') do set "RAM_BYTES=%%a"
set /a RAM_GB=!RAM_BYTES:~0,-10!
if !RAM_GB! GEQ 15 (
    echo    -- Detected !RAM_GB!GB RAM: Optimizing MMAgent and SvcHost...
    powershell -Command "Disable-MMAgent -mc" >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d 16777216 /f >nul
)

echo [10/12] Purging Extended Bloatware...
powershell -Command "$apps = @('*BingWeather*', '*Spotify*', '*Zune*', '*Xbox*', '*Microsoft.MixedReality*', '*QuickAssist*', '*WindowsFeedbackHub*', '*Copilot*', '*MicrosoftFamily*', '*MicrosoftOfficeHub*', '*BingSearch*', '*Clipchamp*', '*MSTeams*', '*Todos*', '*StickyNotes*', '*BingNews*', '*OutlookForWindows*', '*WindowsAlarms*', '*SolitaireCollection*'); foreach ($app in $apps) { Get-AppxPackage -AllUsers $app | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like $app } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue }" >nul 2>&1

:: 10b. Optional "Just the Browser" Tweak
echo.
set /p browser_choice="Apply 'Just the Browser' (Stripped down Chrome/Edge/Firefox)? (Y/N): "
if /i "%browser_choice%"=="Y" (
    echo    -- Running Corbin Davenport's Just the Browser script...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com')))"
)

echo.
echo [11/12] Cleaning Temporary Files and System Cache...
del /q /f /s %TEMP%\* >nul 2>&1
del /q /f /s C:\Windows\Temp\* >nul 2>&1
del /q /f /s C:\Windows\Prefetch\* >nul 2>&1

echo [12/12] Applying Extreme Latency Tweaks (VBS/Hibernate)...
:: Disabling VBS/Core Isolation (Significant FPS/Latency gain for ALL PCs)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d 0 /f >nul 2>&1
bcdedit /set hypervisorlaunchtype off >nul 2>&1
:: Disabling Hibernate (Frees SSD space and stops background task overhead)
powercfg -h off >nul 2>&1

echo.
echo ================================================================================
echo                  SUCCESS: Hardware optimized by Trigger911.
echo ================================================================================
set /p choice="Optimization complete. Would you like to RESTART now? (Y/N): "
if /i "%choice%"=="Y" shutdown /r /t 5
if /i "%choice%"=="N" echo Please remember to restart manually. & pause
exit
