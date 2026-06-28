# Flipper Zero + Momentum Firmware — Master Guide
> Deep research synthesis · June 2026 · Verified claims only

---

## Firmware: Momentum at a Glance

Momentum = direct continuation of Xtreme firmware, built on Official firmware + Unleashed features.
Repo: `github.com/Next-Flip/Momentum-Firmware`

**Key differentiators vs Official firmware:**
- 183+ preinstalled external FAPs (OFW ships 3)
- Extended Sub-GHz frequency ranges (outside CC1101 spec)
- Bad-KB: BLE-based BadUSB with MAC/name spoofing
- Asset Packs: themes/animations with no recompile
- Expanded JS scripting modules (BLE, SubGHz, I2C, SPI, USB disk)
- FindMy Flipper, BLE Spam, NFC Maker, Wardriver bundled

---

## Sub-GHz Frequencies

### CC1101 Official Spec vs Momentum Extended

| Range | Official | Momentum Extended | Risk |
|---|---|---|---|
| Low | 300–348 MHz | **281–361 MHz** | Outside spec — possible HW damage |
| Mid | 387–464 MHz | **378–481 MHz** | Outside spec |
| High | 779–928 MHz | **749–962 MHz** | Outside spec |

> Warning: TI documents hardware damage risk when operating CC1101 outside official ranges. Most community members report no issues, but no long-term study exists.

---

## Top FAP Apps for Momentum

Get FAPs from `github.com/Next-Flip/Momentum-Apps` (245+ as of June 2026).
NOT the official Flipper catalog — API-incompatible with Momentum.

### Must-Have Apps

| App | Category | Description |
|---|---|---|
| **BLE Spam** | Bluetooth | Floods Apple/Android/Windows BLE popups |
| **Bad-KB** | Tools | BadUSB over BLE — no cable needed, spoof name+MAC |
| **FindMy Flipper** | Bluetooth | Spoof Apple AirTag beacons |
| **NFC Maker** | NFC | Write custom NDEF tags |
| **Wardriver** | Sub-GHz | WiFi wardriving (needs GPS module) |
| **File Search** | Tools | Search entire SD card |
| **ESP32 Marauder** | WiFi | Full WiFi attack suite via devboard |
| **DAP Link** | GPIO | Flipper as JTAG/SWD probe for other hardware |
| **ProtoView** | Sub-GHz | Decode unknown Sub-GHz signals visually |
| **Bluetooth Remote** | Bluetooth | HID remote control |
| **TOTP** | Tools | Time-based OTP authenticator |
| **Seader** | NFC | Read/emulate SE-specific credentials |

### FAP Compatibility Rule
- Momentum/RogueMaster/Unleashed FAPs: **interchangeable with each other**
- Official firmware FAPs: **NOT compatible** (different major API version)
- Always rebuild FAPs when major API version changes

---

## Signal Databases

### IR (Infrared)
- **Primary:** `github.com/Lucaslhm/Flipper-IRDB` — CC0-1.0 (since commit 2319685, Aug 2025)
  - Also mirrored at `github.com/logickworkshop/Flipper-IRDB`
  - Files: `Infrared/IRDB/` in this repo (submodule)
- **UberGuidoZ collection:** `Infrared/` in this repo
- **Search:** `search.flippertools.net`

### Sub-GHz
- **Community DB:** `github.com/Zero-Sploit/FlipperZero-Subghz-DB`
  - Located: `Sub-GHz/Community-DB/` in this repo
- **ADolbyB collection:** `github.com/ADolbyB/flipper-zero-files`
- **Bruteforce tool:** `github.com/tobiabocchi/flipperzero-bruteforce`
  - Located: `Sub-GHz/Bruteforce/` in this repo
- **Search all:** `search.flippertools.net`

### BadUSB
- **This repo:** `BadUSB/` — 102 DuckyScript 1.0 `.txt` files
- **Dedicated repo:** `github.com/UberGuidoZ/Flipper_Zero-BadUsb`
- **Hack5 payloads:** `BadUSB/Flipper_Zero_Badusb_hack5_payloads/` (submodule)
- **Format:** DuckyScript 1.0 — `REM`, `DELAY`, `STRING`, `GUI`, `ENTER`
- **Bad-KB (BLE):** Use Bad-KB app on Momentum, same `.txt` format, runs over Bluetooth

---

## WiFi Developer Board

### Hardware
- Module: **ESP32-S2-WROVER**
- Default firmware: **BlackMagic Debug** (ships installed)

### Mode 1: BlackMagic (Debug)
Wireless GDB debugger for Flipper's own MCU.
- SSID: `blackmagic`
- Password: `iamwitcher`
- IP: `192.168.4.1`
- GDB port: `2345`
- Connect VS Code Cortex-Debug → step-debug running FAPs wirelessly

