# Flipper Arsenal - Windows Setup Script
# Requires: Windows 10/11, PowerShell 5+
# Usage: Double-click setup_flipper.bat OR run directly in PowerShell

# Ctrl+C exits cleanly at any point
try { [Console]::TreatControlCAsInput = $false } catch {}
$ErrorActionPreference = "Stop"
trap {
    Write-Host ""
    Write-Host "  Setup cancelled." -ForegroundColor Yellow
    exit 0
}

$ARSENAL_URL  = "https://github.com/The-AI-Workshops/Flipper-arsenal.git"
$UBER_URL     = "https://github.com/UberGuidoZ/Flipper.git"
$ARSENAL_DIR  = "$env:USERPROFILE\Documents\Flipper-arsenal"
$UBER_DIR     = "$env:USERPROFILE\Documents\Flipper-arsenal\_UberGuidoZ"
$QFLIPPER_URL = "https://update.flipperzero.one/builds/qFlipper/release/qFlipper-windows-installer-x86_64.exe"

# --- Helpers ------------------------------------------------------------------

function Write-Header($text) {
    Write-Host ""
    Write-Host "  ==============================================" -ForegroundColor Cyan
    Write-Host "   $text" -ForegroundColor White
    Write-Host "  ==============================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-OK($text)   { Write-Host "  [+] $text" -ForegroundColor Green }
function Write-Warn($text) { Write-Host "  [!] $text" -ForegroundColor Magenta }
function Write-Err($text)  { Write-Host "  [X] $text" -ForegroundColor Red }
function Write-Info($text) { Write-Host "      $text" -ForegroundColor DarkGray }

function Ask-YesNo($prompt) {
    $r = Read-Host "  $prompt [Y/N]"
    return ($r -match '^[Yy]')
}

function Safe-Copy($src, $dst, $label) {
    if (Test-Path $src) {
        New-Item -ItemType Directory -Force $dst | Out-Null
        Copy-Item "$src\*" $dst -Recurse -Force -ErrorAction SilentlyContinue
        $count = (Get-ChildItem $dst -Recurse -File).Count
        Write-OK "$label -> $dst ($count files)"
    } else {
        Write-Warn "$label - source not found, skipping ($src)"
    }
}

# --- Banner -------------------------------------------------------------------

Clear-Host
Write-Host ""
Write-Host "  +==============================================+" -ForegroundColor Cyan
Write-Host "  |        FLIPPER ARSENAL - SETUP v2            |" -ForegroundColor Cyan
Write-Host "  |   Momentum firmware loadout installer         |" -ForegroundColor Cyan
Write-Host "  +==============================================+" -ForegroundColor Cyan
Write-Host ""
Write-Info "Arsenal : $ARSENAL_URL"
Write-Info "Local   : $ARSENAL_DIR"
Write-Host ""

# --- Step 1: Git --------------------------------------------------------------

Write-Header "Step 1 / 6 - Git"

$gitOk = $false
try { git --version 2>&1 | Out-Null; $gitOk = $true } catch {}

if ($gitOk) {
    Write-OK "Git found: $(git --version 2>&1)"
} else {
    Write-Warn "Git not found. Downloading..."
    $gitInstaller = "$env:TEMP\git_installer.exe"
    try {
        Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/latest/download/Git-2.45.2-64-bit.exe" `
            -OutFile $gitInstaller -UseBasicParsing
        Start-Process -FilePath $gitInstaller `
            -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS" -Wait
        $env:PATH += ";C:\Program Files\Git\cmd"
        Write-OK "Git installed."
    } catch {
        Write-Err "Git install failed. Install manually: https://git-scm.com"
        Read-Host "Press Enter to exit"; exit 1
    }
}

# --- Helpers: find qFlipper exe -----------------------------------------------

function Find-QFlipper {
    # 1 - common fixed paths
    $pf86 = [System.Environment]::GetFolderPath('ProgramFilesX86')
    $candidates = @(
        "$env:ProgramFiles\qFlipper\qFlipper.exe",
        "$env:ProgramFiles\Flipper Devices\qFlipper\qFlipper.exe",
        "$pf86\qFlipper\qFlipper.exe",
        "$env:LOCALAPPDATA\Programs\qFlipper\qFlipper.exe",
        "$env:LOCALAPPDATA\Programs\Flipper Devices\qFlipper\qFlipper.exe",
        "$env:LOCALAPPDATA\qFlipper\qFlipper.exe"
    )
    foreach ($p in $candidates) { if (Test-Path $p) { return $p } }

    # 2 - registry uninstall entries (winget installs land here)
    $regRoots = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    foreach ($root in $regRoots) {
        $entry = Get-ItemProperty $root -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -match 'qFlipper|Flipper' }
        if ($entry) {
            foreach ($e in @($entry)) {
                if ($e.InstallLocation) {
                    $exe = Join-Path $e.InstallLocation 'qFlipper.exe'
                    if (Test-Path $exe) { return $exe }
                }
                if ($e.DisplayIcon -and $e.DisplayIcon -match '\.exe') {
                    $ico = $e.DisplayIcon -replace '",?\d*$', '' -replace '"', ''
                    if (Test-Path $ico) { return $ico }
                }
            }
        }
    }

    # 3 - Start Menu + Desktop shortcuts
    $lnkDirs = @(
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs",
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs",
        "$env:USERPROFILE\Desktop",
        "$env:PUBLIC\Desktop"
    )
    foreach ($dir in $lnkDirs) {
        $lnk = Get-ChildItem $dir -Recurse -Filter '*qFlipper*' -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($lnk) {
            try {
                $shell = New-Object -ComObject WScript.Shell
                $sc = $shell.CreateShortcut($lnk.FullName)
                if (Test-Path $sc.TargetPath) { return $sc.TargetPath }
            } catch {}
        }
    }

    # 4 - recursive filesystem fallback
    $found = Get-ChildItem "$env:ProgramFiles" -Recurse -Filter 'qFlipper.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) { return $found.FullName }
    $found = Get-ChildItem "$env:LOCALAPPDATA" -Recurse -Filter 'qFlipper.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) { return $found.FullName }
    return $null
}

# --- Step 2: qFlipper ---------------------------------------------------------

Write-Header "Step 2 / 6 - qFlipper"
Write-Info "Official desktop app: firmware updates, file manager, screen streaming."
Write-Host ""

$doQF = Ask-YesNo "Install qFlipper?"

if (-not $doQF) {
    Write-Warn "Skipping qFlipper."
}

if ($doQF) {
    $qfExe = Find-QFlipper
    if ($qfExe) {
        Write-OK "qFlipper already installed: $qfExe"
    } else {
        $wingetOk = $false
        try {
            winget install --id Flipper.qFlipper -e --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                $wingetOk = $true
                Write-OK "qFlipper installed via winget."
            }
        } catch {}

        if (-not $wingetOk) {
            Write-Warn "winget unavailable. Downloading installer directly..."
            $qfPath = "$env:TEMP\qFlipper_installer.exe"
            try {
                Invoke-WebRequest -Uri $QFLIPPER_URL -OutFile $qfPath -UseBasicParsing
                Write-Host "  Launching qFlipper installer - follow the wizard..." -ForegroundColor Yellow
                Start-Process -FilePath $qfPath -Wait
                Write-OK "qFlipper installer completed."
            } catch {
                Write-Err "Download failed: $_"
                Write-Warn "Get it manually: https://flipperzero.one/update"
            }
        }

        $qfExe = Find-QFlipper
        if ($qfExe) {
            Write-OK "Found: $qfExe"
        } else {
            Write-Warn "Installed but exe not found in common paths."
            Write-Info "Search for qFlipper.exe in Start Menu or Program Files."
        }
    }
}

# --- Step 3: Clone Repos ------------------------------------------------------

Write-Header "Step 3 / 6 - Clone Repos"

# 3a - Flipper Arsenal (our repo)
Write-Host "  [3a] Flipper Arsenal..." -ForegroundColor Yellow
if (Test-Path "$ARSENAL_DIR\.git") {
    Write-OK "Arsenal exists - pulling latest..."
    git -C $ARSENAL_DIR pull --ff-only
} else {
    git clone $ARSENAL_URL $ARSENAL_DIR
    if ($LASTEXITCODE -ne 0) { Write-Err "Clone failed."; Read-Host "Press Enter"; exit 1 }
    Write-OK "Arsenal cloned."
}

# 3b - UberGuidoZ/Flipper (core signal files, shallow)
Write-Host ""
Write-Host "  [3b] UberGuidoZ/Flipper (core signals - shallow clone)..." -ForegroundColor Yellow
Write-Info "Contains: IR, Sub-GHz, NFC, RFID, BadUSB, Music, Graphics files"
if (Test-Path "$UBER_DIR\.git") {
    Write-OK "UberGuidoZ exists - pulling latest..."
    git -C $UBER_DIR pull --ff-only
} else {
    git clone --depth 1 $UBER_URL $UBER_DIR
    if ($LASTEXITCODE -ne 0) { Write-Warn "UberGuidoZ clone failed - SD copy will skip missing files." }
    else { Write-OK "UberGuidoZ cloned (shallow)." }
}

# --- Step 4: Community Modules ------------------------------------------------

Write-Header "Step 4 / 6 - Community Modules"
Write-Host ""

$modules = @(
    [PSCustomObject]@{ Key="Infrared/IRDB";                Label="[-> SD]  IR Database - 10k+ codes (~500 MB)";       SD=$true  },
    [PSCustomObject]@{ Key="Applications/Momentum-Apps";   Label="[-> SD]  Momentum FAP Apps - 245+ apps";            SD=$true  },
    [PSCustomObject]@{ Key="Sub-GHz/Community-DB";         Label="[-> SD]  Sub-GHz Signal DB - community .sub files"; SD=$true  },
    [PSCustomObject]@{ Key="Sub-GHz/Bruteforce";           Label="[-> SD]  Sub-GHz Bruteforce Tool";                  SD=$true  },
    [PSCustomObject]@{ Key="Dev/flipper-zero-tutorials";   Label="[local]  Dev Tutorials - C / GPIO / UART / JS";     SD=$false },
    [PSCustomObject]@{ Key="Resources/awesome-flipperzero";Label="[local]  Awesome Flipper - master resource index";  SD=$false }
)

# -- Try WinForms checkbox dialog (requires STA thread) ------------------------
function Show-ModuleForm($moduleList) {
    $sync = [hashtable]::Synchronized(@{ Checked = @(); OK = $false })

    $rs = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
    $rs.ApartmentState = "STA"
    $rs.ThreadOptions  = "ReuseThread"
    $rs.Open()
    $rs.SessionStateProxy.SetVariable("moduleList", $moduleList)
    $rs.SessionStateProxy.SetVariable("sync", $sync)

    $ps = [System.Management.Automation.PowerShell]::Create()
    $ps.Runspace = $rs
    [void]$ps.AddScript({
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing

        $form              = New-Object System.Windows.Forms.Form
        $form.Text         = "Flipper Arsenal - Select Modules"
        $form.Size         = New-Object System.Drawing.Size(580, 370)
        $form.StartPosition= "CenterScreen"
        $form.TopMost      = $true
        $form.FormBorderStyle = "FixedDialog"
        $form.MaximizeBox  = $false
        $form.BackColor    = [System.Drawing.Color]::FromArgb(28, 28, 28)
        $form.ForeColor    = [System.Drawing.Color]::White
        $form.Font         = New-Object System.Drawing.Font("Segoe UI", 10)

        $lbl               = New-Object System.Windows.Forms.Label
        $lbl.Text          = "Check modules to download.   [-> SD] copies to Flipper.   [local] stays on PC."
        $lbl.Location      = New-Object System.Drawing.Point(12, 10)
        $lbl.Size          = New-Object System.Drawing.Size(548, 20)
        $lbl.ForeColor     = [System.Drawing.Color]::FromArgb(150, 150, 150)
        $form.Controls.Add($lbl)

        $clb               = New-Object System.Windows.Forms.CheckedListBox
        $clb.Location      = New-Object System.Drawing.Point(12, 36)
        $clb.Size          = New-Object System.Drawing.Size(548, 200)
        $clb.CheckOnClick  = $true
        $clb.BackColor     = [System.Drawing.Color]::FromArgb(42, 42, 42)
        $clb.ForeColor     = [System.Drawing.Color]::White
        $clb.BorderStyle   = "FixedSingle"
        $clb.Font          = New-Object System.Drawing.Font("Consolas", 10)
        foreach ($m in $moduleList) { $clb.Items.Add($m.Label, $true) | Out-Null }
        $form.Controls.Add($clb)

        $btnAll            = New-Object System.Windows.Forms.Button
        $btnAll.Text       = "Select All"
        $btnAll.Location   = New-Object System.Drawing.Point(12, 248)
        $btnAll.Size       = New-Object System.Drawing.Size(105, 30)
        $btnAll.BackColor  = [System.Drawing.Color]::FromArgb(60, 60, 60)
        $btnAll.ForeColor  = [System.Drawing.Color]::White
        $btnAll.FlatStyle  = "Flat"
        $btnAll.Add_Click({ for ($i=0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, $true) } })
        $form.Controls.Add($btnAll)

        $btnNone           = New-Object System.Windows.Forms.Button
        $btnNone.Text      = "Select None"
        $btnNone.Location  = New-Object System.Drawing.Point(124, 248)
        $btnNone.Size      = New-Object System.Drawing.Size(105, 30)
        $btnNone.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
        $btnNone.ForeColor = [System.Drawing.Color]::White
        $btnNone.FlatStyle = "Flat"
        $btnNone.Add_Click({ for ($i=0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, $false) } })
        $form.Controls.Add($btnNone)

        $btnOK             = New-Object System.Windows.Forms.Button
        $btnOK.Text        = "OK - Download Selected"
        $btnOK.Location    = New-Object System.Drawing.Point(348, 248)
        $btnOK.Size        = New-Object System.Drawing.Size(212, 30)
        $btnOK.BackColor   = [System.Drawing.Color]::FromArgb(0, 120, 215)
        $btnOK.ForeColor   = [System.Drawing.Color]::White
        $btnOK.FlatStyle   = "Flat"
        $btnOK.DialogResult= "OK"
        $form.AcceptButton = $btnOK
        $form.Controls.Add($btnOK)

        $r = $form.ShowDialog()
        if ($r -eq "OK") {
            $sync.OK = $true
            $checked = @()
            for ($i = 0; $i -lt $clb.Items.Count; $i++) {
                if ($clb.GetItemChecked($i)) { $checked += $i }
            }
            $sync.Checked = $checked
        }
    })

    try   { $ps.Invoke() } catch {}
    $ps.Dispose()
    $rs.Close()
    return $sync
}

# -- Run selector, fall back to console menu if GUI fails ----------------------
$selectedModules = @()
$guiOk = $false

try {
    Write-Info "Opening module selector window..."
    $sync = Show-ModuleForm $modules
    if ($sync.OK) {
        $guiOk = $true
        foreach ($i in $sync.Checked) { $selectedModules += $modules[$i] }
    } elseif (-not $sync.OK -and $sync.Checked.Count -eq 0) {
        Write-Warn "Window closed without selecting - defaulting to console menu."
    }
} catch {
    Write-Warn "GUI unavailable - using console menu."
}

if (-not $guiOk) {
    # -- Console fallback: numbered toggle menu ---------------------------------
    $checked = @($true, $true, $true, $true, $true, $true)  # all on by default
    do {
        Write-Host ""
        Write-Host "  Toggle modules with number keys. Enter 0 when done." -ForegroundColor DarkGray
        Write-Host ""
        for ($i = 0; $i -lt $modules.Count; $i++) {
            $tick = if ($checked[$i]) { "[X]" } else { "[ ]" }
            $col  = if ($checked[$i]) { "Green" } else { "DarkGray" }
            Write-Host ("  [{0}] {1} {2}" -f ($i+1), $tick, $modules[$i].Label) -ForegroundColor $col
        }
        Write-Host ""
        Write-Host "  [A] Select All   [N] Select None   [0] Confirm" -ForegroundColor Cyan
        Write-Host ""
        $k = Read-Host "  Choice"
        if ($k -eq "A" -or $k -eq "a") { for ($i=0; $i -lt $checked.Count; $i++) { $checked[$i]=$true  } }
        elseif ($k -eq "N" -or $k -eq "n") { for ($i=0; $i -lt $checked.Count; $i++) { $checked[$i]=$false } }
        elseif ($k -match '^\d+$' -and [int]$k -ge 1 -and [int]$k -le $modules.Count) {
            $idx = [int]$k - 1
            $checked[$idx] = -not $checked[$idx]
        }
    } while ($k -ne "0")

    for ($i = 0; $i -lt $modules.Count; $i++) {
        if ($checked[$i]) { $selectedModules += $modules[$i] }
    }
}

# -- Download selected ----------------------------------------------------------
if ($selectedModules.Count -gt 0) {
    Write-Host ""
    foreach ($m in $selectedModules) {
        Write-Host "  Downloading $($m.Key)..." -ForegroundColor Yellow
        git -C $ARSENAL_DIR submodule update --init --depth 1 -- $m.Key
        if ($LASTEXITCODE -eq 0) { Write-OK $m.Key } else { Write-Warn "$($m.Key) failed - skipping" }
    }
} else {
    Write-Warn "No modules selected - skipping downloads."
}

# --- Step 5: SD Card Detection ------------------------------------------------

Write-Header "Step 5 / 6 - Flipper SD Card"
Write-Host "  Flipper must be in Mass Storage mode:" -ForegroundColor White
Write-Host "  Settings -> USB -> Mass Storage" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Scanning for removable drives..." -ForegroundColor DarkGray
Write-Host ""

$removable = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 }

$flipperDrive = $null

if ($removable.Count -eq 0) {
    Write-Warn "No removable drives detected."
    Write-Info "Make sure Flipper is in Mass Storage mode then try again."
    $manual = Read-Host "  Enter drive letter manually (or press Enter to skip SD copy)"
    if ($manual -eq "") { Write-Warn "Skipping SD copy."; goto done }
    $flipperDrive = "$($manual.Trim(':').Trim().ToUpper()):"
} elseif ($removable.Count -eq 1) {
    $d = $removable[0]
    Write-Host "  Found: $($d.DeviceID)  Volume: $($d.VolumeName)  Size: $([math]::Round($d.Size/1GB,1)) GB" -ForegroundColor Cyan
    Write-Host ""
    if (Ask-YesNo "Use $($d.DeviceID) as Flipper SD?") {
        $flipperDrive = $d.DeviceID
    } else {
        $manual = Read-Host "  Enter correct drive letter (or Enter to skip)"
        if ($manual -ne "") { $flipperDrive = "$($manual.Trim(':').Trim().ToUpper()):" }
    }
} else {
    Write-Host "  Multiple removable drives found:" -ForegroundColor Cyan
    $i = 1
    foreach ($d in $removable) {
        Write-Host "  [$i] $($d.DeviceID)  $($d.VolumeName)  $([math]::Round($d.Size/1GB,1)) GB" -ForegroundColor Cyan
        $i++
    }
    Write-Host "  [M] Enter manually" -ForegroundColor DarkGray
    Write-Host ""
    $pick = Read-Host "  Select [1-$($removable.Count)] or M"
    if ($pick -match '^\d+$' -and [int]$pick -ge 1 -and [int]$pick -le $removable.Count) {
        $flipperDrive = $removable[[int]$pick - 1].DeviceID
    } else {
        $manual = Read-Host "  Enter drive letter"
        $flipperDrive = "$($manual.Trim(':').Trim().ToUpper()):"
    }
}

if ($flipperDrive -and -not (Test-Path "$flipperDrive\")) {
    Write-Err "Drive $flipperDrive not accessible."
    Write-Info "Check Flipper is in Mass Storage mode."
    Read-Host "  Press Enter to exit"; exit 1
}

# --- Step 6: Copy to SD -------------------------------------------------------

Write-Header "Step 6 / 6 - Copy Files to SD ($flipperDrive)"

if (-not $flipperDrive) {
    Write-Warn "No SD drive selected - skipping file copy."
} else {
    Write-Info "Creating SD folder structure..."

    $sdFolders = @("infrared","subghz","nfc","lfrfid","badusb","apps","dolphin","music_player","wav_player","scripts","asset_packs")
    foreach ($f in $sdFolders) { New-Item -ItemType Directory -Force "$flipperDrive\$f" | Out-Null }

    Write-Host ""
    Write-Host "  Copying from UberGuidoZ/Flipper (core files)..." -ForegroundColor Yellow
    Safe-Copy "$UBER_DIR\Infrared"      "$flipperDrive\infrared"      "Infrared"
    Safe-Copy "$UBER_DIR\Sub-GHz"       "$flipperDrive\subghz"        "Sub-GHz"
    Safe-Copy "$UBER_DIR\NFC"           "$flipperDrive\nfc"           "NFC"
    Safe-Copy "$UBER_DIR\RFID"          "$flipperDrive\lfrfid"        "RFID"
    Safe-Copy "$UBER_DIR\BadUSB"        "$flipperDrive\badusb"        "BadUSB"
    Safe-Copy "$UBER_DIR\Music_Player"  "$flipperDrive\music_player"  "Music"
    Safe-Copy "$UBER_DIR\Wav_Player"    "$flipperDrive\wav_player"    "Wav"
    Safe-Copy "$UBER_DIR\Graphics"      "$flipperDrive\dolphin"       "Graphics"
    Safe-Copy "$UBER_DIR\Dolphin_Level" "$flipperDrive\dolphin"       "Dolphin animations"

    Write-Host ""
    Write-Host "  Copying from community modules..." -ForegroundColor Yellow
    Safe-Copy "$ARSENAL_DIR\Infrared\IRDB"                "$flipperDrive\infrared\IRDB"          "IR Database"
    Safe-Copy "$ARSENAL_DIR\Applications\Momentum-Apps"   "$flipperDrive\apps"                   "Momentum FAPs"
    Safe-Copy "$ARSENAL_DIR\Sub-GHz\Community-DB\subghz"  "$flipperDrive\subghz\community"       "Sub-GHz Community DB"
    Safe-Copy "$ARSENAL_DIR\Sub-GHz\Bruteforce\sub_files" "$flipperDrive\subghz\Bruteforce"      "Sub-GHz Bruteforce"

    Write-Host ""
    Write-Host "  Copying favorites shortcut..." -ForegroundColor Yellow
    if (Test-Path "$ARSENAL_DIR\favorites.txt") {
        Copy-Item "$ARSENAL_DIR\favorites.txt" "$flipperDrive\favorites.txt" -Force
        Write-OK "favorites.txt"
    }
}

# --- Done ---------------------------------------------------------------------

Write-Header "Setup Complete!"
if ($flipperDrive) {
    Write-Host "  SD card populated: $flipperDrive" -ForegroundColor Green
}
Write-Host "  Arsenal location : $ARSENAL_DIR" -ForegroundColor Green
Write-Host "  Core files       : $UBER_DIR" -ForegroundColor Green

# Show qFlipper location
$qfFinal = Find-QFlipper
if ($qfFinal) {
    Write-Host "  qFlipper         : $qfFinal" -ForegroundColor Green
} else {
    Write-Host "  qFlipper         : not found - search Start Menu" -ForegroundColor Magenta
}

Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Info "1. Safely eject $flipperDrive in File Explorer (right-click -> Eject)"
Write-Info "2. Press Back on Flipper to rescan SD"
Write-Info "3. Flash Momentum firmware via qFlipper:"
Write-Info "   github.com/Next-Flip/Momentum-Firmware/releases"
Write-Info "4. To update all repos later: run setup_flipper.bat again"
Write-Host ""

if ($qfFinal -and (Ask-YesNo "Launch qFlipper now?")) {
    Start-Process $qfFinal
}

Read-Host "  Press Enter to exit"
