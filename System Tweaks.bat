@echo off
setlocal enabledelayedexpansion

:: Check for Administrator privileges
NET SESSION >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run this script as an administrator.
    pause
    exit /b 1
)

:: Set Date Variable for Restore Point naming
for /f "tokens=2-4 delims=/ " %%a in ('echo %date%') do set "curr_date=%%a-%%b-%%c"

echo ================================================================================
echo                     AUTO-DETECTING SYSTEM AND GPU OPTIMIZER
echo ================================================================================
echo                         Created by Trigger911 on 03-15-2026
echo ================================================================================

:: 1. Create Restore Point
echo [1/12] Creating System Restore Point: System Optimizer %curr_date%...
powershell -Command "Checkpoint-Computer -Description 'System Optimizer %curr_date%' -RestorePointType 'MODIFY_SETTINGS'" >nul 2>&1

:: 2. Chris Titus Debloat Integration
echo [2/12] Launching Chris Titus Utility...
set "PS_TEMP=%TEMP%\titus_run.ps1"
(
echo $Tweaks = @('WPFTweaksRestorePoint','WPFTweaksWifi','WPFTweaksRightClickMenu','WPFTweaksDebloatAdobe','WPFTweaksStorage','WPFTweaksHiber','WPFTweaksConsumerFeatures','WPFTweaksDVR','WPFTweaksDisableFSO','WPFTweaksTele','WPFTweaksAH','WPFTweaksEndTaskOnTaskbar','WPFTweaksBlockAdobeNet','WPFTweaksEdgeDebloat','WPFTweaksRemoveCopilot','WPFTweaksDiskCleanup','WPFTweaksHome','WPFTweaksDisableExplorerAutoDiscovery','WPFTweaksPowershell7Tele','WPFTweaksDeleteTempFiles','WPFTweaksDisableBGapps','WPFTweaksServices'^)
echo $Features = @('WPFFeatureslegacymedia','WPFFeatureEnableLegacyRecovery','WPFFeaturesdotnet'^)
echo irm "https://christitus.com" ^| iex
echo Invoke-WPFTweaks -Tweaks $Tweaks -Features $Features
) > "%PS_TEMP%"
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%PS_TEMP%\"' -Verb RunAs -Wait"
if exist "%PS_TEMP%" del "%PS_TEMP%"

echo.
echo [3/12] Resetting Network Stack and Disabling Teredo...
netsh winsock reset >nul
netsh int ip reset >nul
netsh interface teredo set state disabled >nul

echo [4/12] Applying BCDEDIT Timer Tweaks (Lower Latency)...
bcdedit /set useplatformclock no >nul 2>&1
bcdedit /set disabledynamictick yes >nul 2>&1

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

echo [10/12] Purging AI and Extended Bloatware List...
:: Comprehensive removal of requested apps and their provisioned installers
powershell -Command "$apps = @('*BingWeather*', '*Spotify*', '*Zune*', '*Xbox*', '*Microsoft.MixedReality*', '*QuickAssist*', '*WindowsFeedbackHub*', '*Copilot*', '*MicrosoftFamily*', '*MicrosoftOfficeHub*', '*BingSearch*', '*Clipchamp*', '*MSTeams*', '*Todos*', '*StickyNotes*', '*BingNews*', '*OutlookForWindows*', '*WindowsAlarms*', '*SolitaireCollection*'); foreach ($app in $apps) { Get-AppxPackage -AllUsers $app | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like $app } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue }" >nul 2>&1
:: Run zoicware Windows AI Removal
powershell -Command "& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com')))" >nul 2>&1

echo [11/12] Cleaning Temporary Files and System Cache...
del /q /f /s %TEMP%\* >nul 2>&1
del /q /f /s C:\Windows\Temp\* >nul 2>&1
del /q /f /s C:\Windows\Prefetch\* >nul 2>&1

echo [12/12] Applying Handheld Performance Tweaks (VBS/Hibernate)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d 0 /f >nul 2>&1
bcdedit /set hypervisorlaunchtype off >nul 2>&1
powercfg -h off >nul 2>&1

echo.
echo ================================================================================
echo                  SUCCESS: Hardware optimized by Trigger911.
echo ================================================================================
set /p choice="Optimization complete. Would you like to RESTART now? (Y/N): "
if /i "%choice%"=="Y" shutdown /r /t 5
if /i "%choice%"=="N" echo Please remember to restart manually. & pause
exit
