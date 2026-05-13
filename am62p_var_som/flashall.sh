#!/bin/bash
#
# Copyright 2026 Variscite Ltd. - https://www.variscite.com/
# SPDX-License-Identifier: Apache-2.0
#
# Flash Android partitions to VAR-SOM-AM62P on Symphony-Board (HS-FS only).
# Run from $TARGET_OUT after `m -j`. See --help for options.

set -e
set -u
set -o pipefail

BOARD="am62p-var-som-symphony"

function usage {
	echo "Usage: sudo $(basename "$0") [options]"
	echo "options:"
	echo "  --sdcard /dev/<SDCARD>   Generate a bootable SD card"
	echo "  --bootloader             Flash bootloader only (for layout changes)"
	echo "  --disable-avb            Flash vbmeta with verity/verification disabled"
	echo "  --help                   Show this message and exit"
	exit 1
}

# FAT32 image holding tispl.bin + u-boot.img, written to the eMMC bootloader partition.
function generate_bootloader_image {
	local tisplbin=$1
	local ubootimg=$2
	echo "Generating bootloader-${BOARD}.img ..."
	dd if=/dev/zero of="bootloader-${BOARD}.img" bs=1048576 count=8 status=none
	mkfs.vfat "bootloader-${BOARD}.img"
	mcopy -i "bootloader-${BOARD}.img" "${tisplbin}" ::tispl.bin
	mcopy -i "bootloader-${BOARD}.img" "${ubootimg}" ::u-boot.img
	echo "Generating bootloader-${BOARD}.img: DONE"
}

function run_sdcard_creation {
	local sd_dev=$1
	local tiboot3bin=$2
	local bootloader_only=$3

	if [ "$EUID" -ne 0 ]; then
		echo "Please run as root/sudo"
		exit 1
	fi

	dd if=/dev/zero of=./installer.img count=40960 status=none

	local loopdev
	loopdev=$(losetup -f)
	losetup "${loopdev}" installer.img
	parted "${loopdev}" mktable gpt
	parted "${loopdev}" mkpart primary fat32 5MiB 13MiB
	parted "${loopdev}" mkpart primary 4MiB 5MiB
	mkfs.vfat -F 32 -n "boot" "${loopdev}p1"
	dd if="${tiboot3bin}" of="${loopdev}p2" status=none
	sync

	mkdir -p boot
	mount "${loopdev}p1" boot
	cp "${tiboot3bin}" boot/tiboot3.bin
	cp "tispl-${BOARD}.bin" boot/tispl.bin
	cp "u-boot-${BOARD}.img" boot/u-boot.img
	umount boot
	losetup -d "${loopdev}"
	dd if=installer.img of="${sd_dev}" status=none
	rm -rf boot installer.img
	set +e
	eject "${sd_dev}"
	set -e

	if [[ "${bootloader_only}" == "true" ]]; then
		echo "Done preparing bootstrap SD card."
		exit 0
	fi

	echo
	echo "Insert the SD card, power the board on, and interrupt U-Boot at"
	echo "the '=>' prompt to prepare eMMC for Android (run once):"
	echo "  => mmc dev 0 0"
	echo "  => mmc erase 0 0x10000"
	echo "  => mmc dev 0 1"
	echo "  => mmc erase 0 0x10000"
	echo "  => env default -a"
	echo "  => setenv mmcdev 0"
	echo "  => saveenv"
	echo "  => reset"
	echo
	echo "After reboot, interrupt U-Boot again and enter fastboot:"
	echo "  => fastboot usb 0"
	echo
	read -p "Press any key when the host sees the fastboot device... " -n1 -s
	echo
}

