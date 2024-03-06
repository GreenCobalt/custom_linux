.EXPORT_ALL_VARIABLES:
ARCH=arm
KERNEL=kernel7
CROSS_COMPILE=arm-linux-gnueabihf-
CPU=bcm2711

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

kernel_config:
	$(MAKE) -C linux -j`nproc` $(CPU)_defconfig

busybox_config:
	cp busybox_config busybox/.config

kernel:
	$(MAKE) -C linux -j`nproc` zImage modules dtbs

busybox:
	$(MAKE) -C busybox -j`nproc`

fs: kernel busybox
	mkdir -p $(INSTALL_MOD_PATH)
	mkdir -p $(BOOT_DIR)/overlays

	cp firmware/boot/fixup4.dat $(BOOT_DIR)
	cp firmware/boot/start4.elf $(BOOT_DIR)
	cp linux/arch/arm/boot/zImage $(BOOT_DIR)
	cp linux/arch/arm/boot/dts/bcm2711-rpi-cm4.dtb $(BOOT_DIR)
	cp linux/arch/arm/boot/dts/overlays/disable-bt.dtbo $(BOOT_DIR)/overlays
	cp config.txt $(BOOT_DIR)
	cp cmdline.txt $(BOOT_DIR)

	$(MAKE) -C linux modules_install
	$(MAKE) -C busybox install

	mkdir -p $(INSTALL_MOD_PATH)/proc $(INSTALL_MOD_PATH)/sys $(INSTALL_MOD_PATH)/dev $(INSTALL_MOD_PATH)/etc

	mkdir -p $(INSTALL_MOD_PATH)/etc/init.d
	touch $(INSTALL_MOD_PATH)/etc/init.d/rcS
	chmod +x $(INSTALL_MOD_PATH)/etc/init.d/rcS

	echo "#!/bin/sh" >> $(INSTALL_MOD_PATH)/etc/init.d/rcS
	echo "mount -t devtmpfs none /dev" >> $(INSTALL_MOD_PATH)/etc/init.d/rcS
	echo "mount -t proc none /proc" >> $(INSTALL_MOD_PATH)/etc/init.d/rcS
	echo "mount -t sysfs none /sys" >> $(INSTALL_MOD_PATH)/etc/init.d/rcS
	echo "echo /sbin/mdev > /proc/sys/kernel/hotplug" >> $(INSTALL_MOD_PATH)/etc/init.d/rcS
	echo "mdev -s" >> $(INSTALL_MOD_PATH)/etc/init.d/rcS

	cd $(INSTALL_MOD_PATH); find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz

.ONESHELL:
img: fs
	dd if=/dev/zero of=out/disk.img bs=1MiB count=512
	sfdisk out/disk.img < disk.sfdisk

	KX=$$(sudo kpartx -avs out/disk.img | grep -m1 -Eo loop..?p)
	mkfs -t vfat /dev/mapper/$${KX}1
	mkfs -t ext4 /dev/mapper/$${KX}2

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
	rm -r $(ROOT_DIR)out

.PHONY: busybox busybox_config kernel kernel_config fs
