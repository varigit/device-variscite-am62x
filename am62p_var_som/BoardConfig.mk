#
# Copyright 2026 Variscite Ltd. - https://www.variscite.com/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#

LOCAL_KERNEL_DIR     := device/variscite/am62p-var-som-kernel
BOOTLOADERS_BINARIES := vendor/variscite/am62x/bootloader/$(TARGET_BOOTLOADER_VERSION)/

TARGET_BOARD_PLATFORM        := am62p
TARGET_BOOTLOADER_BOARD_NAME := am62p_var_som

BOARD_USERDATAIMAGE_PARTITION_SIZE := 26744695808

BOARD_KERNEL_CMDLINE += cma=768M
BOARD_BOOTCONFIG     += androidboot.hardware=am62p

BOARD_LIST := am62p-var-som-symphony

# Indexed by U-Boot's adtb_idx; append, don't reorder.
#   0: symphony.dtb (default)
#   1: symphony-dual-clone-display.dtb
#   2: symphony-dual-independent-display.dtb
DTB_FILES = \
	$(LOCAL_DTB)/k3-am62p5-var-som-symphony.dtb \
	$(LOCAL_DTB)/k3-am62p5-var-som-symphony-dual-clone-display.dtb \
	$(LOCAL_DTB)/k3-am62p5-var-som-symphony-dual-independent-display.dtb

include device/ti/am62x/BoardConfig-common.mk

PRODUCT_COPY_FILES := $(filter-out device/ti/am62x/flashall.sh:%,$(PRODUCT_COPY_FILES))
PRODUCT_COPY_FILES += device/variscite/am62p_var_som/flashall.sh:$(TARGET_OUT)/flashall.sh

BOARD_SEPOLICY_DIRS += device/variscite/am62p_var_som/sepolicy/common
