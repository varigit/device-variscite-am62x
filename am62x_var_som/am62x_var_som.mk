#
# Copyright 2026 Variscite Ltd. - https://www.variscite.com/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#

LOCAL_KERNEL_DIR := device/variscite/am62x-var-som-kernel

# Variscite inherits before TI so our PRODUCT_COPY_FILES win the first-wins
# dedup (filter-out doesn't work — _import-node clears product vars per node).
$(call inherit-product, device/variscite/am62x_var_som/device.mk)
$(call inherit-product, device/ti/am62x/am62x.mk)

PRODUCT_NAME         := am62x_var_som
PRODUCT_DEVICE       := am62x_var_som
PRODUCT_BRAND        := Variscite
PRODUCT_MODEL        := AOSP on VAR-SOM-AM62
PRODUCT_MANUFACTURER := Variscite

TARGET_SCREEN_DENSITY := 160
