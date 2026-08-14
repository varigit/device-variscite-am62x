#
# Copyright 2026 Variscite Ltd. - https://www.variscite.com/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#

LOCAL_KERNEL_DIR     := device/variscite/am62x-var-som-kernel
BOOTLOADERS_BINARIES := vendor/variscite/am62x/bootloader/$(TARGET_BOOTLOADER_VERSION)/

TARGET_BOARD_PLATFORM        := am62x
TARGET_BOOTLOADER_BOARD_NAME := am62x_var_som

BOARD_USERDATAIMAGE_PARTITION_SIZE := 10662838272

BOARD_KERNEL_CMDLINE += cma=512M
BOARD_KERNEL_CMDLINE += earlycon=ns16550a,mmio32,0x02800000
BOARD_KERNEL_CMDLINE += console=ttyS0,115200n8

BOARD_BOOTCONFIG     += androidboot.hardware=am62x

BOARD_LIST := am62-var-som-symphony

# Indexed by U-Boot's adtb_idx; append, don't reorder.
#   0: symphony.dtb (default)
DTB_FILES = \
	$(LOCAL_DTB)/k3-am625-var-som-symphony.dtb

include device/ti/am62x/BoardConfig-common.mk

# Drop TI's secondary console; on the Symphony carrier that UART is not
# the debug console (BT is a serdev on main_uart5 — printk on the wrong
# UART corrupts the firmware-download handshake).
BOARD_KERNEL_CMDLINE := $(filter-out console=ttyS2%,$(BOARD_KERNEL_CMDLINE))

PRODUCT_COPY_FILES := $(filter-out device/ti/am62x/flashall.sh:%,$(PRODUCT_COPY_FILES))
PRODUCT_COPY_FILES += device/variscite/am62x_var_som/flashall.sh:$(TARGET_OUT)/flashall.sh

BOARD_SEPOLICY_DIRS += device/variscite/am62x_var_som/sepolicy/common

BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE := device/variscite/am62x_var_som/modules.blocklist
