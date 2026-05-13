# android_device_wiite_c17s

## LineageOS 18.1 (Android 11) Device Tree
### LOKMAT APPLLP 5 MAX (C17S)

---

## Device Specifications

| Feature | Specification |
|---------|--------------|
| **Device** | LOKMAT APPLLP 5 MAX |
| **Codename** | C17S |
| **SoC** | MT6762V/WB ("Franken-SoC" — MT6762 silicon, MT6765 platform) |
| **Architecture** | ARM64 (arm64-v8a) |
| **Display** | 480×640, 160 DPI, Novatek NT35695B |
| **GPU** | PowerVR GE8320 (Rogue) |
| **RAM** | 4GB |
| **Storage** | 64GB eMMC |
| **Battery** | 900mAh |
| **Cameras** | GalaxyCore GC2385 (rear 2MP), GC030A (front VGA) |
| **Connectivity** | LTE/VoLTE, WiFi 802.11 b/g/n, Bluetooth 5.0, GPS |
| **Sensors** | nRF52832 co-processor (barometer, accelerometer, step counter, temperature), Pixart PAR2822 (heart rate, SpO2) |
| **Encryption** | FBE v1 (aes-256-xts) |
| **Bootloader** | Unlockable |

---

## Project Status

| Component | Status |
|-----------|--------|
| Bootloader unlock | ✅ Complete |
| TWRP 11 recovery | ✅ Complete — full FBE decryption |
| Security research | ✅ Complete — CVE pending |
| Device tree | ✅ Complete |
| LineageOS 18.1 ROM | 🔄 In progress |

---

## Security Research

This device was found to contain deliberate ODM supply chain backdoor infrastructure embedded in the Android framework by the manufacturer Topwise/Wiite/Linswear. The full forensic security research is documented in a separate repository.

**Affected infrastructure confirmed:**
- UID 1000 persistent backdoor agent (`Stopwatch.apk`)
- Framework-level security subversion (`services.jar` — `WiitePackageManagerUtil`, `Configuration.isSpecialApp()`)
- Purpose-built permission escalation registry (`pms_sysapp_grant_permission_list.txt`)
- Enterprise BSP deployment confirmed across Android watch phones, POS terminals, and logistics scanners

Full threat assessment: [wiite-odm-backdoor-research](https://github.com/Beright1976/wiite-odm-backdoor-research)

---

## Clean ROM Architecture

This ROM build removes all ODM surveillance infrastructure and replaces the proprietary sensor bridge with a clean, open-source C++ daemon (`wiite_bridge_daemon`) that initializes the nRF52832 co-processor via the verified sysfs control plane and holds the UART data plane open for the kernel's own IRQ threads to deliver sensor data to Android's sensor framework.

**Burn list — removed from ROM:**
- `/vendor/operator/app/Stopwatch/`
- `/product/priv-app/AdupsFota/`
- `/product/priv-app/WearDeviceDeamPix/`
- `/product/app/WearCleanTaskPro/`
- `/product/app/WearAppFreeze/`
- `/system/priv-app/HeilsFaceUnlockDM101/`
- `/system/etc/permissions/pms_sysapp_grant_permission_list.txt`

---

## Build Instructions

### Prerequisites
- LineageOS 18.1 build environment
- Android build tools
- 16GB RAM minimum
- 300GB free disk space

### Setup

```bash
# Initialize LineageOS 18.1 source
repo init -u https://github.com/LineageOS/android.git -b lineage-18.1

# Clone this device tree
git clone https://github.com/Beright1976/android_device_wiite_c17s device/wiite/c17s

# Sync
repo sync -c -j$(nproc --all)

# Build
. build/envsetup.sh
lunch lineage_c17s-userdebug
mka bacon
```

---

## Related Repositories

| Repository | Description |
|-----------|-------------|
| [wiite-odm-backdoor-research](https://github.com/Beright1976/wiite-odm-backdoor-research) | Full forensic security research and CVE documentation |
| [twrp-build-protocol](https://github.com/Beright1976/twrp-build-protocol) | Protocol for building TWRP on undocumented MTK devices |
| [Lokmat5MAX_wiite-c17s_mt6765](https://github.com/Beright1976/Lokmat5MAX_wiite-c17s_mt6765) | Working TWRP 11 device tree — full FBE decryption |

---

## Developer

**Albert Pittman (Beright1976)**
Independent Android developer and security researcher.
First Western developer to achieve full TWRP decryption on this device family.

---

## License

GPL-3.0 — See LICENSE for details.
Security research and development work is open. If you build on this, keep it open.
