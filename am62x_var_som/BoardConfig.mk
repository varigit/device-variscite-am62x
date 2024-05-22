#
# Copyright 2022 Texas Instruments Incorporated - http://www.ti.com/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Primary Arch
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := cortex-a53

TARGET_IS_64_BIT := false
TARGET_USES_64_BIT_BINDER := true
# Disable 64 bit mediadrmserver
TARGET_ENABLE_MEDIADRM_64 :=

TARGET_BOARD_PLATFORM := am62x_var_som
TARGET_BOOTLOADER_BOARD_NAME := am62x_var_som

BOARD_USERDATAIMAGE_PARTITION_SIZE := 10662838272
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs

ifneq ($(TARGET_BUILD_VARIANT), user)
BOARD_KERNEL_CMDLINE += console=ttyS0,115200
endif
ifeq ($(TARGET_SDCARD_BOOT), true)
BOARD_BOOTCONFIG += androidboot.boot_devices=bus@f0000/fa00000.mmc
else
BOARD_BOOTCONFIG += androidboot.boot_devices=bus@f0000/fa10000.mmc
endif
BOARD_KERNEL_CMDLINE += cma=512M
BOARD_KERNEL_CMDLINE += 8250.nr_uarts=10

BOARD_BOOTCONFIG += androidboot.hardware=am62x

# Copy Bootloader prebuilts and prebuilts images
PRODUCT_COPY_FILES += \
        vendor/ti/am62x/bootloader/am62x-sk/tiboot3.bin:$(TARGET_OUT)/tiboot3-am62x-sk.bin \
        vendor/ti/am62x/bootloader/am62x-sk/tiboot3-hsfs.bin:$(TARGET_OUT)/tiboot3-am62x-sk-hsfs.bin \
        vendor/ti/am62x/bootloader/am62x-sk/tispl.bin:$(TARGET_OUT)/tispl-am62x-sk.bin \
        vendor/ti/am62x/bootloader/am62x-sk/u-boot.img:$(TARGET_OUT)/u-boot-am62x-sk.img \
        vendor/ti/am62x/bootloader/am62x-sk-dfu/tiboot3.bin:$(TARGET_OUT)/tiboot3-am62x-sk-dfu.bin \
        vendor/ti/am62x/bootloader/am62x-sk-dfu/tiboot3-hsfs.bin:$(TARGET_OUT)/tiboot3-am62x-sk-dfu-hsfs.bin \
        vendor/ti/am62x/bootloader/am62x-sk-dfu/tispl.bin:$(TARGET_OUT)/tispl-am62x-sk-dfu.bin \
        vendor/ti/am62x/bootloader/am62x-sk-dfu/u-boot.img:$(TARGET_OUT)/u-boot-am62x-sk-dfu.img

# Copy snagrecover config file
PRODUCT_COPY_FILES += \
        device/ti/am62x/config/dfu/am62x-sk-evm.yaml:$(TARGET_OUT)/am62x-sk-evm.yaml \
        device/ti/am62x/config/dfu/am62x-sk-evm-hsfs.yaml:$(TARGET_OUT)/am62x-sk-evm-hsfs.yaml

# AVB
ifeq ($(TARGET_BUILD_VARIANT), user)
TARGET_AVB_ENABLE := true
endif

ifeq ($(TARGET_AVB_ENABLE), true)
BOARD_AVB_ENABLE := true
BOARD_AVB_ALGORITHM := SHA256_RSA4096
BOARD_AVB_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
else
BOARD_AVB_ENABLE := false
endif
# BT configs
BOARD_HAVE_BLUETOOTH := true

BOARD_USES_METADATA_PARTITION := true

# Treble
PRODUCT_FULL_TREBLE := true
BOARD_VNDK_VERSION := current
TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := false

# AB support
TARGET_NO_RECOVERY := true

# Recovery
TARGET_RECOVERY_FSTAB_GENRULE := gen_fstab_am62_mmc

AB_OTA_UPDATER := true

AB_OTA_PARTITIONS := \
    boot \
    dtbo \
    system \
    vendor \
    vendor_boot \
    init_boot \
    vendor_dlkm

