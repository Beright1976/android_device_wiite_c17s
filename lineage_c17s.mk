# ==========================================================
# LOKMAT APPLLP 5 MAX (c17s) — LineageOS 18.1 Device Tree
# ==========================================================

# 1. Base Identity
PRODUCT_NAME := lineage_c17s
PRODUCT_DEVICE := c17s
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := LOKMAT APPLLP 5 MAX
PRODUCT_MANUFACTURER := Wiite

# 2. Treble & VNDK Architecture
PRODUCT_FULL_TREBLE_OVERRIDE := true
PRODUCT_VNDK_VERSION := 29
PRODUCT_EXTRA_VNDK_VERSIONS := 29
TARGET_SUPPORTS_64_BIT_APPS := true

# 3. Add Custom Native Daemon
PRODUCT_PACKAGES += \
    wiite_bridge_daemon

# 4. THE BURN LIST
PRODUCT_DEL_PACKAGES += \
    Stopwatch \
    AdupsFota \
    WearDeviceDeamPix \
    WearCleanTaskPro \
    WearAppFreeze \
    HeilsFaceUnlockDM101

# 5. UI Overlay — Restore standard AOSP nav bar and status bar
# ODM suppressed both for 2.4-inch screen — we restore them
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

# 6. Core Hardware Properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.hardware=mt6762 \
    ro.board.platform=mt6765 \
    ro.vendor.mediatek.platform=MT6765 \
    ro.vndk.version=29 \
    ro.product.first_api_level=29 \
    ro.treble.enabled=true \
    ro.zygote=zygote64_32 \
    ro.sf.lcd_density=160 \
    ro.vendor.wlan.gen=gen4m \
    wifi.interface=wlan0 \
    wifi.direct.interface=p2p0 \
    wifi.tethering.interface=ap0 \
    ro.product.bt.name=APPLLP_5_MAX \
    ro.default_wifi_hotspot=APPLLP_5_MAX \
    vendor.rild.libpath=mtk-ril.so \
    vendor.rild.libargs=-d /dev/ttyC0 \
    ro.opengles.version=196610 \
    ro.hardware.egl=mtk \
    ro.crypto.state=encrypted \
    ro.crypto.type=file \
    ro.crypto.volume.filenames_mode=aes-256-cts \
    persist.vendor.connsys.chipid=0x6765

# 7. UI & Navigation
PRODUCT_PROPERTY_OVERRIDES += \
    qemu.hw.mainkeys=0

# 8. Android 11 API Levels
PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.version.sdk=30 \
    ro.build.version.release=11

# 9. LineageOS Fingerprint Spoofing
PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.fingerprint=Xiaomi/olive/olive:10/QKQ1.191014.001/1749802324:user/release-keys

# 10. Audio / Bluetooth Calibration
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.audiohal.besloudness_state=1 \
    persist.vendor.bluetooth.a2dpstandbytime=500

# 11. Single SIM Configuration
# Confirmed single-SIM device — vsim2 LDO regulator default-on wastes power
PRODUCT_PROPERTY_OVERRIDES += \
    persist.radio.multisim.config=ss \
    ro.telephony.sim.count=1

# 12. Radio Fast Dormancy — LTE power saving
# Section 8.14 confirmed required properties for Fast Dormancy
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.ril.fd.mode=1 \
    persist.vendor.radio.fd.counter=150 \
    persist.vendor.radio.fd.r8.counter=150 \
    persist.vendor.radio.fd.off.counter=50 \
    persist.vendor.radio.fd.off.r8.counter=50
    
# Force creation of recovery system/etc directory — AOSP build bug workaround
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery.fstab:recovery/root/system/etc/recovery.fstab    
