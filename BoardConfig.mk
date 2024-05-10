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

TARGET_BOARD_PLATFORM := am62x_var_som
TARGET_BOOTLOADER_BOARD_NAME := am62x_var_som

# AVB
ifeq ($(TARGET_BUILD_VARIANT), user)
TARGET_AVB_ENABLE := true
endif

ifeq ($(TARGET_AVB_ENABLE), true)
BOARD_AVB_ENABLE := true
else
BOARD_AVB_ENABLE := false
endif
# BT configs
BOARD_HAVE_BLUETOOTH := true
# Primary Arch
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a53

# Secondary Arch
TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a53

TARGET_IS_64_BIT := true
TARGET_USES_64_BIT_BINDER := true

BOARD_USES_METADATA_PARTITION := true

# Treble
PRODUCT_FULL_TREBLE := true
BOARD_VNDK_VERSION := current
TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := false

# AB support
BOARD_USES_RECOVERY_AS_BOOT := true
TARGET_NO_RECOVERY := true

AB_OTA_UPDATER := true

AB_OTA_PARTITIONS := \
    boot \
    dtbo \
    system \
    vendor

ifeq ($(TARGET_AVB_ENABLE), true)
AB_OTA_PARTITIONS += vbmeta
endif

# FS Configuration
BOARD_BOOTIMAGE_PARTITION_SIZE := 41943040 # 40MiB
BOARD_PREBUILT_DTBOIMAGE := device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/dtbo.img
BOARD_DTBOIMG_PARTITION_SIZE := 8388608 # 8 MiB
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE ?= ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_PARTITION_SIZE := 10696523776
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
TARGET_USERIMAGES_USE_F2FS := true
TARGET_COPY_OUT_VENDOR := vendor

# Super partition
TARGET_USE_DYNAMIC_PARTITIONS := true
BOARD_BUILD_SUPER_IMAGE_BY_DEFAULT := true
BOARD_SUPER_PARTITION_GROUPS := db_dynamic_partitions
BOARD_DB_DYNAMIC_PARTITIONS_PARTITION_LIST := system vendor
BOARD_SUPER_PARTITION_SIZE := 4831838208
BOARD_DB_DYNAMIC_PARTITIONS_SIZE := 2411724800
BOARD_SUPER_PARTITION_METADATA_DEVICE := super

TARGET_SCREEN_DENSITY ?= 160

# Recovery
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_FSTAB := device/variscite/am62x_var_som/fstab.am62x
TARGET_RECOVERY_WIPE := device/variscite/am62x_var_som/recovery.wipe


BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_KERNEL_OFFSET      := 0x82000000
BOARD_RAMDISK_OFFSET := 0xd0000000
BOARD_MKBOOTIMG_ARGS := --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --header_version 2
BOARD_KERNEL_CMDLINE += no_console_suspend androidboot.vendor.sysrq=1 service_locator.enable=1 earlycon=ns16550a,mmio32,0x02800000 consoleblank=0 androidboot.first_stage_console=1
BOARD_KERNEL_CMDLINE += console=ttyS0,115200n8 androidboot.console=ttyS0 printk.devkmsg=on
ifeq ($(TARGET_SDCARD_BOOT), true)
BOARD_KERNEL_CMDLINE += androidboot.boot_devices=bus@f0000/fa00000.mmc
else
BOARD_KERNEL_CMDLINE += androidboot.boot_devices=bus@f0000/fa10000.mmc
endif
BOARD_KERNEL_CMDLINE += init=/init
BOARD_KERNEL_CMDLINE += cma=640M
BOARD_KERNEL_CMDLINE += firmware_class.path=/vendor/firmware
BOARD_KERNEL_CMDLINE += androidboot.hardware=am62x 8250.nr_uarts=10
BOARD_KERNEL_CMDLINE += mem_sleep_default=deep
BOARD_KERNEL_CMDLINE += loop.max_part=7

DEVICE_MANIFEST_FILE := device/variscite/am62x_var_som/manifest.xml

BOARD_SEPOLICY_DIRS += device/variscite/am62x_var_som/sepolicy/common/ device/variscite/am62/sepolicy/common
ifeq ($(TARGET_SDCARD_BOOT), true)
BOARD_SEPOLICY_DIRS += device/variscite/am62x_var_som/sepolicy/sdcard/
else
BOARD_SEPOLICY_DIRS += device/variscite/am62x_var_som/sepolicy/mmc/
endif
PRODUCT_PRIVATE_SEPOLICY_DIRS += device/variscite/am62x_var_som/sepolicy-private