### Mode 2: ESP32 Marauder (Recommended for Momentum)
Flash via `esp32_wifi_marauder.fap` on Flipper.
Wiki: `justcallmekoko/ESP32Marauder/wiki/flipper-zero`

Capabilities:
- `sniffdeauth` — deauthentication attacks (802.11)
- `sniffpmkid` — PMKID/EAPOL WPA2 handshake capture
- Evil portal
- Beacon spoofing / spam
- Wardriving (add GPS module for coordinates)
- 5GHz deauth via Double Barrel variant (RTL8720DN, Sep 2025)

> Note: Xtreme firmware listed on Marauder wiki is abandoned since Summer 2024. Ignore it.

### Mode 3: DAP Link FAP
Use Flipper itself as JTAG/SWD interface to debug other hardware — no external probe needed.

---

## Momentum-Specific Settings

### Asset Packs (Themes)
1. Copy pack to `SD:/asset_packs/<pack_name>/`
2. Go to Momentum Settings → Interface → Asset Pack → select
3. No firmware recompile required
4. Pack creators: run `asset_packer.py` to convert PNGs → `.bm/.bmx`
5. Available since Momentum v40

### JS Scripting
Drop `.js` files anywhere on SD → run from Apps → Scripts.
No compilation, no PC connection needed.

### Extended Sub-GHz
Enabled by default. No config file needed unlike Unleashed.

---

## SD Card Structure

```
SD:/
├── infrared/           ← .ir files
├── subghz/             ← .sub files
├── nfc/                ← .nfc files
├── lfrfid/             ← .rfid / .lfrfid files
├── ibutton/            ← .ibtn files
├── badusb/             ← .txt DuckyScript files
├── apps/               ← .fap apps organized by category
│   ├── GPIO/
│   ├── Tools/
│   ├── Games/
│   ├── Bluetooth/
│   ├── Sub-GHz/
│   ├── NFC/
│   ├── Infrared/
│   └── USB/
├── asset_packs/        ← Momentum themes
│   └── MyTheme/
│       ├── Icons/
│       ├── Anims/
│       └── Fonts/
├── dolphin/            ← animations (.bm/.bmx) + manifest
├── wav_player/         ← .wav audio files
├── music_player/       ← .fmf music files
├── scripts/            ← .js JavaScript files
└── favorites.txt       ← quick-access items
```

### favorites.txt Format
Uses `/any/` prefix (resolves to internal or SD storage):
```
/any/nfc/my_card.nfc
/any/subghz/garage.sub
/any/badusb/payload.txt
/any/infrared/tv_remote.ir
```

---

## Building FAPs (C Development)

### Toolchain: uFBT (Recommended for standalone FAP dev)
```bash
# Install
python3 -m pip install --upgrade ufbt   # Linux/macOS
py -m pip install --upgrade ufbt        # Windows

# Target Momentum specifically
ufbt update --index-url https://up.momentum-fw.dev/firmware/index.json

# Build
ufbt build

# Flash + launch
ufbt launch
```

### Toolchain: fbt (Full firmware dev)
```bash
./fbt launch APPSRC=<appid>    # build + deploy single FAP
./fbt fap_<appid>              # build .fap binary only
./fbt flash_usb                # flash firmware via USB
```

### FAP Structure
Every app needs `application.fam`:
```python
App(
    appid="my_app",
    apptype=FlipperAppType.EXTERNAL,
    entry_point="my_app_main",
    fap_category="Tools",
    stack_size=2 * 1024,
    fap_version=(1, 0),
    fap_icon="icon.png",
    fap_description="Does cool stuff",
)
```

FAP binary: ARM ELF 32-bit relocatable with `.fapmeta` section.
Loaded into RAM by App Loader (SD is SPI, not memory-mapped).

### API Version Warning
FAPs are locked to firmware major API version at build time.
Rebuild whenever Momentum releases a major API bump or FAP refuses to launch.

---

## JavaScript Scripting (No Compile)

Engine: **mJS** from Cesanta (~50KB flash, ~2KB RAM overhead).

### Standard Modules (Official + Momentum)
```js
let gpio    = require("gpio");     // digital I/O
let serial  = require("serial");   // UART/USART/LPUART
let badusb  = require("badusb");   // USB-HID keyboard
let storage = require("storage");  // SD card R/W
let notify  = require("notification"); // LED/vibrate/sound
```

### Momentum-Exclusive Modules
```js
let ble     = require("blebeacon"); // BLE advertising
let i2c     = require("i2c");      // I2C bus
let spi     = require("spi");      // SPI bus
let subghz  = require("subghz");   // Sub-GHz radio
let usbdisk = require("usbdisk");  // USB mass storage
let ir      = require("infrared"); // IR transmit/receive
let nfc     = require("nfc");      // NFC
```

