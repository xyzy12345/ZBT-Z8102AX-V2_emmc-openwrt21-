# Device definition for ZBT Z8102AX-V2 eMMC (Version 24.10.4)
# This file contains device definitions to be copied to target/linux/mediatek/image/filogic.mk
# eMMC devices use block device format with mt798x-gpt partitioning

define Device/zbt_z8102ax-emmc
  DEVICE_VENDOR := ZBT
  DEVICE_MODEL := Z8102AX-V2
  DEVICE_VARIANT := eMMC
  DEVICE_DTS := ZBT-Z8102AX-eMMC24
  DEVICE_DTS_DIR := ../dts
  DEVICE_DTS_LOADADDR := 0x43f00000
  DEVICE_PACKAGES := kmod-usb3 kmod-mt7915e kmod-mt7981-firmware mt7981-wo-firmware \
		     e2fsprogs f2fsck mkf2fs
  SUPPORTED_DEVICES := zbtlink,z8102ax-emmc mediatek,mt7981-emmc-rfb
  KERNEL_LOADADDR := 0x44000000
  KERNEL := kernel-bin | gzip
  KERNEL_INITRAMFS := kernel-bin | lzma | \
	fit lzma $$(KDIR)/image-$$(firstword $$(DEVICE_DTS)).dtb with-initrd | pad-to 64k
  KERNEL_INITRAMFS_SUFFIX := -recovery.itb
  IMAGES := sysupgrade.itb
  IMAGE_SIZE := $$(shell expr 64 + $$(CONFIG_TARGET_ROOTFS_PARTSIZE))m
  IMAGE/sysupgrade.itb := append-kernel | \
	fit gzip $$(KDIR)/image-$$(firstword $$(DEVICE_DTS)).dtb external-static-with-rootfs | \
	pad-rootfs | append-metadata
  ARTIFACTS := emmc-gpt.bin emmc-preloader.bin emmc-bl31-uboot.fip
  ARTIFACT/emmc-gpt.bin := mt798x-gpt emmc
  ARTIFACT/emmc-preloader.bin := mt7981-bl2 emmc-ddr4
  ARTIFACT/emmc-bl31-uboot.fip := mt7981-bl31-uboot zbt_z8102ax-emmc
endef
TARGET_DEVICES += zbt_z8102ax-emmc
