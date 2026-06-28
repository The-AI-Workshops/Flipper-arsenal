# Flipper Arsenal — Windows Setup Script
# Requires: Windows 10/11, PowerShell 5+
# Usage: Double-click setup_flipper.bat OR run directly in PowerShell

$ARSENAL_URL  = "https://github.com/The-AI-Workshops/Flipper-arsenal.git"
$UBER_URL     = "https://github.com/UberGuidoZ/Flipper.git"
$ARSENAL_DIR  = "$env:USERPROFILE\Documents\Flipper-arsenal"
$UBER_DIR     = "$env:USERPROFILE\Documents\Flipper-arsenal\_UberGuidoZ"
$QFLIPPER_URL = "https://update.flipperzero.one/builds/qFlipper/release/qFlipper-windows-installer-x86_64.exe"

# ─── Helpers ──────────────────────────────────────────────────────────────────

function Write-Header($text) {
    Write-Host ""
    Write-Host "  ══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "   $text" -ForegroundColor White
    Write-Host "  ══════════════════════════════════════════════" -ForegroundColor Cyan
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
        Write-OK "$label → $dst ($count files)"
    } else {
        Write-Warn "$label — source not found, skipping ($src)"
    }
}

# ─── Banner ───────────────────────────────────────────────────────────────────

Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║        FLIPPER ARSENAL — SETUP v2            ║" -ForegroundColor Cyan
Write-Host "  ║   Momentum firmware loadout installer         ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Info "Arsenal : $ARSENAL_URL"
Write-Info "Local   : $ARSENAL_DIR"
Write-Host ""

# ─── Step 1: Git ──────────────────────────────────────────────────────────────

Write-Header "Step 1 / 6 — Git"

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

# ─── Step 2: qFlipper ─────────────────────────────────────────────────────────

Write-Header "Step 2 / 6 — qFlipper"
Write-Info "Official desktop app: firmware updates, file manager, screen streaming."
Write-Host ""

if (Ask-YesNo "Install qFlipper?") {
    $wingetOk = $false
    try {
        $wg = winget list --id Flipper.qFlipper 2>&1
        if ($wg -match "Flipper") {
            Write-OK "qFlipper already installed."
            $wingetOk = $true
        }
    } catch {}

    if (-not $wingetOk) {
        try {
            winget install --id Flipper.qFlipper -e --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
            Write-OK "qFlipper installed via winget."
            $wingetOk = $true
        } catch {}
    }

    if (-not $wingetOk) {
        Write-Warn "winget unavailable. Downloading installer directly..."
        $qfPath = "$env:TEMP\qFlipper_installer.exe"
        try {
            Invoke-WebRequest -Uri $QFLIPPER_URL -OutFile $qfPath -UseBasicParsing
            Write-Host "  Launching qFlipper installer — follow the wizard..." -ForegroundColor Yellow
            Start-Process -FilePath $qfPath -Wait
            Write-OK "qFlipper installer completed."
        } catch {
            Write-Err "Download failed: $_"
            Write-Warn "Get it manually: https://flipperzero.one/update"
        }
    }
} else {
    Write-Warn "Skipping qFlipper."
}

# ─── Step 3: Clone Repos ──────────────────────────────────────────────────────

Write-Header "Step 3 / 6 — Clone Repos"

# 3a — Flipper Arsenal (our repo)
Write-Host "  [3a] Flipper Arsenal..." -ForegroundColor Yellow
if (Test-Path "$ARSENAL_DIR\.git") {
    Write-OK "Arsenal exists — pulling latest..."
    git -C $ARSENAL_DIR pull --ff-only
} else {
    git clone $ARSENAL_URL $ARSENAL_DIR
    if ($LASTEXITCODE -ne 0) { Write-Err "Clone failed."; Read-Host "Press Enter"; exit 1 }
    Write-OK "Arsenal cloned."
}

# 3b — UberGuidoZ/Flipper (core signal files, shallow)
Write-Host ""
Write-Host "  [3b] UberGuidoZ/Flipper (core signals — shallow clone)..." -ForegroundColor Yellow
Write-Info "Contains: IR, Sub-GHz, NFC, RFID, BadUSB, Music, Graphics files"
if (Test-Path "$UBER_DIR\.git") {
    Write-OK "UberGuidoZ exists — pulling latest..."
    git -C $UBER_DIR pull --ff-only
} else {
    git clone --depth 1 $UBER_URL $UBER_DIR
    if ($LASTEXITCODE -ne 0) { Write-Warn "UberGuidoZ clone failed — SD copy will skip missing files." }
    else { Write-OK "UberGuidoZ cloned (shallow)." }
}

# ─── Step 4: Community Modules ────────────────────────────────────────────────

Write-Header "Step 4 / 6 — Community Modules"
Write-Info "A selection window will open. Check the modules you want, then click OK."
Write-Host ""

$modules = @(
    [PSCustomObject]@{ Key="Infrared/IRDB";                Label="[→ SD]  IR Database — 10k+ codes (~500 MB)";        SD=$true  },
    [PSCustomObject]@{ Key="Applications/Momentum-Apps";   Label="[→ SD]  Momentum FAP Apps — 245+ apps";             SD=$true  },
    [PSCustomObject]@{ Key="Sub-GHz/Community-DB";         Label="[→ SD]  Sub-GHz Signal DB — community .sub files";  SD=$true  },
    [PSCustomObject]@{ Key="Sub-GHz/Bruteforce";           Label="[→ SD]  Sub-GHz Bruteforce Tool";                   SD=$true  },
    [PSCustomObject]@{ Key="Dev/flipper-zero-tutorials";   Label="[local] Dev Tutorials — C / GPIO / UART / JS";      SD=$false },
    [PSCustomObject]@{ Key="Resources/awesome-flipperzero";Label="[local] Awesome Flipper — master resource index";   SD=$false }
)

