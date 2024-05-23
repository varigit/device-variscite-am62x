#!/bin/bash
# Meant to be called by install_android.sh
set -e

. /usr/bin/echos.sh

som=""
avb_feature=1

if grep -q "AM62X" /sys/devices/soc0/family > /dev/null 2>&1; then
	node=/dev/mmcblk0
	som="am62x"
else
	red_bold_echo "ERROR: Unsupported board"
	exit 1
fi

imagesdir="/opt/images/Android"

usage()
{
	echo
	echo "This script installs Android on the SOM's internal storage device"
	echo
	echo " Usage: $(basename $0) <option>"
	echo
	echo " options:"
	echo " -h                show help message"
	echo " -u                install unsigned dtbo generated buuilding android with AVB feature disabled"
	echo
}

while getopts "hu" OPTION;
do
	case $OPTION in
	h)
		usage
		exit 0
		;;
	u)
		avb_feature=0
		;;
	*)
		usage
		exit 1
		;;
	esac
done

bootloader_file="bootloader-am62x-sk.img"
tiboot3bin_file="tiboot3-am62x-sk-hsfs.bin"
dtboimage_file="dtbo.img"
dtbouimage_file="dtbo-unsigned.img"
bootimage_file="boot.img"
vendor_bootimage_file="vendor_boot.img"
init_bootimage_file="init_boot.img"
vbmeta_file="vbmeta.img"
vbmeta_vendor_dlkm_file="vbmeta_vendor_dlkm.img"
superimage_file="super_raw.img.gz"
metadata_file="metadata.img"
presistimage_file="persist.img"

block=`basename $node`
part=""
if [[ $block == mmcblk* ]] ; then
	part="p"
fi

echo

function check_images
{
	if [[ ! -b $node ]] ; then
		red_bold_echo "ERROR: \"$node\" is not a block device"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${bootloader_file} ]] ; then
		red_bold_echo "ERROR: ${bootloader_file} image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${tiboot3bin_file} ]] ; then
		red_bold_echo "ERROR: ${tiboot3bin_file} image does not exist"
		exit 1
	fi

	if [[ ${avb_feature} -eq 1 ]]; then
		if [[ ! -f ${imagesdir}/${dtboimage_file} ]] ; then
			red_bold_echo "ERROR: ${dtboimage_file} image does not exist"
			exit 1
		fi
	else
		if [[ ! -f ${imagesdir}/${dtbouimage_file} ]] ; then
			red_bold_echo "ERROR: ${dtbouimage_file} image does not exist"
			exit 1
		fi
	fi

	if [[ ! -f ${imagesdir}/${bootimage_file} ]] ; then
		red_bold_echo "ERROR: ${bootimage_file} image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${vendor_bootimage_file} ]] ; then
		red_bold_echo "ERROR: ${vendor_bootimage_file} image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${init_bootimage_file} ]] ; then
		red_bold_echo "ERROR: ${init_bootimage_file} image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${superimage_file} ]] ; then
		red_bold_echo "ERROR: ${superimage_file} image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${metadata_file} ]] ; then
		red_bold_echo "ERROR: ${metadata_file} image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${presistimage_file} ]] ; then
		red_bold_echo "ERROR: ${presistimage_file} image does not exist"
		exit 1
	fi

	if [[ ${avb_feature} -eq 1 ]]; then
		if [[ ! -f ${imagesdir}/${vbmeta_file} ]] ; then
			red_bold_echo "ERROR: ${vbmeta_file} image does not exist"
			exit 1
		fi

		if [[ ! -f ${imagesdir}/${vbmeta_vendor_dlkm_file} ]] ; then
			red_bold_echo "ERROR: ${vbmeta_vendor_dlkm_file} image does not exist"
			exit 1
		fi
	fi
}

