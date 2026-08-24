#!/usr/bin/env bash
#
# Copyright 2026 Variscite Ltd. - https://www.variscite.com/
# SPDX-License-Identifier: Apache-2.0
#
# Build Android artifacts for a Variscite target and stage a
# release tarball.
#
# Adapted from the imx8 version of this script for the TI AOSP tree.

set -e

usage() {
  cat <<'EOF'
var-create-release-package.sh - Build and stage Variscite Android artifacts

USAGE:
  MACHINE=<machine> ./var-create-release-package.sh [--release R] [--variant userdebug|user] [--jobs N]
  ./var-create-release-package.sh --help

REQUIRED:
  MACHINE must be one of:
    am62-var-som-symphony
    am62p-var-som-symphony

OPTIONS:
  --release R   release config for the lunch combo (default: bp2a)
  --variant V   userdebug|user (default: userdebug)
  --jobs N      Parallel jobs for `m` (default: 8)

ENV:
  ANDROID_BUILD_ROOT  AOSP root (default: $PWD)
  ZSTD_LEVEL          zstd compression level for the tarball (default: 19)
  ZSTD_THREADS        zstd worker threads, 0 = auto (default: 0)

EXAMPLE:
  MACHINE=am62p-var-som-symphony ./var-create-release-package.sh --jobs 16
EOF
}

RELEASE="bp2a"
VARIANT="userdebug"
JOBS="8"

while [ $# -gt 0 ]; do
  case "$1" in
    --release) RELEASE="$2"; shift 2 ;;
    --variant) VARIANT="$2"; shift 2 ;;
    --jobs)    JOBS="$2";    shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: unknown arg: $1"; usage; exit 1 ;;
  esac
done

[ -n "${MACHINE:-}" ] || { echo "ERROR: MACHINE is required"; usage; exit 1; }

case "${VARIANT}" in
  userdebug|user) ;;
  *) echo "ERROR: invalid --variant '${VARIANT}'"; exit 1 ;;
esac

PRODUCT=""
LUNCH_PRODUCT=""
case "${MACHINE}" in
  am62-var-som-symphony)  PRODUCT="am62x_var_som"; LUNCH_PRODUCT="am62x_var_som" ;;
  am62p-var-som-symphony) PRODUCT="am62p_var_som"; LUNCH_PRODUCT="am62p_var_som" ;;
  *) echo "ERROR: unsupported MACHINE: ${MACHINE}"; usage; exit 1 ;;
esac

ANDROID_BUILD_ROOT="${ANDROID_BUILD_ROOT:-$(pwd)}"
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
ART_ROOT="${SCRIPT_DIR}/android-artifacts"
ART_ANDROID="${ART_ROOT}/android"
ART_SCRIPTS="${ART_ROOT}/scripts"

INSTALL_SCRIPT_DIR="${ANDROID_BUILD_ROOT}/device/variscite/scripts/sh/var_mk_yocto_sdcard/variscite_scripts/"
OUTDIR="${ANDROID_BUILD_ROOT}/out/target/product/${PRODUCT}"
LUNCH_TARGET="${LUNCH_PRODUCT}-${RELEASE}-${VARIANT}"

