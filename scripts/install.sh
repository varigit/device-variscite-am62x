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
readonly KERNEL_DIR="${ANDROID_DIR}/../ti-kernel-aosp"

## git variables get from base script!
readonly VAR_PATCHES_BRANCH="android16-release-var01"

## dirs ##
readonly VARISCITE_PATCHS_DIR="${SCRIPT_POINT}/platform"
readonly KERNEL_PATCHS_DIR="${SCRIPT_POINT}/platform-kernel"

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

# apply_patches - git am every patch set under a patches root onto its repo
# p1 - patches root; each <repo-path>.git/ dir holds the patches for that repo
# p2 - tree root the <repo-path> is relative to
function apply_patches() {
	local patches_dir=$1
	local tree_root=$2

	[ -d "${patches_dir}" ] || return 0

	cd ${patches_dir} > /dev/null
	local git_array=$(find * -type d 2>/dev/null | grep '.git' || true)
	cd - > /dev/null

	local _ddd _git_p _patch
	for _ddd in ${git_array}
	do
		_git_p=$(echo ${_ddd} | sed 's/.git//g')
		cd ${tree_root}/${_git_p}/ > /dev/null

		if [[ `git branch --list ${VAR_PATCHES_BRANCH}` ]] ; then
			git checkout ${VAR_PATCHES_BRANCH}
		else
			git checkout -b ${VAR_PATCHES_BRANCH}
		fi

		pr_info "Apply patches for this git: \"${_git_p}/\""
		for _patch in ${patches_dir}/${_ddd}/*
		do
			[ -e "${_patch}" ] || continue
			# A patch that reverse-applies cleanly is already in the
			# tree (e.g. re-running install.sh); skip it. Genuine
			# conflicts still fail git am and stop the script.
			if git apply --reverse --check "${_patch}" 2>/dev/null ; then
				pr_info "Already applied, skipping: ${_patch##*/}"
				continue
			fi
			git am "${_patch}"
		done

		cd - > /dev/null
	done
}

############### main code ##############
pr_info "Script version ${SCRIPT_VERSION} (g:20260514)"

pr_info "###########################"
pr_info "# Apply framework patches #"
pr_info "###########################"
apply_patches "${VARISCITE_PATCHS_DIR}" "${ANDROID_DIR}"

pr_info "########################"
pr_info "# Apply kernel patches #"
pr_info "########################"
apply_patches "${KERNEL_PATCHS_DIR}" "${KERNEL_DIR}"

pr_info "#####################"
pr_info "# Done             #"
pr_info "#####################"

exit 0
