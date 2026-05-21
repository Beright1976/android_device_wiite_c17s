#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from AOSP 64-bit telephony base
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit LineageOS common full phone configuration
# This pulls in the entire LineageOS OS framework, apps, and UI
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# ==========================================================
# LOKMAT APPLLP 5 MAX (c17s) — LineageOS 18.1 Device Tree
# ==========================================================

# 1. Base Identity
PRODUCT_NAME := lineage_c17s
PRODUCT_DEVICE := c17s
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := LOKMAT APPLLP 5 MAX
PRODUCT_MANUFACTURER := Wiite

TARGET_VENDOR := wiite
TARGET_VENDOR_PRODUCT_NAME := c17s

# 2. Treble & VNDK Architecture
PRODUCT_FULL_TREBLE_OVERRIDE := true
PRODUCT_VNDK_VERSION := 29
PRODUCT_EXTRA_VNDK_VERSIONS := 29
PRODUCT_SHIPPING_API_LEVEL := 29
TARGET_SUPPORTS_64_BIT_APPS := true

# Boot animation resolution
TARGET_BOOT_ANIMATION_RES := 480

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
    HeilsFaceUnlockDM101 \
    WapiCertManager

# 5. UI Overlay — Restore standard AOSP nav bar and status bar
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
BUILD_FINGERPRINT := Xiaomi/olive/olive:10/QKQ1.191014.001/1749802324:user/release-keys

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.fingerprint=$(BUILD_FINGERPRINT)

# 10. Audio / Bluetooth Calibration
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.audiohal.besloudness_state=1 \
    persist.vendor.bluetooth.a2dpstandbytime=500

# 11. Single SIM Configuration
PRODUCT_PROPERTY_OVERRIDES += \
    persist.radio.multisim.config=ss \
    ro.telephony.sim.count=1
    
# 13. USB VID/PID — ADB host recognition and MTP enumeration
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.usb.vid=0x0E8D \
    vendor.usb.pid=0x201D

# 12. Radio Fast Dormancy — LTE power saving
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.ril.fd.mode=1 \
    persist.vendor.radio.fd.counter=150 \
    persist.vendor.radio.fd.r8.counter=150 \
    persist.vendor.radio.fd.off.counter=50 \
    persist.vendor.radio.fd.off.r8.counter=50

# Force creation of recovery system/etc directory — AOSP build bug workaround
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery.fstab:recovery/root/system/etc/recovery.fstab
    
# rootdir Deployment
# fstab.mt6765 -> ramdisk: first-stage mount reads this to assemble super partition
#   (system, vendor, product logical volumes via device-mapper before /vendor exists)
# fstab.mt6765 -> vendor: vold and second-stage init read from here at runtime
# init.project.rc -> vendor: platform init script loaded by init from /vendor/etc/init/hw/
#   Sets up USB OTG storage, camera AF nodes, SMB screen comm, wiite_corp_ctrl SELinux labels
#   ODM dead code removed: iAmCdRom.iso mount, remosaic_daemon
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6765:$(TARGET_COPY_OUT_RAMDISK)/fstab.mt6765 \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6765:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt6765 \
    $(LOCAL_PATH)/rootdir/etc/init/hw/init.project.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.project.rc

# Vendor blobs — HALs, firmware, proprietary libs extracted via extract-files.sh
$(call inherit-product, vendor/wiite/c17s/c17s-vendor.mk)
