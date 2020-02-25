# Copyright (C) 2013 The Android Open Source Project
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


PRODUCT_PACKAGES += \
    messaging

PRODUCT_PROPERTY_OVERRIDES := \
    keyguard.no_require_sim=true \
    ro.com.android.dataroaming=true

PRODUCT_COPY_FILES := \
    device/sample/etc/apns-full-conf.xml:system/etc/apns-conf.xml \
    frameworks/native/data/etc/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml

$(call inherit-product, $(SRC_TARGET_DIR)/product/telephony.mk)

PRODUCT_COPY_FILES += \
    device/brobwind/rpi3/libgps/gps_cfg.inf:system/etc/gps_cfg.inf \
    device/brobwind/rpi3/libgps/armeabi/gps.default.so:system/lib/hw/gps.default.so

PRODUCT_COPY_FILES += \
    device/brobwind/rpi3/libreference-ril.so:$(TARGET_COPY_OUT_VENDOR)/lib/libreference-ril.so

PRODUCT_PACKAGES += \
    ql-tty2tcp