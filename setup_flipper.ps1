# Flipper Arsenal — Windows Setup Script
# Requires: Windows 10/11, PowerShell 5+
# Usage: Double-click setup_flipper.bat OR run directly in PowerShell

$REPO_URL  = "https://github.com/The-AI-Workshops/Flipper-arsenal.git"
$REPO_DIR  = "$env:USERPROFILE\Documents\Flipper-arsenal"
$QFLIPPER_URL = "https://update.flipperzero.one/builds/qFlipper/release/qFlipper-windows-installer-x86_64.exe"

# ─── Helpers ─────────────────────────────────────────────────────────────────

function Write-Header($text) {
    Write-Host ""
    Write-Host "  ══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "   $text" -ForegroundColor White
    Write-Host "  ══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step($n, $total, $text) {
    Write-Host "  [$n/$total] $text" -ForegroundColor Yellow
}

function Write-OK($text)   { Write-Host "  [OK] $text" -ForegroundColor Green }
function Write-Warn($text) { Write-Host "  [!!] $text" -ForegroundColor Magenta }
function Write-Err($text)  { Write-Host "  [ERR] $text" -ForegroundColor Red }

function Ask-YesNo($prompt) {
    $r = Read-Host "  $prompt [Y/N]"
    return ($r -match '^[Yy]')
}

function Pick-Module($label) {
    $r = Read-Host "  Install $label? [Y/N]"
    return ($r -match '^[Yy]')
}

# ─── Banner ───────────────────────────────────────────────────────────────────

Clear-Host
Write-Host ""
Write-Host "  ┌─────────────────────────────────────────────┐" -ForegroundColor Cyan
Write-Host "  │         FLIPPER ARSENAL — SETUP              │" -ForegroundColor Cyan
Write-Host "  │   Momentum firmware loadout installer         │" -ForegroundColor Cyan
Write-Host "  └─────────────────────────────────────────────┘" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Repo  : $REPO_URL" -ForegroundColor DarkGray
Write-Host "  Local : $REPO_DIR" -ForegroundColor DarkGray
Write-Host ""

# ─── Step 1: Git ─────────────────────────────────────────────────────────────

Write-Header "Step 1 — Git"

$gitOk = $false
try {
    $v = git --version 2>&1
    Write-OK "Git found: $v"
    $gitOk = $true
} catch {}

if (-not $gitOk) {
    Write-Warn "Git not found. Downloading..."
    $gitInstaller = "$env:TEMP\git_installer.exe"
    try {
        Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/latest/download/Git-2.45.2-64-bit.exe" `
            -OutFile $gitInstaller -UseBasicParsing
        Write-Host "  Installing Git silently..." -ForegroundColor Yellow
        Start-Process -FilePath $gitInstaller `
            -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS" `
            -Wait
        $env:PATH += ";C:\Program Files\Git\cmd"
        Write-OK "Git installed."
    } catch {
        Write-Err "Git install failed: $_"
        Write-Host "  Install manually from https://git-scm.com" -ForegroundColor DarkGray
        Read-Host "  Press Enter to exit"
        exit 1
    }
}

# ─── Step 2: qFlipper ────────────────────────────────────────────────────────

Write-Header "Step 2 — qFlipper (Official Flipper Desktop App)"
Write-Host "  qFlipper lets you update firmware, manage files," -ForegroundColor DarkGray
Write-Host "  install apps, and stream the Flipper screen." -ForegroundColor DarkGray
Write-Host ""

if (Ask-YesNo "Install qFlipper?") {
    # Try winget first (silent, no temp file)
    $wingetOk = $false
    try {
        winget install --id Flipper.qFlipper -e --silent 2>&1 | Out-Null
        $wingetOk = $true
        Write-OK "qFlipper installed via winget."
    } catch {}

    if (-not $wingetOk) {
        Write-Host "  winget not available. Downloading installer..." -ForegroundColor Yellow
        $qfPath = "$env:TEMP\qFlipper_installer.exe"
        try {
            Invoke-WebRequest -Uri $QFLIPPER_URL -OutFile $qfPath -UseBasicParsing
            Write-Host "  Launching qFlipper installer (follow the wizard)..." -ForegroundColor Yellow
            Start-Process -FilePath $qfPath -Wait
            Write-OK "qFlipper installer completed."
        } catch {
            Write-Err "qFlipper download failed: $_"
            Write-Warn "Download manually from https://flipperzero.one/update"
        }
    }
} else {
    Write-Warn "Skipping qFlipper."
}

# ─── Step 3: Clone Repo ──────────────────────────────────────────────────────

Write-Header "Step 3 — Clone Flipper Arsenal"

if (Test-Path "$REPO_DIR\.git") {
    Write-OK "Repo already exists at $REPO_DIR"
    Write-Host "  Pulling latest changes..." -ForegroundColor Yellow
    git -C $REPO_DIR pull
} else {
    Write-Host "  Cloning $REPO_URL ..." -ForegroundColor Yellow
    git clone $REPO_URL $REPO_DIR
    if ($LASTEXITCODE -ne 0) {
        Write-Err "Clone failed."
        Read-Host "  Press Enter to exit"
        exit 1
    }
    Write-OK "Repo cloned to $REPO_DIR"
}

