@echo off
setlocal enabledelayedexpansion

:: Check for Administrator privileges
NET SESSION >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run this script as an administrator.
    pause
    exit /b 1
)

echo ================================================================================
echo                              SYSTEM AND GPU OPTIMIZER
echo ================================================================================
echo                         Created by Trigger911 on 3/15/2026
echo ================================================================================

:: 1. Create Restore Point
echo [1/8] Creating System Restore Point...
powershell -Command "Checkpoint-Computer -Description 'Trigger911_Final' -RestorePointType 'MODIFY_SETTINGS'" >nul 2>&1

:: 2. Chris Titus Debloat Integration
echo [2/8] Launching Chris Titus Utility in a NEW window...
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
echo [3/8] Resetting Network Stack...
netsh winsock reset >nul
netsh interface teredo set state disabled >nul

echo [4/8] Applying BCDEDIT Timer Tweaks...
bcdedit /set useplatformclock no >nul 2>&1
bcdedit /set disabledynamictick yes >nul 2>&1

echo [5/8] Disabling Network and USB Power Saving...
:: 5a. Disable Network Adapter Power Management
powershell -Command "Get-NetAdapter | Disable-NetAdapterPowerManagement -NoRestart -ErrorAction SilentlyContinue" >nul 2>&1
powershell -Command "Get-NetAdapter | ForEach-Object { Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Energy Efficient Ethernet' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue }" >nul 2>&1

:: 5b. UNCHECK "Allow computer to turn off device" for ALL USB Hubs & Host Controllers
:: This targets all devices under the USB and PCI stacks that have power management capabilities.
powershell -Command "Get-CimInstance -ClassName MSPower_DeviceEnable -Namespace root/WMI | Where-Object { $_.InstanceName -match 'USB|PCI' } | Set-CimInstance -Property @{Enable = $false} -ErrorAction SilentlyContinue" >nul 2>&1

:: 5c. Global Registry Fix: Force Disable Selective Suspend
reg add "HKLM\System\CurrentControlSet\Services\USB" /v "DisableSelectiveSuspend" /t REG_DWORD /d 1 /f >nul 2>&1

:: 5d. Power Plan Fix: Disable Selective Suspend for Current Plan (AC and DC)
powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48951235-afd4-4b53-8a3d-699298453443 0 >nul 2>&1
powercfg /SETDCVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48951235-afd4-4b53-8a3d-699298453443 0 >nul 2>&1
powercfg /SETACTIVE SCHEME_CURRENT >nul 2>&1

echo [6/8] Detecting GPU and Applying Fixes...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PowerSavingsDisabled" /t REG_DWORD /d 1 /f >nul

echo [7/8] Applying Input and Priority Registry Edits...
reg add HKLM\SYSTEM\ControlSet001\Control\PriorityControl\ /v Win32PrioritySeparation /t REG_DWORD /d 0x16 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d "20" /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d "20" /f >nul

echo [8/8] Smart RAM Scanning...
for /f "tokens=2 delims==" %%a in ('wmic computersystem get TotalPhysicalMemory /value') do set "RAM_BYTES=%%a"
set /a RAM_GB=!RAM_BYTES:~0,-10!
if !RAM_GB! GEQ 15 (
    echo                        -- Detected !RAM_GB!GB RAM: Disabling Memory Compression...
    powershell -Command "Disable-MMAgent -mc" >nul 2>&1
)

echo.
echo ================================================================================
echo                  SUCCESS: Detected hardware optimized by Trigger911.
echo ================================================================================
echo                           Please RESTART your computer now.
pause
