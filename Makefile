.EXPORT_ALL_VARIABLES:
ARCH=arm64
KERNEL=kernel8
CROSS_COMPILE=aarch64-linux-gnu-
CPU=bcm2711

CONFIG_LOCALVERSION="-v8-SNADOL"

LINUX_REPO=https://github.com/raspberrypi/linux
FIRMWARE_REPO=https://github.com/raspberrypi/firmware
BUSYBOX_REPO=https://git.busybox.net/busybox

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/
INSTALL_MOD_PATH=$(ROOT_DIR)out/rootfs
BOOT_DIR=$(ROOT_DIR)out/boot

deps:
	if cd linux/; then git pull; else git clone --depth 1 $(LINUX_REPO); fi
	if cd firmware/; then git pull; else git clone --depth 1 $(FIRMWARE_REPO); fi
	if cd busybox/; then git pull; else git clone --depth 1 $(BUSYBOX_REPO); fi

kernel_defconfig:
	$(MAKE) -C linux -j`nproc` $(CPU)_defconfig

busybox_defconfig:
	echo "CONFIG_STATIC=y\nCONFIG_CROSS_COMPILER_PREFIX=\"$(CROSS_COMPILE)\"\nCONFIG_PREFIX=\"$(INSTALL_MOD_PATH)\"" > busybox/configs/CM4_defconfig
	$(MAKE) -C busybox -j`nproc` CM4_defconfig

kernel_config:
	$(MAKE) -C linux menuconfig

busybox_config:
	$(MAKE) -C busybox menuconfig

kernel:
	$(MAKE) -C linux -j`nproc` Image modules dtbs

busybox:
	$(MAKE) -C busybox -j`nproc`

fs: kernel busybox
	rm -rf out/

	mkdir -p $(INSTALL_MOD_PATH)
	mkdir -p $(BOOT_DIR)/overlays

	cp firmware/boot/fixup4.dat $(BOOT_DIR)
	cp firmware/boot/start4.elf $(BOOT_DIR)

	cp linux/arch/arm64/boot/dts/broadcom/*.dtb $(BOOT_DIR)
	cp linux/arch/arm64/boot/dts/overlays/*.dtb* $(BOOT_DIR)/overlays/
	cp linux/arch/arm64/boot/dts/overlays/README $(BOOT_DIR)/overlays/
	cp linux/arch/arm64/boot/Image $(BOOT_DIR)/Image

	cp config.txt $(BOOT_DIR)
	cp cmdline.txt $(BOOT_DIR)

	$(MAKE) -C linux modules_install
	$(MAKE) -C busybox install

	mkdir -p $(INSTALL_MOD_PATH)/etc
	mkdir -p $(INSTALL_MOD_PATH)/etc/init.d
	mkdir -p $(INSTALL_MOD_PATH)/proc 
	mkdir -p $(INSTALL_MOD_PATH)/sys
	mkdir -p $(INSTALL_MOD_PATH)/dev
	mkdir -p $(INSTALL_MOD_PATH)/tmp
	mkdir -p $(INSTALL_MOD_PATH)/root
	mkdir -p $(INSTALL_MOD_PATH)/var
	mkdir -p $(INSTALL_MOD_PATH)/lib
	mkdir -p $(INSTALL_MOD_PATH)/mnt
	mkdir -p $(INSTALL_MOD_PATH)/boot

	install busybox/examples/inittab $(INSTALL_MOD_PATH)/etc/inittab

	touch $(INSTALL_MOD_PATH)/etc/init.d/rcS
	chmod +x $(INSTALL_MOD_PATH)/etc/init.d/rcS

	echo "#!/bin/sh" > $(INSTALL_MOD_PATH)/etc/init.d/rcS
	echo "mdev -s" >> $(INSTALL_MOD_PATH)/etc/init.d/rcS
	echo "echo SYSTEM BOOTED TO INIT SPACE" >> $(INSTALL_MOD_PATH)/etc/init.d/rcS

	#cd $(INSTALL_MOD_PATH); find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz

.ONESHELL:
img: fs
	dd if=/dev/zero of=out/disk.img bs=1MiB count=512
	sfdisk out/disk.img < disk.sfdisk

	KX=$$(sudo kpartx -avs out/disk.img | grep -m1 -Eo loop..?p)
	mkfs -t vfat /dev/mapper/$${KX}1
	mkfs -t ext4 /dev/mapper/$${KX}2

	echo /dev/mapper/$${KX}

	mkdir -p $(ROOT_DIR)out/tmp/boot
	mkdir -p $(ROOT_DIR)out/tmp/rootfs

	mount -o loop /dev/mapper/$${KX}1 $(ROOT_DIR)out/tmp/boot
	mount -o loop /dev/mapper/$${KX}2 $(ROOT_DIR)out/tmp/rootfs

	cp -r $(BOOT_DIR)/* $(ROOT_DIR)out/tmp/boot
	cp -r $(INSTALL_MOD_PATH)/* $(ROOT_DIR)out/tmp/rootfs

	umount $(ROOT_DIR)out/tmp/boot
	umount $(ROOT_DIR)out/tmp/rootfs

	sudo kpartx -dv out/disk.img
	rm -r $(ROOT_DIR)out/tmp

clean:
	$(MAKE) -C linux clean
	$(MAKE) -C busybox clean
	rm -rf $(ROOT_DIR)out

.PHONY: busybox busybox_config kernel kernel_config fs