function delete_device
{
	echo
	blue_underlined_bold_echo "Deleting current partitions"
	for partition in `ls ${node}${part}* 2> /dev/null`
	do
		if [[ ${partition} = ${node} ]] ; then
			# skip base node
			continue
		fi
		if [[ ! -b ${partition} ]] ; then
			red_bold_echo "ERROR: \"${partition}\" is not a block device"
			exit 1
		fi
		dd if=/dev/zero of=${partition} bs=1M count=1 2> /dev/null || true
	done
	sync

	# Zero out environment
	echo 0 > /sys/block/mmcblk0boot0/force_ro
	dd if=/dev/zero of=/dev/mmcblk0boot0 bs=1K count=128 seek=1024 2>/dev/null || true
	echo 1 > /sys/block/mmcblk0boot0/force_ro

	((echo d; echo 1; echo d; echo 2; echo d; echo 3; echo d; echo w) | fdisk $node &> /dev/null) || true
	sync

	sgdisk -Z $node
	sync

	dd if=/dev/zero of=$node bs=1M count=8
	sync; sleep 1
}

function create_parts
{
	echo
	blue_underlined_bold_echo "Creating Android partitions"
	sgdisk -a 512 -n1:10240:+8M      -c 1:"bootloader"               -t 1:0700  $node
	sgdisk -a 512 -n2:8192:+1M       -c 2:"tiboot3"                  -t 2:0700  $node
	sgdisk -a 512 -n3:27648:+512K    -c 3:"misc"                     -t 3:0700  $node
	sgdisk -a 512 -n4:0:+512K        -c 4:"frp"                      -t 4:0700  $node
	sgdisk -a 512 -n5:0:+40M         -c 5:"boot_a"                   -t 5:0700  $node
	sgdisk -a 512 -n6:0:+40M         -c 6:"boot_b"                   -t 6:0700  $node
	sgdisk -a 512 -n7:0:+32M         -c 7:"vendor_boot_a"            -t 7:0700  $node
	sgdisk -a 512 -n8:0:+32M         -c 8:"vendor_boot_b"            -t 8:0700  $node
	sgdisk -a 512 -n9:0:+8M          -c 9:"init_boot_a"              -t 9:0700  $node
	sgdisk -a 512 -n10:0:+8M         -c 10:"init_boot_b"             -t 10:0700 $node
	sgdisk -a 512 -n11:0:+8M         -c 11:"dtbo_a"                  -t 11:0700 $node
	sgdisk -a 512 -n12:0:+8M         -c 12:"dtbo_b"                  -t 12:0700 $node
	sgdisk -a 512 -n13:0:+64K        -c 13:"vbmeta_a"                -t 13:0700 $node
	sgdisk -a 512 -n14:0:+64K        -c 14:"vbmeta_b"                -t 14:0700 $node
	sgdisk -a 512 -n15:0:+64K        -c 15:"vbmeta_vendor_dlkm_a"    -t 15:0700 $node
	sgdisk -a 512 -n16:0:+64K        -c 16:"vbmeta_vendor_dlkm_b"    -t 16:0700 $node
	sgdisk -a 512 -n17:0:+4608M      -c 17:"super"                   -t 17:0700 $node
	sgdisk -a 512 -n18:0:+64M        -c 18:"metadata"                -t 18:0700 $node
	sgdisk -a 512 -n19:0:+32M        -c 19:"persist"                 -t 19:0700 $node
	sgdisk -a 512 -n20:0:-0          -c 20:"userdata"                -t 20:0700 $node
	sync; sleep 2

	for i in `cat /proc/mounts | grep "${node}" | awk '{print $2}'`; do umount $i; done
	hdparm -z $node
	sync; sleep 3

	sgdisk -p $node
}

function install_bootloader
{
	echo
	blue_underlined_bold_echo "Installing booloader"

	dd if=${imagesdir}/${tiboot3bin_file} bs=1k of=${node}${part}2 conv=fsync; sync
	dd if=${imagesdir}/${bootloader_file} bs=1k of=${node}${part}1 conv=fsync; sync
}

function format_android
{
	blue_underlined_bold_echo "Erasing misc partition"
	dd if=/dev/zero of=${node}${part}3 bs=1k count=512 conv=fsync

	blue_underlined_bold_echo "Erasing userdata partition"
	dd if=/dev/zero of=${node}${part}20 bs=1k count=512 conv=fsync

	sync; sleep 1
}