# ── Windows Forms checkbox dialog ─────────────────────────────────────────────
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form              = New-Object System.Windows.Forms.Form
$form.Text         = "Flipper Arsenal — Select Modules"
$form.Size         = New-Object System.Drawing.Size(560, 360)
$form.StartPosition= "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox  = $false
$form.Font         = New-Object System.Drawing.Font("Segoe UI", 10)
$form.BackColor    = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.ForeColor    = [System.Drawing.Color]::White

$label             = New-Object System.Windows.Forms.Label
$label.Text        = "Select modules to download:  [→ SD] = copied to Flipper   [local] = PC only"
$label.Location    = New-Object System.Drawing.Point(12, 10)
$label.Size        = New-Object System.Drawing.Size(520, 22)
$label.ForeColor   = [System.Drawing.Color]::FromArgb(160, 160, 160)
$form.Controls.Add($label)

$clb               = New-Object System.Windows.Forms.CheckedListBox
$clb.Location      = New-Object System.Drawing.Point(12, 38)
$clb.Size          = New-Object System.Drawing.Size(520, 190)
$clb.CheckOnClick  = $true
$clb.BackColor     = [System.Drawing.Color]::FromArgb(45, 45, 45)
$clb.ForeColor     = [System.Drawing.Color]::White
$clb.BorderStyle   = "FixedSingle"
$clb.Font          = New-Object System.Drawing.Font("Consolas", 10)
foreach ($m in $modules) { $clb.Items.Add($m.Label, $true) | Out-Null }  # all checked by default
$form.Controls.Add($clb)

# Select All / None buttons
$btnAll            = New-Object System.Windows.Forms.Button
$btnAll.Text       = "Select All"
$btnAll.Location   = New-Object System.Drawing.Point(12, 238)
$btnAll.Size       = New-Object System.Drawing.Size(100, 30)
$btnAll.BackColor  = [System.Drawing.Color]::FromArgb(60, 60, 60)
$btnAll.ForeColor  = [System.Drawing.Color]::White
$btnAll.FlatStyle  = "Flat"
$btnAll.Add_Click({ for ($i=0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, $true) } })
$form.Controls.Add($btnAll)

$btnNone           = New-Object System.Windows.Forms.Button
$btnNone.Text      = "Select None"
$btnNone.Location  = New-Object System.Drawing.Point(120, 238)
$btnNone.Size      = New-Object System.Drawing.Size(100, 30)
$btnNone.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$btnNone.ForeColor = [System.Drawing.Color]::White
$btnNone.FlatStyle = "Flat"
$btnNone.Add_Click({ for ($i=0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, $false) } })
$form.Controls.Add($btnNone)

$btnOK             = New-Object System.Windows.Forms.Button
$btnOK.Text        = "OK — Download Selected"
$btnOK.Location    = New-Object System.Drawing.Point(330, 238)
$btnOK.Size        = New-Object System.Drawing.Size(200, 30)
$btnOK.BackColor   = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnOK.ForeColor   = [System.Drawing.Color]::White
$btnOK.FlatStyle   = "Flat"
$btnOK.DialogResult= "OK"
$form.AcceptButton = $btnOK
$form.Controls.Add($btnOK)

$result = $form.ShowDialog()

$selectedModules = @()
if ($result -eq "OK") {
    for ($i = 0; $i -lt $modules.Count; $i++) {
        if ($clb.GetItemChecked($i)) { $selectedModules += $modules[$i] }
    }
}

if ($selectedModules.Count -gt 0) {
    Write-Host ""
    foreach ($m in $selectedModules) {
        Write-Host "  Downloading $($m.Key)..." -ForegroundColor Yellow
        git -C $ARSENAL_DIR submodule update --init --depth 1 -- $m.Key
        if ($LASTEXITCODE -eq 0) { Write-OK $m.Key } else { Write-Warn "$($m.Key) failed — skipping" }
    }
} else {
    Write-Warn "No modules selected."
}

# ─── Step 5: SD Card Detection ────────────────────────────────────────────────

Write-Header "Step 5 / 6 — Flipper SD Card"
Write-Host "  Flipper must be in Mass Storage mode:" -ForegroundColor White
Write-Host "  Settings → USB → Mass Storage" -ForegroundColor Yellow
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

# ─── Step 6: Copy to SD ───────────────────────────────────────────────────────

Write-Header "Step 6 / 6 — Copy Files to SD ($flipperDrive)"

if (-not $flipperDrive) {
    Write-Warn "No SD drive selected — skipping file copy."
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

# ─── Done ─────────────────────────────────────────────────────────────────────

Write-Header "Setup Complete!"
if ($flipperDrive) {
    Write-Host "  SD card populated: $flipperDrive" -ForegroundColor Green
}
Write-Host "  Arsenal location : $ARSENAL_DIR" -ForegroundColor Green
Write-Host "  Core files       : $UBER_DIR" -ForegroundColor Green
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Info "1. Safely eject $flipperDrive in File Explorer (right-click → Eject)"
Write-Info "2. Press Back on Flipper to rescan SD"
Write-Info "3. Flash Momentum firmware via qFlipper:"
Write-Info "   github.com/Next-Flip/Momentum-Firmware/releases"
Write-Info "4. To update all repos later: run setup_flipper.bat again"
Write-Host ""
Read-Host "  Press Enter to exit"
