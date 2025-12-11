# Device definition for ZBT Z8102AX-V2 eMMC
# This content should be added to target/linux/mediatek/image/mt7981.mk

define Device/mt7981-emmc-rfb-z8102ax
  DEVICE_VENDOR := ZBT
  DEVICE_MODEL := Z8102AX-V2
  DEVICE_VARIANT := eMMC
  DEVICE_DTS := ZBT-Z8102AX-eMMC
  DEVICE_DTS_DIR := ../dts
  DEVICE_PACKAGES := kmod-usb3 kmod-mt7915e kmod-mt7981-firmware mt7981-wo-firmware \
		     kmod-mmc kmod-sdhci kmod-sdhci-mt7620
  SUPPORTED_DEVICES := zbtlink,z8102ax-emmc mediatek,mt7981-emmc-rfb
  UBINIZE_OPTS := -E 5
  BLOCKSIZE := 128k
  PAGESIZE := 2048
  IMAGE_SIZE := 65536k
  KERNEL_SIZE := 16384k
  KERNEL := kernel-bin | lzma | fit lzma $$(KDIR)/image-$$(firstword $$(DEVICE_DTS)).dtb
  KERNEL_INITRAMFS := kernel-bin | lzma | fit lzma $$(KDIR)/image-$$(firstword $$(DEVICE_DTS)).dtb with-initrd
  IMAGES := sysupgrade.bin factory.bin
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
  IMAGE/factory.bin := append-kernel | pad-to $$(KERNEL_SIZE) | append-ubi | check-size
endef
TARGET_DEVICES += mt7981-emmc-rfb-z8102ax
