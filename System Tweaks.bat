@echo off
setlocal enabledelayedexpansion

:: ================================================================================
:: LOGGING SETUP
:: ================================================================================
set "LOGFILE=%~dp0Optimizer_Log.txt"
echo =============================================================== >> "%LOGFILE%"
echo Run Date: %date% %time% >> "%LOGFILE%"
echo =============================================================== >> "%LOGFILE%"

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

title Batch System Optimizer - System Tweaks
color 0b

echo ================================================================================
echo                          SYSTEM AND GPU OPTIMIZER
echo ================================================================================
echo CREDITS ^& CONTRIBUTIONS:
echo - Maintained ^& Developed by: Trigger911
echo - Official Repository: https://github.com
echo.
echo - Windows Utility: Chris Titus Tech (christitus.com)
echo - Browser Debloat Concept: Corbin Davenport (justthebrowser.com)
echo - Latency ^& Network Logic: Community Optimization Standards
echo ================================================================================

:: 1 Restore Point
echo [1/16] Creating System Restore Point...
powershell -Command "Checkpoint-Computer -Description 'System Optimizer %curr_date%' -RestorePointType 'MODIFY_SETTINGS'" >nul 2>&1
echo Restore Point Created >> "%LOGFILE%"

:: 2 Chris Titus (Official Tool)
echo [2/16] Launching Chris Titus Utility...
start powershell -NoExit -ExecutionPolicy Bypass -Command "irm 'https://christitus.com' | iex"
echo Chris Titus Utility Launched >> "%LOGFILE%"

:: 3 Network Reset
echo [3/16] Resetting Network Stack...
netsh winsock reset >nul
netsh int ip reset >nul
netsh interface teredo set state default >nul
echo Network Reset Completed >> "%LOGFILE%"

:: 4 Timer Tweaks
echo [4/16] Applying Timer Tweaks...
bcdedit /set useplatformclock no >nul 2>&1
bcdedit /set disabledynamictick yes >nul 2>&1
powershell -Command "Get-PnpDevice -FriendlyName 'High precision event timer' -ErrorAction SilentlyContinue | Disable-PnpDevice -Confirm:$false" >nul 2>&1
echo Timer Tweaks Applied >> "%LOGFILE%"

:: 5 USB Power
echo [5/16] Disabling USB Power Saving...
powershell -Command "Get-NetAdapter | Disable-NetAdapterPowerManagement -NoRestart -ErrorAction SilentlyContinue" >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Services\USB" /v "DisableSelectiveSuspend" /t REG_DWORD /d 1 /f >nul 2>&1
echo USB Tweaks Applied >> "%LOGFILE%"

:: 6 GPU Mode
echo [6/16] Forcing High-Performance GPU Mode...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PowerSavingsDisabled" /t REG_DWORD /d 1 /f >nul
echo GPU Tweaks Applied >> "%LOGFILE%"

:: 7 CPU Game Tweaks
echo [7/16] Tweaking CPU Priority ^& Throttling...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xffffffff /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul
echo CPU Tweaks Applied >> "%LOGFILE%"

:: 8 Mouse Keyboard
echo [8/16] Refining Input Response...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 22 /f >nul
echo Input Tweaks Applied >> "%LOGFILE%"

:: 9 RAM (Fixed for your 96GB)
echo [9/16] Smart RAM Optimization...
for /f %%a in ('powershell -command "[math]::round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)"') do set "RAM_GB=%%a"
if %RAM_GB% GEQ 15 (
    echo -- Detected %RAM_GB%GB RAM: Optimizing MMAgent and SvcHost...
    powershell -Command "Disable-MMAgent -mc" >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d 100663296 /f >nul
)
echo RAM Optimization Checked >> "%LOGFILE%"

:: 10 Bloatware
echo [10/16] Removing Bloatware...
powershell -Command "Get-AppxPackage -AllUsers *Xbox* | Remove-AppxPackage -AllUsers" >nul 2>&1
echo Bloat Removal Complete >> "%LOGFILE%"

:: 11 Network Optimizer
echo [11/16] Network Optimization...
netsh int tcp set global autotuninglevel=normal >nul
netsh int tcp set global chimney=enabled >nul
netsh int tcp set global rss=enabled >nul
echo Network Optimized >> "%LOGFILE%"

:: 12 Advanced Adapter Tweaks (Nagle's Algorithm)
echo [12/16] Advanced Adapter Tweaks...
for /f "tokens=*" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"') do (
    reg add "%%i" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "%%i" /v "TCPNoDelay" /t REG_DWORD /d 1 /f >nul 2>&1
)
echo Adapter Tweaks Applied >> "%LOGFILE%"

:: 13 Temp Cleanup
echo [13/16] Cleaning Temporary Files...
del /q /f /s %TEMP%\* >nul 2>&1
echo Temp Cleanup Complete >> "%LOGFILE%"

:: 14 Extreme Latency Tweaks
echo [14/16] Disabling VBS ^& Hypervisor...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d 0 /f >nul 2>&1
bcdedit /set hypervisorlaunchtype off >nul 2>&1
echo VBS Disabled >> "%LOGFILE%"

:: 15 Location Services Prompt
echo.
set /p locchoice="Do you require Location Services (Weather, Outlook, etc.)? (Y/N): "
if /i "%locchoice%"=="N" (
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d 1 /f >nul 2>&1
    echo Location Disabled >> "%LOGFILE%"
)

:: 16 Generate Restore Script
echo [16/16] Creating Restore_Defaults.bat...
(
echo @echo off
echo echo Restoring Windows Defaults...
echo bcdedit /set hypervisorlaunchtype auto
echo powercfg -h on
echo reg delete "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /f
echo reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /f
echo powercfg /setactive SCHEME_BALANCED
echo echo Defaults Restored. Please Restart.
echo pause
) > "%~dp0Restore_Defaults.bat"
echo Restore Script Created >> "%LOGFILE%"

echo.
echo ================================================================================
echo SUCCESS: Hardware optimized by Trigger911 ^& Contributors.
echo ================================================================================
set /p choice="Optimization complete. Would you like to RESTART now? (Y/N): "
if /i "%choice%"=="Y" shutdown /r /t 5
if /i "%choice%"=="N" echo Please remember to restart manually. & pause
exit
