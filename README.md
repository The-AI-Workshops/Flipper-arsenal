# Flipper Arsenal

> Curated Flipper Zero loadout for Momentum firmware — signal DBs, FAPs, JS scripts, BadUSB payloads & community repos, auto-updated daily.

Forked from [UberGuidoZ/Flipper](https://github.com/UberGuidoZ/Flipper) and extended with Momentum firmware focus, community repo aggregation, and auto-sync tooling.

---

## Quick Start (Windows)

**One script does everything — git, qFlipper, repo clone, module selection, SD copy.**

```
1. Download or clone this repo
2. Double-click  setup_flipper.bat
3. Follow the interactive menu
```

### What the installer does

| Step | Action |
|---|---|
| 1 | Installs **Git** if missing (silent, via official installer) |
| 2 | Installs **qFlipper** — official Flipper desktop app (via winget or direct download) |
| 3 | Clones **this repo** (`The-AI-Workshops/Flipper-arsenal`) or pulls latest |
| 4 | **Interactive module selection** — pick only what you want |
| 5 | Auto-detects SD card drive letter, copies files to correct paths |

### Module Selection Menu

The installer asks which community repos to download:

```
Install IR Signal Database (~500MB, 10k+ codes)?  [Y/N]
Install Momentum FAP Apps (245+ apps)?            [Y/N]
Install Sub-GHz Signal DB?                         [Y/N]
Install Sub-GHz Bruteforce Tool?                   [Y/N]
Install Dev Tutorials (C/GPIO/UART/JS)?            [Y/N]
Install Awesome Flipper index?                     [Y/N]
```

Skip anything you don't need. Core files always install.

### After Install

1. Safely eject the SD card in File Explorer
2. Press **Back** on Flipper to rescan
3. Update firmware to Momentum via qFlipper:
   → `github.com/Next-Flip/Momentum-Firmware/releases`

### If you already have the repo cloned

```powershell
# Pull latest + update all submodules
bash update_all.sh

# Or just run the installer again — it detects existing clone and pulls
setup_flipper.bat
```

---

## What's Inside

### Signal Files

| Folder | Content |
|---|---|
| `Infrared/` | IR codes — TVs, ACs, fans, projectors, audio |
| `Infrared/IRDB/` | [Lucaslhm/Flipper-IRDB](https://github.com/Lucaslhm/Flipper-IRDB) — primary community IR database (CC0-1.0) |
| `Sub-GHz/` | Sub-GHz signals — garage doors, remotes, pagers, vehicles |
| `Sub-GHz/Community-DB/` | [Zero-Sploit/FlipperZero-Subghz-DB](https://github.com/Zero-Sploit/FlipperZero-Subghz-DB) |
| `Sub-GHz/Bruteforce/` | [tobiabocchi/flipperzero-bruteforce](https://github.com/tobiabocchi/flipperzero-bruteforce) |
| `NFC/` | NFC dumps, Amiibo, tags |
| `RFID/` | 125kHz RFID files |
| `BadUSB/` | DuckyScript 1.0 payloads (`.txt`) — 100+ scripts |

### Apps & Dev

| Folder | Content |
|---|---|
| `Applications/Momentum-Apps/` | [Next-Flip/Momentum-Apps](https://github.com/Next-Flip/Momentum-Apps) — 245+ FAPs for Momentum |
| `Applications/Official/` | Official firmware FAPs |
| `Dev/flipper-zero-tutorials/` | [jamisonderek](https://github.com/jamisonderek/flipper-zero-tutorials) — C, GPIO, UART, JS guides |
| `Resources/awesome-flipperzero/` | [djsime1/awesome-flipperzero](https://github.com/djsime1/awesome-flipperzero) — master resource index |

### Other

| Folder | Content |
|---|---|
| `Graphics/` | Animations, themes, wallpapers |
| `Music_Player/` | `.fmf` music files |
| `Wav_Player/` | `.wav` audio |
| `GPIO/` | GPIO wiring guides |
| `Wifi_DevBoard/` | ESP32 devboard guides + schematic |

---

## Momentum Firmware

This repo is optimized for **[Momentum firmware](https://github.com/Next-Flip/Momentum-Firmware)** — the most feature-complete Flipper firmware as of 2026.

Key advantages over Official firmware:
- **183+ preinstalled FAPs** (OFW ships 3)
- **Extended Sub-GHz** — 281–962 MHz (beyond CC1101 spec)
- **Bad-KB** — BadUSB over Bluetooth, no cable needed
- **Asset Packs** — themes/animations without recompile
- **Expanded JS modules** — BLE, SubGHz, I2C, SPI, USB disk, NFC

> FAPs from this repo (`Applications/Momentum-Apps/`) are **not compatible** with Official firmware. Momentum/RogueMaster/Unleashed FAPs are interchangeable with each other.

---

## SD Card Layout

```
SD:/
├── infrared/        ← copy from Infrared/
├── subghz/          ← copy from Sub-GHz/
├── nfc/             ← copy from NFC/
├── lfrfid/          ← copy from RFID/
├── badusb/          ← copy from BadUSB/
├── apps/            ← copy from Applications/Momentum-Apps/
├── asset_packs/     ← Momentum themes
├── scripts/         ← .js JavaScript files
├── dolphin/         ← copy from Graphics/ + Dolphin_Level/
└── favorites.txt    ← quick-access items (/any/ prefix)
```

`setup_flipper.bat` handles all of this automatically.

---

## Auto-Update

Pull all repos (main + submodules + community clones):

```bash
bash update_all.sh
```

Runs automatically at **3:23 AM daily** when Claude session is active.
Logs to `update_all.log`.

Community repos updated:
- `Next-Flip/Momentum-Apps`
- `jamisonderek/flipper-zero-tutorials`
- `djsime1/awesome-flipperzero`
- `Zero-Sploit/FlipperZero-Subghz-DB`
- `tobiabocchi/flipperzero-bruteforce`
- All git submodules

---

## JavaScript Scripting (Momentum)

Drop `.js` on SD → Apps → Scripts. No compile, no PC needed.

```js
// GPIO
let gpio = require("gpio");
gpio.init("PC3", "outputPushPull", "up");
gpio.write("PC3", true);

// UART serial read
let serial = require("serial");
serial.setup("usart", 115200);
serial.write("help\r\n");
print(serial.readln(2000));

// BLE beacon spoof
let ble = require("blebeacon");
ble.setConfig("MyDevice", "random", [0x1E,0xFF,0x4C,0x00,0x12,0x19]);
ble.start();
```

**Momentum-exclusive modules:** `blebeacon` `subghz` `i2c` `spi` `usbdisk` `nfc` `infrared`

Full guide: [`FLIPPER_MOMENTUM_GUIDE.md`](FLIPPER_MOMENTUM_GUIDE.md)

---

## WiFi Dev Board

| Mode | Use |
|---|---|
| **BlackMagic** (default) | Wireless GDB — debug Flipper's own MCU over WiFi |
| **ESP32 Marauder** | Deauth, PMKID capture, evil portal, wardriving |

BlackMagic: SSID `blackmagic` / PW `iamwitcher` / GDB at `192.168.4.1:2345`

Flash Marauder via `esp32_wifi_marauder.fap` on Flipper.

---

## Building FAPs

```bash
# Install uFBT targeting Momentum
py -m pip install --upgrade ufbt
ufbt update --index-url https://up.momentum-fw.dev/firmware/index.json

# Build + deploy
ufbt build
ufbt launch
```

See [`Dev/flipper-zero-tutorials/`](Dev/flipper-zero-tutorials/) for GPIO, UART, and JS examples.

---

## Resources

| Resource | Link |
|---|---|
| Momentum Firmware | [Next-Flip/Momentum-Firmware](https://github.com/Next-Flip/Momentum-Firmware) |
| Signal search | [search.flippertools.net](https://search.flippertools.net) |
| IR database | [Lucaslhm/Flipper-IRDB](https://github.com/Lucaslhm/Flipper-IRDB) |
| Master index | [djsime1/awesome-flipperzero](https://github.com/djsime1/awesome-flipperzero) |
| Dev tutorials | [jamisonderek/flipper-zero-tutorials](https://github.com/jamisonderek/flipper-zero-tutorials) |
| uFBT | [flipperdevices/flipperzero-ufbt](https://github.com/flipperdevices/flipperzero-ufbt) |
| Official docs | [docs.flipperzero.one](https://docs.flipperzero.one) |
| Official Discord | [discord.com/invite/flipper](https://discord.com/invite/flipper) |

---

*Based on [UberGuidoZ/Flipper](https://github.com/UberGuidoZ/Flipper). Credits to all upstream contributors.*
