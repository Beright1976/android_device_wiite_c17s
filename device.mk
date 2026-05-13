# ==========================================================
# LOKMAT APPLLP 5 MAX (c17s) — LineageOS 18.1 Device Tree
# ==========================================================

# 1. Base Identity
PRODUCT_NAME := lineage_c17s
PRODUCT_DEVICE := c17s
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := LOKMAT APPLLP 5 MAX
# FIX 1: Removed SPRD, correctly assigned to ODM
PRODUCT_MANUFACTURER := Wiite

# 2. Treble & VNDK Architecture
PRODUCT_FULL_TREBLE_OVERRIDE := true
PRODUCT_VNDK_VERSION := 29
PRODUCT_EXTRA_VNDK_VERSIONS := 29

# 3. Add Custom Native Daemon
# This instructs the build system to compile our C++ sensor bridge
PRODUCT_PACKAGES += \
    wiite_bridge_daemon

# 4. THE BURN LIST (Disposition List)
# We explicitly command the build system to DELETE these packages 
# even if they are pulled from the stock vendor/product extraction.
PRODUCT_DEL_PACKAGES += \
    Stopwatch \
    AdupsFota \
    WearDeviceDeamPix \
    WearCleanTaskPro \
    WearAppFreeze \
    HeilsFaceUnlockDM101

# 5. Core Hardware Properties & Spoofing
PRODUCT_PROPERTY_OVERRIDES += \
    ro.hardware=mt6762 \
    ro.board.platform=mt6765 \
    ro.vendor.mediatek.platform=MT6765 \
    ro.vndk.version=29 \
    ro.product.first_api_level=29 \
    ro.treble.enabled=true \
    ro.zygote=zygote64_32 \
    ro.sf.lcd_density=160 \
    qemu.hw.mainkeys=0 \
    ro.vendor.wlan.gen=gen4m \
    wifi.interface=wlan0 \
    wifi.direct.interface=p2p0 \
    wifi.tethering.interface=ap0 \
    ro.product.bt.name=APPLLP_5_MAX \
    ro.default_wifi_hotspot=APPLLP_5_MAX \
    vendor.rild.libpath=mtk-ril.so \
    vendor.rild.libargs=-d\ /dev/ttyC0 \
    ro.opengles.version=196610 \
    ro.hardware.egl=mtk \
    ro.crypto.state=encrypted \
    ro.crypto.type=file \
    ro.crypto.volume.filenames_mode=aes-256-cts \
    persist.vendor.connsys.chipid=0x6765

# FIX 2: Correct Android 11 (LineageOS 18.1) API Levels
PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.version.sdk=30 \
    ro.build.version.release=11

# FIX 4: Standard LineageOS Fingerprint Spoofing
PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.fingerprint=Xiaomi/olive/olive:10/QKQ1.191014.001/1749802324:user/release-keys

# 6. Audio/Bluetooth Calibration Fixes
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.audiohal.besloudness_state=1 \
    persist.vendor.bluetooth.a2dpstandbytime=500

