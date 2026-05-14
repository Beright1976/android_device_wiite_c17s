#!/bin/bash
#
# Copyright (C) 2016-2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=c17s
VENDOR=wiite

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to adb if no path is provided, but allow local dump path overriding
SRC=$1
if [ -z "${SRC}" ]; then
    SRC="adb"
fi

# ==========================================================
# SECURITY ENFORCEMENT AND RPATH CORRECTION
# ==========================================================
function blob_fixup() {
    case "${1}" in
        # RPATH corrections for NVRAM/Calibration libraries
        vendor/lib64/libhwm.so | vendor/lib64/libnvram.so | vendor/lib64/libfile_op.so)
            echo "[FIXUP] Patching RPATH for ${1}"
            patchelf --set-rpath /vendor/lib64 "${2}"
            ;;

        # HARD SAFETY NET: Destroy ODM malware if ever listed
        vendor/operator/app/Stopwatch* | \
        product/priv-app/AdupsFota* | \
        product/priv-app/WearDeviceDeamPix* | \
        product/app/WearCleanTaskPro* | \
        product/app/WearAppFreeze* | \
        system/priv-app/HeilsFaceUnlockDM101* | \
        system/etc/permissions/pms_sysapp_grant_permission_list.txt)
            echo "[SECURITY BREACH PREVENTED] Destroying malicious payload: ${1}"
            rm -f "${2}"
            ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

# Extract the blobs using the verified manifest
extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${ANDROID_ROOT}"

# Automatically execute the makefile generation once extraction is complete
"${MY_DIR}/setup-makefiles.sh"