# ─── Step 4: Select Modules ──────────────────────────────────────────────────

Write-Header "Step 4 — Select Modules to Download"
Write-Host "  Each module is a git submodule (community repo)." -ForegroundColor DarkGray
Write-Host "  Skip any you don't need to save time/space." -ForegroundColor DarkGray
Write-Host ""

$modules = @(
    @{ key="Infrared/IRDB";              label="IR Signal Database (Lucaslhm/Flipper-IRDB) — ~500MB, 10k+ IR codes" },
    @{ key="Applications/Momentum-Apps"; label="Momentum FAP Apps (Next-Flip) — 245+ apps" },
    @{ key="Sub-GHz/Community-DB";       label="Sub-GHz Signal DB (Zero-Sploit) — community .sub files" },
    @{ key="Sub-GHz/Bruteforce";         label="Sub-GHz Bruteforce Tool (tobiabocchi)" },
    @{ key="Dev/flipper-zero-tutorials"; label="Dev Tutorials (jamisonderek) — C, GPIO, UART, JS" },
    @{ key="Resources/awesome-flipperzero"; label="Awesome Flipper index (djsime1) — resource links" }
)

$selected = @()
foreach ($m in $modules) {
    if (Pick-Module $m.label) {
        $selected += $m.key
    }
}

if ($selected.Count -gt 0) {
    Write-Host ""
    Write-Host "  Initializing selected submodules..." -ForegroundColor Yellow
    foreach ($s in $selected) {
        Write-Host "  → $s" -ForegroundColor DarkGray
        git -C $REPO_DIR submodule update --init --depth 1 -- $s
        if ($LASTEXITCODE -eq 0) { Write-OK $s } else { Write-Warn "$s failed — skipping" }
    }
} else {
    Write-Warn "No modules selected. Core files still available."
}

# ─── Step 5: Copy to SD ──────────────────────────────────────────────────────

Write-Header "Step 5 — Copy to Flipper SD Card"
Write-Host "  Make sure your Flipper is connected and in Mass Storage mode:" -ForegroundColor DarkGray
Write-Host "  Settings → USB → Mass Storage" -ForegroundColor Yellow
Write-Host ""

# Auto-detect Flipper SD card
$flipperDrive = $null
$drives = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 }
foreach ($d in $drives) {
    if (Test-Path "$($d.DeviceID)\") {
        Write-Host "  Removable drive found: $($d.DeviceID) ($($d.VolumeName))" -ForegroundColor Cyan
    }
}

$driveInput = Read-Host "  Enter Flipper SD drive letter (e.g. E)"
$flipperDrive = "$($driveInput.Trim(':').Trim().ToUpper()):"

if (-not (Test-Path "$flipperDrive\")) {
    Write-Err "Drive $flipperDrive not found."
    Write-Host "  Enable Mass Storage on Flipper and try again." -ForegroundColor DarkGray
    Read-Host "  Press Enter to exit"
    exit 1
}

Write-OK "Flipper SD detected at $flipperDrive"
Write-Host ""

# Module → SD path mapping
$copyMap = @(
    @{ src="$REPO_DIR\Infrared\IRDB";              dst="$flipperDrive\infrared\IRDB";    label="IR Database" },
    @{ src="$REPO_DIR\Applications\Momentum-Apps"; dst="$flipperDrive\apps";             label="Momentum FAPs" },
    @{ src="$REPO_DIR\Sub-GHz\Community-DB\subghz";dst="$flipperDrive\subghz";           label="Sub-GHz signals" },
    @{ src="$REPO_DIR\Sub-GHz\Bruteforce\sub_files";dst="$flipperDrive\subghz\Bruteforce";label="Bruteforce files" }
)

Write-Host "  Copying files to SD card..." -ForegroundColor Yellow

foreach ($c in $copyMap) {
    if (Test-Path $c.src) {
        New-Item -ItemType Directory -Force $c.dst | Out-Null
        Copy-Item "$($c.src)\*" $c.dst -Recurse -Force
        Write-OK "$($c.label) → $($c.dst)"
    }
}

# ─── Done ────────────────────────────────────────────────────────────────────

Write-Header "Setup Complete!"
Write-Host "  Files installed to: $flipperDrive" -ForegroundColor Green
Write-Host "  Repo location:      $REPO_DIR" -ForegroundColor Green
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host "  1. Safely eject $flipperDrive in File Explorer" -ForegroundColor DarkGray
Write-Host "  2. Press Back on Flipper to rescan SD card" -ForegroundColor DarkGray
Write-Host "  3. Open qFlipper to update firmware to Momentum" -ForegroundColor DarkGray
Write-Host "     → https://github.com/Next-Flip/Momentum-Firmware/releases" -ForegroundColor DarkGray
Write-Host ""
Read-Host "  Press Enter to exit"
