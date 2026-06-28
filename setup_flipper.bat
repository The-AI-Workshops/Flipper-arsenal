@echo off
:: Flipper Arsenal — Windows Setup Launcher
:: Double-click to run. PowerShell handles the rest.

echo.
echo  Flipper Arsenal Setup
echo  =====================
echo.

powershell -Command "exit 0" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PowerShell not found. Required on Windows 7+.
    pause & exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup_flipper.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Setup failed or was cancelled.
    pause
)
