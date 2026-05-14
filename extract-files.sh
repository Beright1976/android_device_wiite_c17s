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

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
            CLEAN_VENDOR=false
            ;;
        -k | --kang )
            KANG="--kang"
            ;;
        -s | --section )
            SECTION="${2}"; shift
            CLEAN_VENDOR=false
            ;;
        * )
            SRC="${1}"
            ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

# ==========================================================
# SECURITY ENFORCEMENT AND RPATH CORRECTION
# ==========================================================
function blob_fixup() {
    case "${1}" in
        vendor/lib64/libhwm.so | vendor/lib64/libnvram.so | vendor/lib64/libfile_op.so)
            echo "[FIXUP] Patching RPATH for ${1}"
            patchelf --set-rpath /vendor/lib64 "${2}"
            ;;
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

setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
