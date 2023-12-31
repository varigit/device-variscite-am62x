#!/bin/bash
# Meant to be called by install_android.sh
set -e

. /usr/bin/echos.sh

som=""
sdshared=false
img_list=()
if grep -q "AM62X" /sys/devices/soc0/family > /dev/null 2>&1; then
	node=/dev/mmcblk0
	som="am62x"
else
	red_bold_echo "ERROR: Unsupported board"
	exit 1
fi

imagesdir="/opt/images/Android"
soc_name="showoptions"

function help() {

	bn=`basename $0`
	echo " usage $bn <option>"
	echo
	echo " options:"
	echo " -h			displays this help message"
	echo " -f soc_name		flash android image [optional]."
}

moreoptions=1
while [ "$moreoptions" = 1 -a $# -gt 0 ]; do
	case $1 in
		-h) help; exit ;;
		-f) soc_name=$2; shift ;;
		*)  moreoptions=0 ;;
	esac
	[ "$moreoptions" = 0 ] && [ $# -gt 2 ] && help && exit
	[ "$moreoptions" = 1 ] && shift
done

function add_am62x_menu() {
	img_list+=("dtbo.img                            (VAR-SOM-AM62 on Symphony-Board, with LVDS support)")
}
#Prepare the menu based on SOM
case $som in
	"am62x")
		add_am62x_menu;;
	*)
		echo "Invalid SOM"; exit;;
esac

min=0
max=$(( ${#img_list[@]} -1 ))
img_prefix="dtbo"
while [[ min -lt max ]]
do
    # Swap current first and last elements
    x="${img_list[$min]}"
    img_list[$min]="${img_list[$max]}"
    img_list[$max]="$x"

    # Move closer
    (( min++, max-- ))
done

# check for dtb
if [[ $soc_name != "showoptions" ]] && [[ ! ${img_list[@]} =~ $soc_name ]] ; then
	echo; red_bold_echo "ERROR: invalid dtb $soc_name"
	soc_name=showoptions
fi

if [[ $soc_name == "showoptions" ]] && [[ ${#img_list[@]} == 1 ]] ; then
	soc_name=${img_list[0]};
fi

if [[ $soc_name == "showoptions" ]] && [[ ${#img_list[@]} > 1 ]] ; then
	PS3='Please choose the correct dtbo image for your board configuration: '
	COLUMNS=20
	select opt in "${img_list[@]}"
	do
		if [[ -z "$opt" ]] ; then
			echo invalid option
			continue
		else
			if grep -q "AM62X" /sys/devices/soc0/soc_id; then
				soc_name=`echo $opt | cut -d "." -f1`
				soc_name=`echo ${soc_name} | sed "s/${img_prefix}//"`
			else
				soc_name=$opt
			fi
			break
		fi
	done
fi

dtboimage_file="dtbo.img"
bootimage_file="boot.img"
vbmeta_file="vbmeta.img"
superimage_file="super.raw.gz"
presistimage_file="persist.img"
bootloader_file="bootloader-am62x-sk.img"
tiboot3bin_file="tiboot3-am62x-sk-hsfs.bin"

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


	if [[ ! -f ${imagesdir}/${dtboimage_file} ]] ; then
		red_bold_echo "ERROR: ${dtboimage_file} image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${bootimage_file} ]] ; then
		red_bold_echo "ERROR: ${bootimage_file} image does not exist"
		exit 1
	fi
	
	if [[ ! -f ${imagesdir}/${superimage_file} ]] ; then
		red_bold_echo "ERROR: ${superimage_file} image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${vbmeta_file} ]] ; then
		red_bold_echo "ERROR: ${vbmeta_file} image does not exist"
		exit 1
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
        sgdisk -a 512 -n1:10240:+8M           -c 1:"bootloader"  -t 1:0700  $node
        sgdisk -a 512 -n2:8192:+1M            -c 2:"tiboot3"     -t 2:0700  $node
        sgdisk -a 512 -n3:0:+512K             -c 3:"uboot-env"   -t 3:0700  $node
        sgdisk -a 512 -n4:27648:+512K         -c 4:"misc"        -t 4:0700  $node
        sgdisk -a 512 -n5:0:+40M              -c 5:"boot_a"      -t 5:0700  $node
        sgdisk -a 512 -n6:0:+40M              -c 6:"boot_b"      -t 6:0700  $node
        sgdisk -a 512 -n7:0:+8M               -c 7:"dtbo_a"      -t 7:0700  $node
        sgdisk -a 512 -n8:0:+8M               -c 8:"dtbo_b"      -t 8:0700  $node
        sgdisk -a 512 -n9:0:+64K              -c 9:"vbmeta_a"    -t 9:0700  $node
        sgdisk -a 512 -n10:0:+64K             -c 10:"vbmeta_b"   -t 10:0700 $node
        sgdisk -a 512 -n11:0:+4608M           -c 11:"super"      -t 11:0700 $node
        sgdisk -a 512 -n12:0:+16M             -c 12:"metadata"   -t 12:0700 $node
        sgdisk -a 512 -n13:0:+32M             -c 13:"persist"    -t 13:0700 $node
        sgdisk -a 512 -n14:0:-0               -c 14:"userdata"   -t 14:0700 $node
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

	dd if=${imagesdir}/${bootloader_file} bs=1k of=${node}${part}1 conv=fsync; sync
	dd if=${imagesdir}/${tiboot3bin_file} bs=1k of=${node}${part}2 conv=fsync; sync

}

function format_android
{
	blue_underlined_bold_echo "Erasing presistdata partition"
	dd if=${imagesdir}/${presistimage_file} of=${node}${part}13 bs=1M conv=fsync

	blue_underlined_bold_echo "Erasing misc partition"
	dd if=/dev/zero of=${node}${part}4 bs=1k count=512 conv=fsync

	blue_underlined_bold_echo "Erasing metadata partition"
	mkfs.ext4 -F ${node}${part}12 -Lmetadata

	# For Android 13.0.0_1.2.0 encryption otpion is must
	blue_underlined_bold_echo "Formating userdata partition"
	mkfs.f2fs -f ${node}${part}14  -O encrypt -l userdata

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
	blue_underlined_bold_echo "Installing Android dtbo image: $dtboimage_file"
	dd if=${imagesdir}/${dtboimage_file} of=${node}${part}7 bs=1M
	dd if=${imagesdir}/${dtboimage_file} of=${node}${part}8 bs=1M
	sync

	echo
	blue_underlined_bold_echo "Installing Android vbmeta image: $vbmeta_file"
	dd if=${imagesdir}/${vbmeta_file} of=${node}${part}9 bs=1M
	dd if=${imagesdir}/${vbmeta_file} of=${node}${part}10 bs=1M
	sync;

	echo
	blue_underlined_bold_echo "Installing Android super image: $superimage_file"
	zcat ${imagesdir}/${superimage_file} | dd of=${node}${part}11 bs=1M
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
