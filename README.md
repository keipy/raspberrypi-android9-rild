# First, refer to raspberrypi android build from the link below.  
# Basically, the below step is based on brobwind's android build. 
https://github.com/brobwind/pie-device-brobwind-rpi3



1. Kernel build for LTE modem USB driver. Refer to module vendor's USB driver integration guilde! 
# add USB driver in bcmrpi3_defconfig
# kernel-v4.14/arch/arm64/configs/bcmrpi3_defconfig 
CONFIG_USB_WDM=y
CONFIG_USB_SERIAL=y
CONFIG_USB_SERIAL_WWAN=y
CONFIG_USB_SERIAL_OPTION=y
CONFIG_USB_USBNET=y
CONFIG_USB_NET_CDC_MBIM=y
CONFIG_USB_NET_QMI_WWAN=y

# refer to Kernel build process from the link below,
https://github.com/brobwind/pie-device-brobwind-rpi3-kernel-v4.14


2. Edit .rc files for ril-daemon & device permission. 
# add service in init.rc
# system/core/rootdir/init.rc
service ril-daemon /vendor/bin/hw/rild -l /vendor/lib/libreference-ril.so    
	class main
	user root
	group radio cache inet misc audio sdcard_rw log
  
# add diver permission in ueventd.rc
# system/core/rootdir/ueventd.rc
/dev/ttyUSB* 	0660 	radio 	radio
/dev/cdc-wdm* 	0660 	radio 	radio
/dev/qcqmi* 	0660 	radio 	radio
/dev/cdc-acm* 	0660 	radio 	radio


3. Configure files related to sepolicy 
# add scripts as below
# device/brobwind/rpi3/sepolicy/file_contexts
/dev/ttyUSB[0-9]*		u:object_r:tty_device:s0
/system/bin/rild		u:object_r:rild_exec:s0
/system/socket/rild		u:object_r:rild_socket:s0
/system/socket/rild-debug		u:object_r:rild_debug_socket:s0

# device/brobwind/rpi3/manifest.xml
<hal format="hidl">
	<name>android.hardware.broadcastradio</name>
	<transport>hwbinder</transport>
	<version>1.0</version>
	<interface>
	<name>IBroadcastRadioFactory</name>
	<instance>default</instance>
	</interface>
</hal>
<hal format="hidl">
	<name>android.hardware.radio.deprecated</name>
	<transport>hwbinder</transport>
	<version>1.0</version>
	<interface>
	<name>IOemHook</name>
	<instance>slot1</instance>
	</interface>
</hal>
<hal format="hidl">
	<name>android.hardware.radio</name>
	<transport>hwbinder</transport>
	<version>1.0</version>
	<interface>
	<name>IRadio</name>
	<instance>slot1</instance>
	</interface>
</hal>


4. Add mini_rpi3_telephony.mk to rpi3.mk in order to include telephony feature 
# device/brobwind/rpi3/rpi3.mk
$(call inherit-product, device/brobwind/rpi3/mini_rpi3_telephony.mk)


5. Remove the useless feature in hardware/ril/rild/Android.mk 
# comment or delete ENABLE_VENDOR_RIL_SERVICE & LOCAL_INIT_RC 
#LOCAL_INIT_RC := rild.legacy.rc


6. Copy libreference-ril.so in device/brobwind/rpi3


7. Add GPS feature in BoardConfig.mk
# device/brobwind/rpi3/BoardConfig.mk
BOARD_HAS_GPS :=true


8. Delete existing gps package and add new package
# device/brobwind/rpi3/mini_rpi3_common.mk 
#PRODUCT_PACKAGES += \
#    gps.rpi3 \
#    android.hardware.gnss@1.0-service \
#    android.hardware.gnss@1.0-impl
PRODUCT_PACKAGES += \
    gps.default \
    android.hardware.gnss@1.0-service \
    android.hardware.gnss@1.0-impl


9. Remove gps.rpi3.so if you already built android
# out/target/product/rpi3/vendor/lib/hw/gps.rpi3.so


10.A If you have ths source code for GPS library, add the code to device/brobwind/rpi3/hals/gps folder.
# Set variables in Android.mk
LOCAL_VENDOR_MODULE :=true
LOCAL_MODULE_RELATIVE_PATH :=hw


10.B If you have gps library(gps.default.so), copy it to device/brobwind/rpi3/libgps/armeabi folder and add scripts as below
# device/brobwind/rpi3/mini_rpi3_telephony.mk
PRODUCT_COPY_FILES += \
  device/brobwind/rpi3/libgps/armeabi/gps.default.so:vendor/lib/hw/gps.default.so


11. /dev/cdc-wdm0 device not created with QMI device and qmi_wwan driver
# add "usbmisc" in system/core/init/devices.cpp
-} else if (uevent.subsystem == "usb") {
+} else if (uevent.subsystem == "usb" || uevent.subsystem == "usbmisc") {

# refer to the forum below
https://groups.google.com/forum/#!msg/Android-x86/1njBsHw0vro/YwhjZ7TtJJIJ


12. Add the resouce in order to activate LTE mode in Setting
# device/brobwind/rpi3/overlay/package/services/Telephony/res/value/config.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>	
<!-- Show enabled lte option for lte device -->    <bool name="config_enabled_lte" translatable="false">true</bool>
</resources>

