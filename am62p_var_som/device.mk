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
	frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
	frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml

# Variscite init.optee.rc overrides TI's: starts tee-supplicant explicitly
# in `on fs` so it races vendor.keymint-optee in the early_hal class.
PRODUCT_COPY_FILES += \
	device/variscite/am62p_var_som/init.optee.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.optee.rc

PRODUCT_COPY_FILES += \
	device/variscite/am62p_var_som/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml

PRODUCT_COPY_FILES += \
	device/variscite/am62p_var_som/camera/camera_hal.yaml:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/camera_hal.yaml
