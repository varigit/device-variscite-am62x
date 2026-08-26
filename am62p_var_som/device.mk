#
# Copyright 2026 Variscite Ltd. - https://www.variscite.com/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#

-include device/variscite/common/bootanimation/variscite_bootanimation_logo.mk

# NXP IW612 firmware — WLAN-only on SDIO + BT-only on UART. Avoids the
# combo blob which couples BT/WLAN through chip-side firmware arbitration.
NXP_IMX_FW_IW612 := vendor/nxp/imx-firmware/FwImage_IW612_SD
PRODUCT_COPY_FILES += \
	$(NXP_IMX_FW_IW612)/sd_w61x_v1.bin.se:vendor/firmware/nxp/sd_w61x_v1.bin.se \
	$(NXP_IMX_FW_IW612)/uartspi_n61x_v1.bin.se:vendor/firmware/nxp/uartspi_n61x_v1.bin.se

PRODUCT_COPY_FILES += \
	device/variscite/am62p_var_som/init.early_init.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.early_init.rc

# Fork of TI's ueventd.am62p.rc; adds backlight brightness perms for the
# lights HAL. Listed before TI's copy in the inherit chain, so it wins.
PRODUCT_COPY_FILES += \
	device/variscite/am62p_var_som/ueventd.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc

# Overrides TI's empty AAOS stub; PackageManager won't report FEATURE_BLUETOOTH otherwise.
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
	frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml

PRODUCT_PACKAGES += \
	android.hardware.bluetooth-service.default

PRODUCT_PACKAGES_DEBUG += \
	spidev_test

# IW612 has no LEA offload but expose the switcher.
PRODUCT_PRODUCT_PROPERTIES += \
	ro.bluetooth.leaudio_offload.supported=false \
	persist.bluetooth.leaudio_offload.disabled=false \
	ro.bluetooth.leaudio_switcher.supported=true

# Variscite init.optee.rc overrides TI's: starts tee-supplicant explicitly
# in `on fs` so it races vendor.keymint-optee in the early_hal class.
PRODUCT_COPY_FILES += \
	device/variscite/am62p_var_som/init.optee.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.optee.rc

# Symphony fork (PCM_16_BIT) of TI's audio_policy_configuration.xml.
PRODUCT_COPY_FILES += \
	device/variscite/am62p_var_som/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml

PRODUCT_VENDOR_PROPERTIES += \
	vendor.ti.audio.cardprefix=wm8904

PRODUCT_COPY_FILES += \
	device/variscite/am62p_var_som/camera/camera_hal.yaml:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/camera_hal.yaml

PRODUCT_COPY_FILES += \
	device/variscite/common/idc/generic_ft5x06.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/generic_ft5x06.idc \
	device/variscite/common/idc/generic_ft5x06.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/1-0038_generic_ft5x06.idc
