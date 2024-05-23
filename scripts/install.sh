#!/bin/bash
#
# install
#
# This script must be run from the Android main directory.
#
# Variscite patches for Android 14 09_02_00

set -e
#set -x

SCRIPT_NAME=${0##*/}
readonly SCRIPT_VERSION="1.0"

#### Exports Variables ####
#### global variables ####
readonly ABSOLUTE_FILENAME=$(readlink -e "$0")
readonly ABSOLUTE_DIRECTORY=$(dirname ${ABSOLUTE_FILENAME})
readonly SCRIPT_POINT=${ABSOLUTE_DIRECTORY}
readonly SCRIPT_START_DATE=$(date +%Y%m%d)
readonly ANDROID_DIR="${SCRIPT_POINT}/../../.."
readonly TI_BOOTLOADER_AOSP_DIR="${ANDROID_DIR}/../ti-bootloader-aosp"
readonly G_CROSS_COMPILER_ARMv8_PATH=${TI_BOOTLOADER_AOSP_DIR}/toolchain/arm-gnu-toolchain-11.3.rel1-x86_64-aarch64-none-linux-gnu
readonly G_CROSS_COMPILER_ARMv8_ARCHIVE=arm-gnu-toolchain-11.3.rel1-x86_64-aarch64-none-linux-gnu.tar.xz
readonly G_CROSS_COMPILER_ARMv7_PATH=${TI_BOOTLOADER_AOSP_DIR}/toolchain/arm-gnu-toolchain-11.3.rel1-x86_64-arm-none-linux-gnueabihf
readonly G_CROSS_COMPILER_ARMv7_ARCHIVE=arm-gnu-toolchain-11.3.rel1-x86_64-arm-none-linux-gnueabihf.tar.xz
readonly G_CROSS_COMPILER_LINK=https://developer.arm.com/-/media/Files/downloads/gnu/11.3.rel1/binrel

## git variables get from base script!
readonly VAR_PATCHES_BRANCH="android14-release-var01"

## dirs ##
readonly VARISCITE_PATCHS_DIR="${SCRIPT_POINT}/platform"

# print error message
# p1 - printing string
function pr_error() {
	echo ${2} "E: $1"
}

# print warning message
# p1 - printing string
function pr_warning() {
	echo ${2} "W: $1"
}

# print info message
# p1 - printing string
function pr_info() {
	echo ${2} "I: $1"
}

# print debug message
# p1 - printing string
function pr_debug() {
	echo ${2} "D: $1"
}

############### main code ##############
pr_info "Script version ${SCRIPT_VERSION} (g:20240510)"

cd ${ANDROID_DIR} > /dev/null
pr_info "###########################"
pr_info "# Apply framework patches #"
pr_info "###########################"
cd ${VARISCITE_PATCHS_DIR} > /dev/null
git_array=$(find * -type d | grep '.git')
cd - > /dev/null

for _ddd in ${git_array}
do
	_git_p=$(echo ${_ddd} | sed 's/.git//g')
	cd ${ANDROID_DIR}/${_git_p}/ > /dev/null

	if [[ `git branch --list ${VAR_PATCHES_BRANCH}` ]] ; then
		git checkout ${VAR_PATCHES_BRANCH}
	else
		git checkout -b ${VAR_PATCHES_BRANCH}
	fi

	pr_info "Apply patches for this git: \"${_git_p}/\""
	git am ${VARISCITE_PATCHS_DIR}/${_ddd}/*

	cd - > /dev/null
done

pr_info "#######################"
pr_info "# Copy ARMv8 tool chain #"
pr_info "#######################"
# get ARMv8 toolchain
(( `ls ${G_CROSS_COMPILER_ARMv8_PATH} 2>/dev/null | wc -l` == 0 )) && {
	pr_info "Get and unpack ARMv8 cross compiler";
	mkdir -p ${TI_BOOTLOADER_AOSP_DIR}/toolchain/
	cd ${TI_BOOTLOADER_AOSP_DIR}/toolchain/
	wget ${G_CROSS_COMPILER_LINK}/${G_CROSS_COMPILER_ARMv8_ARCHIVE}
	tar -xJf ${G_CROSS_COMPILER_ARMv8_ARCHIVE} \
		-C .
};

pr_info "#######################"
pr_info "# Copy ARMv7 tool chain #"
pr_info "#######################"
# get ARMv8 toolchain
(( `ls ${G_CROSS_COMPILER_ARMv7_PATH} 2>/dev/null | wc -l` == 0 )) && {
	pr_info "Get and unpack ARMv7 cross compiler";
	mkdir -p ${TI_BOOTLOADER_AOSP_DIR}/toolchain/
	cd ${TI_BOOTLOADER_AOSP_DIR}/toolchain/
	wget ${G_CROSS_COMPILER_LINK}/${G_CROSS_COMPILER_ARMv7_ARCHIVE}
	tar -xJf ${G_CROSS_COMPILER_ARMv7_ARCHIVE} \
		-C .
};

pr_info "#####################"
pr_info "# Done             #"
pr_info "#####################"

exit 0