# Copy Bootloader prebuilts and prebuilts images
PRODUCT_COPY_FILES += \
        vendor/variscite/am62x_var_som/bootloader/am62x-sk/tiboot3.bin:$(TARGET_OUT)/tiboot3-am62x-sk.bin \
        vendor/variscite/am62x_var_som/bootloader/am62x-sk/tiboot3-hsfs.bin:$(TARGET_OUT)/tiboot3-am62x-sk-hsfs.bin \
        vendor/variscite/am62x_var_som/bootloader/am62x-sk/tispl.bin:$(TARGET_OUT)/tispl-am62x-sk.bin \
        vendor/variscite/am62x_var_som/bootloader/am62x-sk/u-boot.img:$(TARGET_OUT)/u-boot-am62x-sk.img \
        vendor/variscite/am62x_var_som/bootloader/am62x-sk-dfu/tiboot3.bin:$(TARGET_OUT)/tiboot3-am62x-sk-dfu.bin \
        vendor/variscite/am62x_var_som/bootloader/am62x-sk-dfu/tiboot3-hsfs.bin:$(TARGET_OUT)/tiboot3-am62x-sk-dfu-hsfs.bin \
        vendor/variscite/am62x_var_som/bootloader/am62x-sk-dfu/tispl.bin:$(TARGET_OUT)/tispl-am62x-sk-dfu.bin \
        vendor/variscite/am62x_var_som/bootloader/am62x-sk-dfu/u-boot.img:$(TARGET_OUT)/u-boot-am62x-sk-dfu.img \
        vendor/variscite/am62x_var_som/binaries/persist.img:$(TARGET_OUT)/persist.img \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/dtbo.img:$(TARGET_OUT)/dtbo-unsigned.img

# Copy Android Flashing Script
PRODUCT_COPY_FILES += \
        device/variscite/am62x_var_som/flashall.sh:$(TARGET_OUT)/flashall.sh \

# Copy snagrecover config file
PRODUCT_COPY_FILES += \
        device/variscite/am62x_var_som/config/dfu/am62x-sk-evm.yaml:$(TARGET_OUT)/am62x-sk-evm.yaml

# Copy kernel modules into /vendor/lib/modules
BOARD_ALL_MODULES := $(shell find device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE) -type f -iname '*.ko')
BOARD_VENDOR_KERNEL_MODULES += $(BOARD_ALL_MODULES)

# USB Hal
BOARD_SEPOLICY_DIRS += \
        hardware/ti/am62x/usb/1.2/sepolicy

ifeq ($(TARGET_AVB_ENABLE), true)
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA2048
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 2
endif

# Audio HAL
BOARD_USES_TINYHAL_AUDIO := true
TINYALSA_NO_ADD_NEW_CTRLS := true
TINYALSA_NO_CTL_GET_ID := true
TINYCOMPRESS_TSTAMP_IS_LONG := true

# -------@block_wifi-------
BOARD_WLAN_DEVICE            := bcmdhd
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211
BOARD_HOSTAPD_PRIVATE_LIB               := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

WIFI_HIDL_FEATURE_DUAL_INTERFACE := false

# -------@block_bluetooth-------
# Broadcom BT
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/variscite/am62x_var_som/bluetooth
BOARD_CUSTOM_BT_CONFIG := $(BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR)/vnd_config.txt
BOARD_HAVE_BLUETOOTH_BCM := true


BOARD_VENDOR_RAMDISK_KERNEL_MODULES += \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/zsmalloc.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/zram.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/ti-msgmgr.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/ti_sci.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/ti_sci_pm_domains.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/phy-omap-usb2.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/syscon-clk.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/tee.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/k3-ringacc.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/irq-ti-sci-intr.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/sci-clk.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/k3-psil-lib.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/k3-udma.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/reset-ti-sci.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/irq-ti-sci-inta.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/reset-ti-syscon.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/k3-udma-glue.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/rtc-ti-k3.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/optee-rng.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/sa2ul.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/cma_heap.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/system_heap.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/gpio-davinci.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/gpio-pca953x.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/gpio-regulator.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/drm_dma_helper.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/omap_hwspinlock.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/i2c-omap.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/i2c-mux.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/i2c-mux-pca954x.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/ili210x.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/irq-pruss-intc.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/leds-tlc591xx.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/omap-mailbox.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/palmas.ko \
	device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/pwrseq_emmc.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/sdhci_am654.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/adin.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/at803x.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/mux-core.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/mux-mmio.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/davinci_mdio.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/mdio-bitbang.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/mdio-gpio.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/cdns-dphy-rx.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/cdns-dphy.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/phy-cadence-torrent.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/phy-can-transceiver.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/phy-gmii-sel.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/phy-j721e-wiz.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/pwm-tiecap.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/pwm-tiehrpwm.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/palmas-regulator.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/pru_rproc.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/ti_k3_common.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/ti_k3_dsp_remoteproc.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/ti_k3_m4_remoteproc.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/ti_k3_r5_remoteproc.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/rpmsg_kdrv.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/rpmsg_kdrv_switch.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/rpmsg_ns.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/virtio_rpmsg_bus.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/pruss.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/spi-cadence-quadspi.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/spi-omap2-mcspi.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/optee.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/k3_bandgap.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/k3_j72xx_bandgap.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/dwc3-am62.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/dwc3-haps.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/dwc3-of-simple.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/tps6598x.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/rti_wdt.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/i2c-dev.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/tidss.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/sii902x.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/display-connector.ko \
        device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/panel-simple.ko \
	device/variscite/am62x-kernel/kernel/$(TARGET_KERNEL_USE)/pwm_bl.ko

BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD +=  $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES)