function install_android
{
	echo
	blue_underlined_bold_echo "Installing Android boot image: $bootimage_file"
	dd if=${imagesdir}/${bootimage_file} of=${node}${part}5 bs=1M
	dd if=${imagesdir}/${bootimage_file} of=${node}${part}6 bs=1M
	sync

	echo
	blue_underlined_bold_echo "Installing Android vendor boot image: $vendor_bootimage_file"
	dd if=${imagesdir}/${vendor_bootimage_file} of=${node}${part}7 bs=1M
	dd if=${imagesdir}/${vendor_bootimage_file} of=${node}${part}8 bs=1M
	sync

	echo
	blue_underlined_bold_echo "Installing Android init boot image: $init_bootimage_file"
	dd if=${imagesdir}/${init_bootimage_file} of=${node}${part}9 bs=1M
	dd if=${imagesdir}/${init_bootimage_file} of=${node}${part}10 bs=1M
	sync

	echo
	if [[ ${avb_feature} -eq 1 ]]; then
		blue_underlined_bold_echo "Installing Android dtbo image: $dtboimage_file"
		dd if=${imagesdir}/${dtboimage_file} of=${node}${part}11 bs=1M
		dd if=${imagesdir}/${dtboimage_file} of=${node}${part}12 bs=1M
	else
		blue_underlined_bold_echo "Installing Android dtbo image: $dtbouimage_file"
		dd if=${imagesdir}/${dtbouimage_file} of=${node}${part}11 bs=1M
		dd if=${imagesdir}/${dtbouimage_file} of=${node}${part}12 bs=1M
	fi
	sync

	if [[ ${avb_feature} -eq 1 ]]; then
		echo
		blue_underlined_bold_echo "Installing Android vbmeta image: $vbmeta_file"
		dd if=${imagesdir}/${vbmeta_file} of=${node}${part}13 bs=1M
		dd if=${imagesdir}/${vbmeta_file} of=${node}${part}14 bs=1M
		sync;

		echo
		blue_underlined_bold_echo "Installing Android vbmeta vendor dlkm image: $vbmeta_vendor_dlkm_file"
		dd if=${imagesdir}/${vbmeta_vendor_dlkm_file} of=${node}${part}15 bs=1M
		dd if=${imagesdir}/${vbmeta_vendor_dlkm_file} of=${node}${part}16 bs=1M
		sync;
	fi

	blue_underlined_bold_echo "Installing metadata partition"
	dd if=${imagesdir}/${metadata_file} of=${node}${part}18 bs=1M conv=fsync

	blue_underlined_bold_echo "Installing presistdata partition"
	dd if=${imagesdir}/${presistimage_file} of=${node}${part}19 bs=1M conv=fsync

	echo
	blue_underlined_bold_echo "Installing Android super image: $superimage_file"
	zcat ${imagesdir}/${superimage_file} | dd of=${node}${part}17 bs=1M
	sync;

	sleep 1
}

function finish
{
	echo
	errors=0
	for partition in ${node}${part}*
	do
		if [[ ! -b ${partition} ]] ; then
			red_bold_echo "ERROR: \"${partition}\" is not a block device"
			errors=$((errors+1))
		fi
	done

	if [[ ${errors} = 0 ]] ; then
		blue_bold_echo "Android installed successfully"
	else
		red_bold_echo "Android installation failed"
	fi
	exit ${errors}
}

stop_udev()
{
        if [ -f /lib/systemd/system/systemd-udevd.service ]; then
                systemctl -q stop \
                        systemd-udevd-kernel.socket \
                        systemd-udevd-control.socket \
                        systemd-udevd
        fi
}

start_udev()
{
        if [ -f /lib/systemd/system/systemd-udevd.service ]; then
                systemctl -q start \
                        systemd-udevd-kernel.socket \
                        systemd-udevd-control.socket \
                        systemd-udevd
        fi
}

check_images

umount ${node}${part}*  2> /dev/null || true

stop_udev
delete_device
create_parts
install_bootloader
format_android
install_android
start_udev
finish