### GPIO Example
```js
let gpio = require("gpio");
gpio.init("PC3", "outputPushPull", "up");
gpio.write("PC3", true);   // 3.3V
gpio.write("PC3", false);  // 0V
// All pins: 3.3V logic, MCU at 64 MHz
```

### UART Automation (Security Use Case)
```js
let serial = require("serial");
serial.setup("usart", 115200);
serial.write("help\r\n");
let response = serial.readln(2000); // 2s timeout
print(response);
```

### BLE Beacon Spoofing
```js
let ble = require("blebeacon");
ble.setConfig("Apple AirTag", "random", [0x1E,0xFF,0x4C,0x00,0x12,0x19]);
ble.start();
```

> Breaking API change Oct 2024: old JS scripts may need updates.

---

## GPIO Hardware Reference

| Pin | Function | Notes |
|---|---|---|
| 1 | 5V | From USB only |
| 2, 4 | GND | |
| 3 | 3.3V | 50mA max |
| 5 | PC3 | GPIO / UART TX |
| 6 | PB3 | GPIO / SPI SCK |
| 7 | PB2 | GPIO / SPI MISO |
| 8 | PA4 | GPIO / SPI CS |
| 9 | PA6 | GPIO |
| 10 | PA7 | GPIO |
| 11 | PA14 | GPIO / SWD CLK |
| 12 | PA13 | GPIO / SWD IO |
| 13 | PB6 | I2C SCL |
| 14 | PB7 | I2C SDA |
| 15 | PC1 | GPIO / UART RX |
| 16 | PC0 | GPIO |
| 17 | 1-Wire | iButton |
| 18 | GND | |

All GPIO: **3.3V logic**. 5V tolerant on some pins — check datasheet before connecting 5V signals.

---

## Community Resources

| Resource | URL / Path | Purpose |
|---|---|---|
| Momentum Firmware | `Next-Flip/Momentum-Firmware` | Source + releases |
| Momentum Apps | `Next-Flip/Momentum-Apps` | FAPs for Momentum |
| Awesome Flipper | `djsime1/awesome-flipperzero` | Master index |
| UberGuidoZ | `UberGuidoZ/Flipper` | This repo |
| Derek Jamison tutorials | `jamisonderek/flipper-zero-tutorials` | Dev tutorials (GPIO/UART/JS) |
| JS-Momentum wiki | `jamisonderek` wiki: JavaScript-Momentum | Momentum JS modules |
| Official good FAPs | `flipperdevices/flipperzero-good-faps` | Reference implementations |
| IRDB | `Lucaslhm/Flipper-IRDB` | IR signal database |
| SubGHz DB | `Zero-Sploit/FlipperZero-Subghz-DB` | Sub-GHz signals |
| Bruteforce | `tobiabocchi/flipperzero-bruteforce` | Sub-GHz brute force |
| Signal search | `search.flippertools.net` | Cross-DB search |
| uFBT | `flipperdevices/flipperzero-ufbt` | FAP build tool |

### Local Repo Layout (this directory)
```
Dev/
├── flipper-zero-tutorials/   ← jamisonderek tutorials
Resources/
└── awesome-flipperzero/      ← djsime1 master index
Applications/
└── Momentum-Apps/            ← Next-Flip FAPs
Sub-GHz/
├── Community-DB/             ← Zero-Sploit signals
└── Bruteforce/               ← tobiabocchi tool
Infrared/
└── IRDB/                     ← Lucaslhm IRDB (submodule)
```

---

## Debugging FAPs

### Wireless Debugging via WiFi DevBoard
1. Keep BlackMagic firmware on devboard
2. Connect to `blackmagic` WiFi
3. VS Code: install Cortex-Debug extension
4. Launch config targets `192.168.4.1:2345`
5. Attach to running Flipper process
6. Use `furi_assert()` to hit breakpoints in C code
7. Read backtraces from crash logs

### Flipper as Debug Probe (DAP Link FAP)
Flipper can act as JTAG/SWD interface for **other hardware**:
- Load DAP Link FAP from apps
- Connect target via GPIO header
- Attach GDB to Flipper's USB serial

---

## Hidden Gems

- **UART injection via JS** — automate serial attacks on embedded devices. No C, no compile. See secureideas.com blog
- **FliPmods Combo** — 3rd party ESP32 + GPS + extra CC1101 in one module (Jan 2025)
- **Marauder Double Barrel 5G** — 5GHz deauth via RTL8720DN (Sep 2025)
- **Flipper as TOTP authenticator** — replaces phone app, works offline
- **NFC NDEF writing** — clone/customize NFC tags with NFC Maker
- **Seader app** — reads iClass SE credentials most tools can't touch
- `search.flippertools.net` — searchable index across all community signal files

---

*Auto-updated via `update_all.sh` — run periodically or see cron config.*