function main {
	local opts_args="sdcard:,help,bootloader,disable-avb"
	local opts
	opts=$(getopt -o '' -l "${opts_args}" -- "$@")
	eval set -- "${opts}"

	local sd_dev=""
	local bootloader_only="false"
	local disable_avb="false"
	while true; do
		case "$1" in
			--sdcard)       sd_dev="$2"; shift 2 ;;
			--bootloader)   bootloader_only="true"; shift ;;
			--disable-avb)  disable_avb="true"; shift ;;
			--help)         usage; exit 0 ;;
			--)             shift; break ;;
		esac
	done

	echo "board: ${BOARD} (HS-FS)"

	local tiboot3bin="tiboot3-${BOARD}-hsfs.bin"
	local tisplbin="tispl-${BOARD}.bin"
	local ubootimg="u-boot-${BOARD}.img"

	local required_bootloaders=("${tiboot3bin}" "${tisplbin}" "${ubootimg}")
	local img
	for img in "${required_bootloaders[@]}"; do
		if [ ! -e "${img}" ]; then
			echo "Missing ${img}"
			exit 1
		fi
	done

	if [ -n "${sd_dev}" ]; then
		run_sdcard_creation "${sd_dev}" "${tiboot3bin}" "${bootloader_only}"
	fi

	if [[ -x "fastboot" ]] && [[ ! -v FASTBOOT ]]; then
		export FASTBOOT="./fastboot"
	fi
	export FASTBOOT=${FASTBOOT-$(which fastboot)}
	export LD_LIBRARY_PATH=./
	echo "Fastboot: ${FASTBOOT}"
	if [ ! -f "${FASTBOOT}" ]; then
		echo "Error: fastboot is not available at ${FASTBOOT}"
		exit 1
	fi

	generate_bootloader_image "${tisplbin}" "${ubootimg}"
	local bootloaderimg="bootloader-${BOARD}.img"

	local userdataimg="userdata.img"
	local superimg="super.img"
	local bootimg="boot.img"
	local vendorbootimg="vendor_boot.img"
	local initbootimg="init_boot.img"
	local vbmetaimg="vbmeta.img"
	local vbmetavendordlkmimg="vbmeta_vendor_dlkm.img"
	local vbmetasystemdlkmimg="vbmeta_system_dlkm.img"
	local dtboimg="dtbo.img"
	local persistimg="persist.img"
	local metadataimg="metadata.img"

	local required_images=(
		"${tiboot3bin}"
		"${bootloaderimg}"
		"${superimg}"
		"${userdataimg}"
		"${bootimg}"
		"${vendorbootimg}"
		"${initbootimg}"
		"${persistimg}"
		"${metadataimg}"
		"${dtboimg}"
		"${vbmetaimg}"
		"${vbmetavendordlkmimg}"
		"${vbmetasystemdlkmimg}"
	)

	for img in "${required_images[@]}"; do
		if [ ! -e "${img}" ]; then
			echo "Missing ${img}"
			exit 1
		fi
	done

	echo "Create GPT partition table"
	${FASTBOOT} oem format
	sleep 3

	echo "Flashing tiboot3 (HS-FS)"
	echo "   tiboot3bin: ${tiboot3bin}"
	${FASTBOOT} flash tiboot3 "${tiboot3bin}"
	sleep 3

	echo "Flashing bootloader (tispl + u-boot)"
	echo "   bootloader: ${bootloaderimg}"
	${FASTBOOT} flash bootloader "${bootloaderimg}"

	if [[ "${bootloader_only}" == "true" ]]; then
		echo "Done flashing bootloader"
		exit 0
	fi

	echo "Flashing Boot Image"
	${FASTBOOT} flash boot_a "${bootimg}"
	${FASTBOOT} flash boot_b "${bootimg}"

	echo "Flashing Vendor Boot Image"
	${FASTBOOT} flash vendor_boot_a "${vendorbootimg}"
	${FASTBOOT} flash vendor_boot_b "${vendorbootimg}"

	echo "Flashing Init Boot Image"
	${FASTBOOT} flash init_boot_a "${initbootimg}"
	${FASTBOOT} flash init_boot_b "${initbootimg}"

	echo "Flashing Userdata Image"
	${FASTBOOT} flash userdata "${userdataimg}"

	if [[ "${disable_avb}" == "true" ]]; then
		echo "Flashing vbmeta (AVB disabled)"
		${FASTBOOT} flash --disable-verity --disable-verification vbmeta_a "${vbmetaimg}"
		${FASTBOOT} flash --disable-verity --disable-verification vbmeta_b "${vbmetaimg}"
		echo "Flashing vbmeta_vendor_dlkm (AVB disabled)"
		${FASTBOOT} flash --disable-verity --disable-verification vbmeta_vendor_dlkm_a "${vbmetavendordlkmimg}"
		${FASTBOOT} flash --disable-verity --disable-verification vbmeta_vendor_dlkm_b "${vbmetavendordlkmimg}"
		echo "Flashing vbmeta_system_dlkm (AVB disabled)"
		${FASTBOOT} flash --disable-verity --disable-verification vbmeta_system_dlkm_a "${vbmetasystemdlkmimg}"
		${FASTBOOT} flash --disable-verity --disable-verification vbmeta_system_dlkm_b "${vbmetasystemdlkmimg}"
	else
		echo "Flashing vbmeta"
		${FASTBOOT} flash vbmeta_a "${vbmetaimg}"
		${FASTBOOT} flash vbmeta_b "${vbmetaimg}"
		echo "Flashing vbmeta_vendor_dlkm"
		${FASTBOOT} flash vbmeta_vendor_dlkm_a "${vbmetavendordlkmimg}"
		${FASTBOOT} flash vbmeta_vendor_dlkm_b "${vbmetavendordlkmimg}"
		echo "Flashing vbmeta_system_dlkm"
		${FASTBOOT} flash vbmeta_system_dlkm_a "${vbmetasystemdlkmimg}"
		${FASTBOOT} flash vbmeta_system_dlkm_b "${vbmetasystemdlkmimg}"
	fi

	echo "Flashing DTBO"
	${FASTBOOT} flash dtbo_a "${dtboimg}"
	${FASTBOOT} flash dtbo_b "${dtboimg}"

	echo "Flashing persist"
	${FASTBOOT} flash persist "${persistimg}"

	echo "Erasing misc"
	${FASTBOOT} erase misc

	echo "Flashing metadata"
	${FASTBOOT} flash metadata "${metadataimg}"

	echo "Flashing super"
	${FASTBOOT} flash super "${superimg}"

	rm -f "${bootloaderimg}"
	echo "-------------------------------"
	echo "Done. Run: fastboot reboot"
}

if [ "$0" = "${BASH_SOURCE[0]}" ]; then
	main "$@"
fi