ifeq ($(TARGET_AVB_ENABLE), true)
AB_OTA_PARTITIONS += vbmeta
endif

# FS Configuration
BOARD_BOOTIMAGE_PARTITION_SIZE := 41943040 # 40MiB
BOARD_PREBUILT_DTBOIMAGE := device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/dtbo.img
BOARD_DTBOIMG_PARTITION_SIZE := 8388608 # 8 MiB
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE ?= ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
TARGET_USERIMAGES_USE_F2FS := true
TARGET_COPY_OUT_VENDOR := vendor

# Vendor boot partition
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 33554432

# Super partition
TARGET_USE_DYNAMIC_PARTITIONS := true
BOARD_BUILD_SUPER_IMAGE_BY_DEFAULT := true
BOARD_SUPER_PARTITION_GROUPS := db_dynamic_partitions
BOARD_DB_DYNAMIC_PARTITIONS_PARTITION_LIST := system vendor
BOARD_SUPER_PARTITION_SIZE := 4831838208
BOARD_DB_DYNAMIC_PARTITIONS_SIZE := 2411724800

# Vendor DLKM partition
BOARD_USES_VENDOR_DLKMIMAGE := true
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm
BOARD_DB_DYNAMIC_PARTITIONS_PARTITION_LIST += vendor_dlkm

TARGET_SCREEN_DENSITY ?= 160

# Recovery
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_WIPE := device/ti/am62x/recovery.wipe

# Boot Image v4 support
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true

# GKI-related variables.
BOARD_USES_GENERIC_KERNEL_IMAGE := true

# No recovery
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE :=

BOARD_BOOT_HEADER_VERSION := 4
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_KERNEL_OFFSET      := 0x82000000
BOARD_RAMDISK_OFFSET := 0xd0000000
BOARD_RAMDISK_USE_LZ4 := true
BOARD_MKBOOTIMG_ARGS := --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --pagesize 4096

BOARD_BOOTCONFIG += androidboot.load_modules_parallel=true

#fstab
ifeq ($(TARGET_SDCARD_BOOT), true)
ifeq ($(TARGET_AVB_ENABLE), true)
BOARD_BOOTCONFIG += androidboot.fstab_suffix=am62.sdcard.avb
else
BOARD_BOOTCONFIG += androidboot.fstab_suffix=am62.sdcard
endif
else
ifeq ($(TARGET_AVB_ENABLE), true)
BOARD_BOOTCONFIG += androidboot.fstab_suffix=am62.mmc.avb
else
BOARD_BOOTCONFIG += androidboot.fstab_suffix=am62.mmc
endif
endif

# Init Boot partition
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 0x800000
BOARD_MKBOOTIMG_INIT_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)

ifneq ($(TARGET_BUILD_VARIANT), user)
BOARD_KERNEL_CMDLINE += printk.devkmsg=on
endif
BOARD_KERNEL_CMDLINE += init=/init
BOARD_KERNEL_CMDLINE += firmware_class.path=/vendor/firmware
BOARD_KERNEL_CMDLINE += mem_sleep_default=deep 

DEVICE_MANIFEST_FILE += device/ti/am62x/manifest.xml
DEVICE_PRODUCT_COMPATIBILITY_MATRIX_FILE += device/ti/am62x/framework_compatibility_matrix.xml

BOARD_SEPOLICY_DIRS += device/variscite/am62x_var_som/sepolicy/common/
ifeq ($(TARGET_SDCARD_BOOT), true)
BOARD_SEPOLICY_DIRS += device/ti/am62x/sepolicy/sdcard/
else
BOARD_SEPOLICY_DIRS += device/ti/am62x/sepolicy/mmc/
endif
PRODUCT_PRIVATE_SEPOLICY_DIRS += device/ti/am62x/sepolicy-private

# Copy Bootloader prebuilts and prebuilts images
PRODUCT_COPY_FILES += \
        vendor/ti/am62x/binaries/persist.img:$(TARGET_OUT)/persist.img \
        vendor/ti/am62x/binaries/metadata.img:$(TARGET_OUT)/metadata.img \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/dtbo.img:$(TARGET_OUT)/dtbo-unsigned.img

