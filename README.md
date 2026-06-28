# Flipper Arsenal

> Curated Flipper Zero loadout for Momentum firmware — signal DBs, FAPs, JS scripts, BadUSB payloads & community repos, auto-updated daily.

Built on [UberGuidoZ/Flipper](https://github.com/UberGuidoZ/Flipper) + community submodules. Optimized for [Momentum firmware](https://github.com/Next-Flip/Momentum-Firmware).

---

## Quick Start (Windows)

**Single command — paste into PowerShell and press Enter. Nothing else needed.**

```powershell
irm https://raw.githubusercontent.com/The-AI-Workshops/Flipper-arsenal/main/setup_flipper.ps1 | iex
```

Opens in PowerShell (Win + X → Terminal, or search "PowerShell"). No admin required. No downloads before running.

> **Already cloned?** Run `setup_flipper.bat` directly — it detects existing files and pulls latest.

No manual config. No editing files. Everything is interactive.

---

## What the Installer Does

`setup_flipper.bat` launches `setup_flipper.ps1` — a 6-step interactive installer:

### Step 1 — Git
Checks if Git is installed. If not, downloads and silently installs the official Git for Windows.

### Step 2 — qFlipper
Offers to install the official Flipper desktop app.
- Tries `winget install Flipper.qFlipper` first (silent, no browser)
- Falls back to direct installer download if winget unavailable
- Skips if already installed

### Step 3 — Clone Repos
Clones two repos automatically:

| Repo | Purpose | Method |
|---|---|---|
| `The-AI-Workshops/Flipper-arsenal` | This repo — community modules, guides, scripts | Full clone |
| `UberGuidoZ/Flipper` | Core signal files (IR, Sub-GHz, NFC, BadUSB, Graphics) | Shallow `--depth 1` (fast) |

If repos already exist locally, pulls latest changes instead.

### Step 4 — Module Selection
Picks which community repos to download. Each is optional:

```
[→ SD] IR Database (10k+ codes, ~500MB)?          [Y/N]
[→ SD] Momentum FAP Apps (245+ apps)?              [Y/N]
[→ SD] Sub-GHz Signal DB (community .sub files)?   [Y/N]
[→ SD] Sub-GHz Bruteforce Tool?                    [Y/N]
[local] Dev Tutorials (C / GPIO / UART / JS)?      [Y/N]
[local] Awesome Flipper — resource index?           [Y/N]
```

`[→ SD]` = goes onto the Flipper SD card.  
`[local]` = stays on your PC for reference/dev.

### Step 5 — SD Card Detection
Flipper must be connected in **Mass Storage mode** (`Settings → USB → Mass Storage`).

The installer auto-detects removable drives:
- **1 drive found** → shows name + size, asks to confirm or override
- **Multiple drives** → numbered list, pick by number
- **None found** → prompts manual letter entry

### Step 6 — Copy Files to SD
Copies everything to the correct SD paths automatically:

| Source | SD Path |
|---|---|
| `UberGuidoZ/Infrared/` | `SD:/infrared/` |
| `UberGuidoZ/Sub-GHz/` | `SD:/subghz/` |
| `UberGuidoZ/NFC/` | `SD:/nfc/` |
| `UberGuidoZ/RFID/` | `SD:/lfrfid/` |
| `UberGuidoZ/BadUSB/` | `SD:/badusb/` |
| `UberGuidoZ/Music_Player/` | `SD:/music_player/` |
| `UberGuidoZ/Wav_Player/` | `SD:/wav_player/` |
| `UberGuidoZ/Graphics/` + `Dolphin_Level/` | `SD:/dolphin/` |
| `Infrared/IRDB/` | `SD:/infrared/IRDB/` |
| `Applications/Momentum-Apps/` | `SD:/apps/` |
| `Sub-GHz/Community-DB/` | `SD:/subghz/community/` |
| `Sub-GHz/Bruteforce/` | `SD:/subghz/Bruteforce/` |

Reports file count per folder. Skips gracefully if a module wasn't downloaded.

### After Install

1. **Eject** the SD card in File Explorer (right-click → Eject)
2. **Press Back** on Flipper to rescan SD
3. **Flash Momentum** via qFlipper → `github.com/Next-Flip/Momentum-Firmware/releases`

---

## Re-running / Updating

Run `setup_flipper.bat` again anytime — it detects existing clones and pulls latest instead of re-cloning.

Or update repos directly:

```bash
# Linux/macOS/WSL
bash update_all.sh

# Pulls: main repo + all submodules + community clones
# Logs to: update_all.log
```

---

## What's Inside

### Signal Files (via UberGuidoZ + community submodules)

| Path | Content |
|---|---|
| `_UberGuidoZ/Infrared/` | IR codes — TVs, ACs, fans, projectors, audio |
| `Infrared/IRDB/` | [Lucaslhm/Flipper-IRDB](https://github.com/Lucaslhm/Flipper-IRDB) — 10k+ IR codes (CC0-1.0) |
| `_UberGuidoZ/Sub-GHz/` | Sub-GHz — garage, remotes, pagers, vehicles |
| `Sub-GHz/Community-DB/` | [Zero-Sploit/FlipperZero-Subghz-DB](https://github.com/Zero-Sploit/FlipperZero-Subghz-DB) |
| `Sub-GHz/Bruteforce/` | [tobiabocchi/flipperzero-bruteforce](https://github.com/tobiabocchi/flipperzero-bruteforce) |
| `_UberGuidoZ/NFC/` | NFC dumps, Amiibo, tags |
| `_UberGuidoZ/RFID/` | 125kHz RFID files |
| `_UberGuidoZ/BadUSB/` | DuckyScript 1.0 payloads — 100+ scripts |

### Apps & Dev

| Path | Content |
|---|---|
| `Applications/Momentum-Apps/` | [Next-Flip/Momentum-Apps](https://github.com/Next-Flip/Momentum-Apps) — 245+ FAPs for Momentum |
| `Dev/flipper-zero-tutorials/` | [jamisonderek](https://github.com/jamisonderek/flipper-zero-tutorials) — C, GPIO, UART, JS |
| `Resources/awesome-flipperzero/` | [djsime1/awesome-flipperzero](https://github.com/djsime1/awesome-flipperzero) — master index |

### Docs

| File | Content |
|---|---|
| `FLIPPER_MOMENTUM_GUIDE.md` | Full research guide — Sub-GHz, FAPs, JS, GPIO, WiFi devboard |
| `setup_flipper.bat` | Windows installer launcher |
| `setup_flipper.ps1` | Full interactive PowerShell installer |
| `update_all.sh` | Linux/macOS auto-updater |

---

## Momentum Firmware

Recommended firmware. Key advantages over Official:

| Feature | Momentum | Official |
|---|---|---|
| Preinstalled FAPs | 183+ | 3 |
| Sub-GHz range | 281–962 MHz | 300–928 MHz |
| BadUSB over BLE | Yes (Bad-KB) | No |
| Themes (Asset Packs) | Yes | No |
| JS scripting modules | 13+ | 9 |

> FAPs in `Applications/Momentum-Apps/` are **not compatible** with Official firmware.  
> Momentum ↔ RogueMaster ↔ Unleashed FAPs are interchangeable.

---

## SD Card Structure

```
SD:/
├── infrared/           ← IR remotes (.ir)
│   └── IRDB/           ← 10k+ community IR codes
├── subghz/             ← Sub-GHz signals (.sub)
│   ├── community/      ← community DB
│   └── Bruteforce/     ← brute force files
├── nfc/                ← NFC cards/tags (.nfc)
├── lfrfid/             ← 125kHz RFID (.rfid)
├── badusb/             ← DuckyScript payloads (.txt)
├── apps/               ← FAP apps by category
│   ├── GPIO/
│   ├── Tools/
│   ├── Games/
│   ├── Bluetooth/
│   └── ...
├── asset_packs/        ← Momentum themes
├── scripts/            ← JS scripts (.js)
├── dolphin/            ← animations + level files
├── music_player/       ← music (.fmf)
├── wav_player/         ← audio (.wav)
└── favorites.txt       ← quick-access shortcuts
```

`favorites.txt` uses `/any/` prefix:
```
/any/nfc/my_card.nfc
/any/subghz/garage.sub
/any/badusb/payload.txt
```

---

## JavaScript Scripting (Momentum)

Drop `.js` on SD → Apps → Scripts. No compile needed.

```js
// GPIO
let gpio = require("gpio");
gpio.init("PC3", "outputPushPull", "up");
gpio.write("PC3", true);   // 3.3V

// UART read
let serial = require("serial");
serial.setup("usart", 115200);
serial.write("help\r\n");
print(serial.readln(2000));

// BLE beacon spoof
let ble = require("blebeacon");
ble.setConfig("MyDevice", "random", [0x1E,0xFF,0x4C,0x00,0x12,0x19]);
ble.start();
```

**Momentum-exclusive modules:** `blebeacon` · `subghz` · `i2c` · `spi` · `usbdisk` · `nfc` · `infrared`

Full reference: [`FLIPPER_MOMENTUM_GUIDE.md`](FLIPPER_MOMENTUM_GUIDE.md)

---

## WiFi Dev Board

| Mode | How | Use |
|---|---|---|
| **BlackMagic** (default) | Connects over WiFi | Wireless GDB debugger for Flipper MCU |
| **ESP32 Marauder** | Flash via `esp32_wifi_marauder.fap` | Deauth, PMKID, evil portal, wardriving |

BlackMagic: SSID `blackmagic` · PW `iamwitcher` · GDB `192.168.4.1:2345`

---

## Building FAPs

```bash
# Install uFBT for Momentum
py -m pip install --upgrade ufbt
ufbt update --index-url https://up.momentum-fw.dev/firmware/index.json

# Build + flash
ufbt build
ufbt launch
```

See [`Dev/flipper-zero-tutorials/`](Dev/flipper-zero-tutorials/) for full C and JS examples.

---

## Resources

| Resource | Link |
|---|---|
| Momentum Firmware | [Next-Flip/Momentum-Firmware](https://github.com/Next-Flip/Momentum-Firmware) |
| Momentum Apps | [Next-Flip/Momentum-Apps](https://github.com/Next-Flip/Momentum-Apps) |
| Signal search | [search.flippertools.net](https://search.flippertools.net) |
| IR database | [Lucaslhm/Flipper-IRDB](https://github.com/Lucaslhm/Flipper-IRDB) |
| Dev tutorials | [jamisonderek/flipper-zero-tutorials](https://github.com/jamisonderek/flipper-zero-tutorials) |
| uFBT | [flipperdevices/flipperzero-ufbt](https://github.com/flipperdevices/flipperzero-ufbt) |
| Master index | [djsime1/awesome-flipperzero](https://github.com/djsime1/awesome-flipperzero) |
| Official docs | [docs.flipperzero.one](https://docs.flipperzero.one) |
| Official Discord | [discord.com/invite/flipper](https://discord.com/invite/flipper) |

---

*Built on [UberGuidoZ/Flipper](https://github.com/UberGuidoZ/Flipper). Credits to all upstream contributors and community repo authors.*
