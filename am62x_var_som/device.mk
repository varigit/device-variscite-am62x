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

PRODUCT_COPY_FILES += \
	device/variscite/am62x_var_som/init.early_init.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.early_init.rc

# Sterling LWB / LWB5 (BCM43430 / BCM4339) WiFi + BT combo firmware.
BCM_FIRMWARE_PATH := vendor/variscite/bcm_4343w_fw/brcm
PRODUCT_COPY_FILES += \
	$(BCM_FIRMWARE_PATH)/BCM43430A1.hcd:$(TARGET_COPY_OUT_VENDOR)/firmware/brcm/BCM43430A1.hcd \
	$(BCM_FIRMWARE_PATH)/brcmfmac43430-sdio.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/brcm/brcmfmac43430-sdio.bin \
	$(BCM_FIRMWARE_PATH)/brcmfmac43430-sdio.txt:$(TARGET_COPY_OUT_VENDOR)/firmware/brcm/brcmfmac43430-sdio.txt \
	$(BCM_FIRMWARE_PATH)/brcmfmac43430-sdio.clm_blob:$(TARGET_COPY_OUT_VENDOR)/firmware/brcm/brcmfmac43430-sdio.clm_blob \
	$(BCM_FIRMWARE_PATH)/BCM4335C0.hcd:$(TARGET_COPY_OUT_VENDOR)/firmware/brcm/BCM4335C0.hcd \
	$(BCM_FIRMWARE_PATH)/brcmfmac4339-sdio.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/brcm/brcmfmac4339-sdio.bin \
	$(BCM_FIRMWARE_PATH)/brcmfmac4339-sdio.txt:$(TARGET_COPY_OUT_VENDOR)/firmware/brcm/brcmfmac4339-sdio.txt

# Overrides TI's empty AAOS stub; PackageManager won't report FEATURE_BLUETOOTH otherwise.
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
	frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml

PRODUCT_PACKAGES += \
	android.hardware.bluetooth-service.default

# Re-enable Wi-Fi after brcmfmac bounces wlan0 on resume from suspend.
PRODUCT_PACKAGES += \
	WifiAm62VarSomOverlay

PRODUCT_PACKAGES_DEBUG += \
	spidev_test

# BCM43430/4339 have no LE Audio offload.
PRODUCT_PRODUCT_PROPERTIES += \
	ro.bluetooth.leaudio_offload.supported=false \
	persist.bluetooth.leaudio_offload.disabled=false

PRODUCT_COPY_FILES += \
	device/variscite/am62x_var_som/init.optee.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.optee.rc

# Symphony fork (PCM_16_BIT) of TI's audio_policy_configuration.xml.
PRODUCT_COPY_FILES += \
	device/variscite/am62x_var_som/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml

PRODUCT_VENDOR_PROPERTIES += \
	vendor.ti.audio.cardprefix=wm8904

PRODUCT_COPY_FILES += \
	device/variscite/am62x_var_som/camera/camera_hal.yaml:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/camera_hal.yaml

PRODUCT_COPY_FILES += \
	device/variscite/common/idc/generic_ft5x06.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/generic_ft5x06.idc \
	device/variscite/common/idc/generic_ft5x06.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/1-0038_generic_ft5x06.idc