copy_glob() {
  src_glob="$1"
  dst_dir="$2"
  ( shopt -s nullglob
    matches=( $src_glob )
    if [ ${#matches[@]} -eq 0 ]; then
      echo "WARN: no matches for: ${src_glob}"
      return 0
    fi
    mkdir -p "${dst_dir}"
    cp -a "${matches[@]}" "${dst_dir}/"
  )
}

copy_file() {
  src="$1"
  dst_dir="$2"
  dst_file_name="${3:-}"

  if [ -e "${src}" ]; then
    mkdir -p "${dst_dir}"
    if [ -n "${dst_file_name}" ]; then
      cp -a "${src}" "${dst_dir}/${dst_file_name}"
    else
      cp -a "${src}" "${dst_dir}/"
    fi
  else
    echo "WARN: missing: ${src}"
  fi
}

clean_product_outdir() {
  echo "Cleaning product outdir: ${OUTDIR}"
  rm -rf "${OUTDIR}"
}

run_build() {
  echo "=== BUILD ${MACHINE} : lunch ${LUNCH_TARGET} jobs=${JOBS} ==="

  [ -f "${ANDROID_BUILD_ROOT}/build/envsetup.sh" ] || {
    echo "ERROR: build/envsetup.sh not found under ANDROID_BUILD_ROOT=${ANDROID_BUILD_ROOT}"
    exit 1
  }

  clean_product_outdir

  (
    cd "${ANDROID_BUILD_ROOT}"
    # shellcheck disable=SC1091
    source build/envsetup.sh
    lunch "${LUNCH_TARGET}"
    m -j"${JOBS}" droid sbom
  )
}

# FAT32 image bundling tispl.bin + u-boot.img — what TI ROM code expects in
# the "bootloader" partition. Same recipe as flashall.sh's
# generate_bootloader_image, factored out so the released artifact is the
# ready-to-flash bootloader-${MACHINE}.img instead of the raw pieces.
generate_bootloader_image() {
  local tisplbin="$1"
  local ubootimg="$2"
  local outfile="$3"

  command -v mkfs.vfat >/dev/null 2>&1 || { echo "ERROR: mkfs.vfat not found (apt install dosfstools)"; exit 1; }
  command -v mcopy     >/dev/null 2>&1 || { echo "ERROR: mcopy not found (apt install mtools)"; exit 1; }
  [ -f "${tisplbin}" ] || { echo "ERROR: tispl not found: ${tisplbin}"; exit 1; }
  [ -f "${ubootimg}" ] || { echo "ERROR: u-boot not found: ${ubootimg}"; exit 1; }

  echo "Generating $(basename "${outfile}") ..."
  dd if=/dev/zero of="${outfile}" bs=1048576 count=8 status=none
  mkfs.vfat "${outfile}" >/dev/null
  mcopy -i "${outfile}" "${tisplbin}" ::tispl.bin
  mcopy -i "${outfile}" "${ubootimg}" ::u-boot.img
}

copy_artifacts_for_machine() {
  dest="$1"
  echo "=== COPY ${MACHINE} -> ${dest} ==="

  [ -d "${OUTDIR}" ] || { echo "ERROR: output dir not found: ${OUTDIR}"; exit 1; }

  mkdir -p "${dest}"

  copy_file "${OUTDIR}/tiboot3-${MACHINE}-hsfs.bin"           "${dest}"

  generate_bootloader_image \
    "${OUTDIR}/tispl-${MACHINE}.bin" \
    "${OUTDIR}/u-boot-${MACHINE}.img" \
    "${dest}/bootloader-${MACHINE}.img"

  copy_file "${OUTDIR}/tispl-${MACHINE}.bin"                  "${dest}"
  copy_file "${OUTDIR}/u-boot-${MACHINE}.img"                 "${dest}"

  # Android boot images.
  copy_file "${OUTDIR}/boot.img"                              "${dest}"
  copy_file "${OUTDIR}/vendor_boot.img"                       "${dest}"
  copy_file "${OUTDIR}/init_boot.img"                         "${dest}"

  copy_file "${OUTDIR}/dtbo.img"                              "${dest}"
  copy_file "${OUTDIR}/dtbo-unsigned.img"                     "${dest}"

  copy_file "${OUTDIR}/vbmeta.img"                            "${dest}"
  copy_file "${OUTDIR}/vbmeta_vendor_dlkm.img"                "${dest}"
  copy_file "${OUTDIR}/vbmeta_system_dlkm.img"                "${dest}"

  # Dynamic partitions blob (system + vendor + product + *_dlkm).
  if file "${OUTDIR}/super.img" 2>/dev/null | grep -q "Android sparse image"; then
    simg2img_bin="${ANDROID_BUILD_ROOT}/out/host/linux-x86/bin/simg2img"
    [ -x "${simg2img_bin}" ] || simg2img_bin="$(command -v simg2img || true)"
    [ -n "${simg2img_bin}" ] || { echo "ERROR: simg2img not found (apt install android-sdk-libsparse-utils)"; exit 1; }
    echo "Converting sparse super.img -> raw ..."
    "${simg2img_bin}" "${OUTDIR}/super.img" "${dest}/super.img"
  else
    copy_file "${OUTDIR}/super.img"                           "${dest}"
  fi

  copy_file "${OUTDIR}/metadata.img"                          "${dest}"
  copy_file "${OUTDIR}/persist.img"                           "${dest}"

  # Host-side fastboot installer (the build emits it into OUTDIR).
  copy_file "${OUTDIR}/flashall.sh"                           "${dest}"

  # SPDX SBOM (Software Bill of Materials) produced by the `sbom` target.
  copy_file "${OUTDIR}/sbom.spdx.json"                        "${dest}"
}

copy_scripts() {
  mkdir -p "${ART_SCRIPTS}"

  shopt -s nullglob
  script_files=("${INSTALL_SCRIPT_DIR}"/*.sh)
  shopt -u nullglob

  if [ ${#script_files[@]} -eq 0 ]; then
    echo "WARN: No .sh scripts found in ${INSTALL_SCRIPT_DIR}"
    return
  fi

  cp -a "${script_files[@]}" "${ART_SCRIPTS}/"

  echo "Copied scripts to ${ART_SCRIPTS}:"
  for script in "${script_files[@]}"; do
    echo "  - $(basename "${script}")"
  done
}

create_tar_zst() {
  local src_dir="${ART_ROOT:-}"
  [ -n "${src_dir}" ] || { echo "ERROR: ART_ROOT is not set"; return 1; }
  [ -d "${src_dir}" ] || { echo "ERROR: directory not found: ${src_dir}"; return 1; }

  command -v zstd >/dev/null 2>&1 || { echo "ERROR: zstd not found in PATH"; return 1; }
  command -v tar  >/dev/null 2>&1 || { echo "ERROR: tar not found in PATH";  return 1; }

  local parent base out_file level threads
  parent="$(dirname -- "${src_dir}")"
  base="$(basename -- "${src_dir}")"

  out_file="${1:-${parent}/${base}-${MACHINE}-${VARIANT}.tar.zst}"
  level="${ZSTD_LEVEL:-19}"
  threads="${ZSTD_THREADS:-0}"

  rm -f "${out_file}"

  echo "Creating: ${out_file}"
  echo "From    : ${src_dir}"

  tar -C "${parent}" -cf - "${base}" \
    | zstd -"${level}" -T"${threads}" -o "${out_file}"

  echo "${out_file}"
}

if [ -d "${ART_ROOT}" ]; then
  echo "Cleaning ${ART_ROOT}"
  rm -r "${ART_ROOT}"
fi

mkdir -p "${ART_ROOT}" "${ART_SCRIPTS}" "${ART_ANDROID}"

run_build
copy_artifacts_for_machine "${ART_ANDROID}"
copy_scripts
out_archive="$(create_tar_zst)"

echo "Done."
echo "Artifacts root  : ${ART_ROOT}"
echo "Release archive : ${out_archive}"
