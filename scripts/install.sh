#!/bin/bash
#
# install
#
# This script must be run from the Android main directory.
#
# Variscite patches for Android 16 11_00_01

set -e
#set -x

SCRIPT_NAME=${0##*/}
readonly SCRIPT_VERSION="2.0"

#### Exports Variables ####
#### global variables ####
readonly ABSOLUTE_FILENAME=$(readlink -e "$0")
readonly ABSOLUTE_DIRECTORY=$(dirname ${ABSOLUTE_FILENAME})
readonly SCRIPT_POINT=${ABSOLUTE_DIRECTORY}
readonly SCRIPT_START_DATE=$(date +%Y%m%d)
readonly ANDROID_DIR="${SCRIPT_POINT}/../../.."

## git variables get from base script!
readonly VAR_PATCHES_BRANCH="android16-release-var01"

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
pr_info "Script version ${SCRIPT_VERSION} (g:20260512)"

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

pr_info "#####################"
pr_info "# Done             #"
pr_info "#####################"

exit 0
