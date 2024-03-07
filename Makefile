.EXPORT_ALL_VARIABLES:
ARCH=arm64
KERNEL=kernel8
CROSS_COMPILE=aarch64-linux-gnu-
HOST=aarch64-linux-gnu
CPU=bcm2711

CONFIG_LOCALVERSION="-v8-SNADOL"

LINUX_REPO=https://github.com/raspberrypi/linux
FIRMWARE_REPO=https://github.com/raspberrypi/firmware
BUSYBOX_REPO=https://git.busybox.net/busybox

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/
INSTALL_MOD_PATH=$(ROOT_DIR)out/rootfs
BOOT_DIR=$(ROOT_DIR)out/boot

all: kernel packages fs img
	@echo "Done"

deps:
	if cd $(ROOT_DIR)linux/; then git pull; else git clone --depth 1 $(LINUX_REPO); fi
	if cd $(ROOT_DIR)firmware/; then git pull; else git clone --depth 1 $(FIRMWARE_REPO); fi
	if cd $(ROOT_DIR)busybox/; then git pull; else git clone --depth 1 $(BUSYBOX_REPO); fi

	$(MAKE) -C ${ROOT_DIR}packages/htop deps
	$(MAKE) -C ${ROOT_DIR}packages/ncurses deps
	$(MAKE) -C ${ROOT_DIR}packages/neofetch deps

defconfig:
	$(MAKE) -C linux -j`nproc` $(CPU)_defconfig
	sed -i 's/CONFIG_USB_NET_SMSC75XX=m/CONFIG_USB_NET_SMSC75XX=y/g' linux/arch/arm64/configs/$(cpu)_defconfig

	echo "CONFIG_STATIC=y\nCONFIG_CROSS_COMPILER_PREFIX=\"$(CROSS_COMPILE)\"\nCONFIG_PREFIX=\"$(INSTALL_MOD_PATH)\"" > busybox/configs/CM4_defconfig
	$(MAKE) -C busybox -j`nproc` CM4_defconfig

	$(MAKE) -C ${ROOT_DIR}packages/htop configure
	$(MAKE) -C ${ROOT_DIR}packages/ncurses configure
	$(MAKE) -C ${ROOT_DIR}packages/neofetch configure

kernel:
	$(MAKE) -C linux -j`nproc` Image dtbs
	$(MAKE) -C linux -j`nproc` modules

packages:
	$(MAKE) -C busybox -j`nproc`
	$(MAKE) -C ${ROOT_DIR}packages/htop build
	$(MAKE) -C ${ROOT_DIR}packages/ncurses build
	$(MAKE) -C ${ROOT_DIR}packages/neofetch build

fs:
	rm -rf out/

	mkdir -p $(INSTALL_MOD_PATH)
	cp -r skeleton/* out/rootfs/
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

	$(MAKE) -C ${ROOT_DIR}packages/htop install
	$(MAKE) -C ${ROOT_DIR}packages/ncurses install
	$(MAKE) -C ${ROOT_DIR}packages/neofetch install

	@echo "FS BUILD DONE"

.ONESHELL:
img:
	dd if=/dev/zero of=out/disk.img bs=1MiB count=300
	sfdisk out/disk.img < disk.sfdisk

	KX=$$(sudo kpartx -avs out/disk.img | grep -m1 -Eo loop..?p)
	sudo mkfs -t vfat /dev/mapper/$${KX}1
	sudo mkfs -t ext4 /dev/mapper/$${KX}2

	mkdir -p $(ROOT_DIR)out/tmp/boot
	mkdir -p $(ROOT_DIR)out/tmp/rootfs

	sudo mount -o loop /dev/mapper/$${KX}1 $(ROOT_DIR)out/tmp/boot
	sudo mount -o loop /dev/mapper/$${KX}2 $(ROOT_DIR)out/tmp/rootfs

	sudo cp -r $(BOOT_DIR)/* $(ROOT_DIR)out/tmp/boot
	sudo cp -r $(INSTALL_MOD_PATH)/* $(ROOT_DIR)out/tmp/rootfs

	sudo umount $(ROOT_DIR)out/tmp/boot
	sudo umount $(ROOT_DIR)out/tmp/rootfs

	sudo kpartx -dv $(ROOT_DIR)out/disk.img
	sudo rm -r $(ROOT_DIR)out/tmp
	exit

clean:
	$(MAKE) -C linux clean
	$(MAKE) -C busybox clean
	$(MAKE) -C ${ROOT_DIR}packages/htop clean
	$(MAKE) -C ${ROOT_DIR}packages/ncurses clean
	$(MAKE) -C ${ROOT_DIR}packages/neofetch clean
	rm -rf $(ROOT_DIR)out

kernel_config:
	$(MAKE) -C linux menuconfig

busybox_config:
	$(MAKE) -C busybox menuconfig

.PHONY: busybox busybox_config kernel kernel_config fs packages