# Copy Android Flashing Script
PRODUCT_COPY_FILES += \
        device/ti/am62x/flashall.sh:$(TARGET_OUT)/flashall.sh

# Boot Animation
PRODUCT_COPY_FILES += \
    device/variscite/common/bootanimation/bootanimation-var1280.zip:system/media/bootanimation.zip

# Copy kernel modules into /vendor/lib/modules
BOARD_ALL_MODULES := $(shell find device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE) -type f -iname '*.ko')
BOARD_VENDOR_KERNEL_MODULES += $(BOARD_ALL_MODULES)

# USB Hal
BOARD_SEPOLICY_DIRS += \
        hardware/ti/am62x/usb/1.2/sepolicy

ifeq ($(TARGET_AVB_ENABLE), true)
# Enable chained vbmeta for boot images
BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_BOOT_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 2

# Enable chained vbmeta for init_boot images
BOARD_AVB_INIT_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_INIT_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_INIT_BOOT_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_INIT_BOOT_ROLLBACK_INDEX_LOCATION := 3

# Enabled chained vbmeta for vendor_dlkm
BOARD_AVB_VBMETA_CUSTOM_PARTITIONS := vendor_dlkm
BOARD_AVB_VBMETA_VENDOR_DLKM := vendor_dlkm
BOARD_AVB_VBMETA_VENDOR_DLKM_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_VBMETA_VENDOR_DLKM_ALGORITHM := SHA256_RSA4096
BOARD_AVB_VBMETA_VENDOR_DLKM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_VENDOR_DLKM_ROLLBACK_INDEX_LOCATION := 4

BOARD_AVB_SYSTEM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
endif

# Audio HAL
BOARD_USES_TINYHAL_AUDIO := true
TINYALSA_NO_ADD_NEW_CTRLS := true
TINYALSA_NO_CTL_GET_ID := true
TINYCOMPRESS_TSTAMP_IS_LONG := true

# wifi
BOARD_WLAN_DEVICE := bcmdhd
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_HOSTAPD_DRIVER := NL80211
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true
WIFI_HIDL_FEATURE_DUAL_INTERFACE := true

BOARD_VENDOR_RAMDISK_KERNEL_MODULES += \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/8250_omap.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/zsmalloc.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/zram.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/cma_heap.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/system_heap.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/omap-mailbox.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/ti-msgmgr.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/k3-psil-lib.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/k3-udma.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/k3-udma-glue.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/k3-ringacc.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/libarc4.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/irq-ti-sci-inta.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/irq-ti-sci-intr.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/irq-pruss-intc.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/ti_sci.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/ti_sci_pm_domains.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/syscon-clk.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/tee.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/sci-clk.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/reset-ti-sci.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/reset-ti-syscon.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/rtc-ti-k3.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/optee-rng.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/sa2ul.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/gpio-davinci.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/gpio-pca953x.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/gpio-regulator.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/drm_dma_helper.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/omap_hwspinlock.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/i2c-omap.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/i2c-mux.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/i2c-mux-pca954x.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/i2c-dev.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/ili210x.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/phy-omap-usb2.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/palmas.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/pwrseq_emmc.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/pwrseq_simple.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/sdhci_am654.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/mux-core.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/mux-mmio.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/davinci_mdio.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/mdio-bitbang.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/mdio-gpio.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/cdns-dphy-rx.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/cdns-dphy.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/phy-cadence-torrent.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/phy-can-transceiver.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/phy-gmii-sel.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/phy-j721e-wiz.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/palmas-regulator.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/optee.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/k3_bandgap.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/k3_j72xx_bandgap.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/dwc3-am62.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/dwc3-haps.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/dwc3-of-simple.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/tps6598x.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/rti_wdt.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/tidss.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/display-connector.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/adin.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/panel-simple.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/sii902x.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/ite-it66121.ko  \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/tps65219.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/tps65219-pwrbutton.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/tps65219-regulator.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/pwm_bl.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/at803x.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/rtc-ds1307.ko \
        device/ti/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/usb-conn-gpio.ko

BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD +=  $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES)

BOARD_VENDOR_KERNEL_MODULES_LOAD += $(BOARD_VENDOR_KERNEL_MODULES)
