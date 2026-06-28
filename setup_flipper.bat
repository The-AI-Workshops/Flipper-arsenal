@echo off
setlocal EnableDelayedExpansion

echo ============================================
echo  Flipper Zero SD Card Setup
echo ============================================
echo.

:: ---- CONFIG: set your SD card drive letter ----
set FLIPPER=E:
set REPO_DIR=%USERPROFILE%\Documents\Flipper
set REPO_URL=https://github.com/UberGuidoZ/Flipper
:: -----------------------------------------------

:: Check/install Git
echo [1/4] Checking for Git...
git --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Git not found. Downloading installer...
    curl -L -o "%TEMP%\git_installer.exe" "https://github.com/git-for-windows/git/releases/latest/download/Git-2.45.2-64-bit.exe"
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Download failed. Check internet connection.
        pause & exit /b 1
    )
    echo Installing Git silently...
    "%TEMP%\git_installer.exe" /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS
    :: Refresh PATH
    set "PATH=%PATH%;C:\Program Files\Git\cmd"
    git --version >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Git install failed. Install manually from https://git-scm.com
        pause & exit /b 1
    )
    echo Git installed OK.
) else (
    echo Git found.
)

:: Clone repo
echo.
echo [2/4] Cloning repo to %REPO_DIR%...
if exist "%REPO_DIR%\.git" (
    echo Repo already exists. Pulling latest...
    git -C "%REPO_DIR%" pull
) else (
    git clone "%REPO_URL%" "%REPO_DIR%"
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Clone failed. Check internet connection.
        pause & exit /b 1
    )
)

:: Verify SD card
echo.
echo [3/4] Checking Flipper SD at %FLIPPER%...
if not exist "%FLIPPER%\" (
    echo.
    echo ERROR: Drive %FLIPPER% not found.
    echo.
    echo Make sure:
    echo   1. Flipper is connected via USB
    echo   2. Go to Settings ^> USB ^> Mass Storage on Flipper
    echo   3. Update FLIPPER drive letter in this script if needed
    echo.
    pause & exit /b 1
)

:: Copy files
echo.
echo [4/4] Copying files to Flipper SD...

:: Create target folders
for %%F in (infrared subghz nfc lfrfid badusb music_player wav_player apps dolphin) do (
    if not exist "%FLIPPER%\%%F\" mkdir "%FLIPPER%\%%F"
)

xcopy "%REPO_DIR%\Infrared\*"     "%FLIPPER%\infrared\"    /E /I /Y /Q
xcopy "%REPO_DIR%\Sub-GHz\*"      "%FLIPPER%\subghz\"      /E /I /Y /Q
xcopy "%REPO_DIR%\NFC\*"          "%FLIPPER%\nfc\"          /E /I /Y /Q
xcopy "%REPO_DIR%\RFID\*"         "%FLIPPER%\lfrfid\"       /E /I /Y /Q
xcopy "%REPO_DIR%\BadUSB\*"       "%FLIPPER%\badusb\"       /E /I /Y /Q
xcopy "%REPO_DIR%\Music_Player\*" "%FLIPPER%\music_player\" /E /I /Y /Q
xcopy "%REPO_DIR%\Wav_Player\*"   "%FLIPPER%\wav_player\"   /E /I /Y /Q
xcopy "%REPO_DIR%\Graphics\*"     "%FLIPPER%\dolphin\"      /E /I /Y /Q
xcopy "%REPO_DIR%\Dolphin_Level\*""%FLIPPER%\dolphin\"      /E /I /Y /Q

echo.
echo ============================================
echo  Done!
echo  Safely eject %FLIPPER% in File Explorer
echo  then press Back on your Flipper to rescan.
echo ============================================
echo.
pause
