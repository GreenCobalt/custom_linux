REPO=https://github.com/htop-dev/htop

ARCH=arm64
KERNEL=kernel8
CROSS_COMPILE=aarch64-linux-gnu-

PACKAGE_DIR=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/
ROOT_DIR:=$(PACKAGE_DIR)/../../

deps:
	if cd ${PACKAGE_DIR}htop/; then git pull; else cd ${PACKAGE_DIR}; git clone --depth 1 $(REPO); fi

configure:
	cd ${PACKAGE_DIR}htop; ./autogen.sh
	cd ${PACKAGE_DIR}htop; ./configure --enable-static --enable-sensors --prefix=${ROOT_DIR}out/rootfs

build:
	$(MAKE) -C ${PACKAGE_DIR}htop -j`nproc`

install:
	$(MAKE) -C ${PACKAGE_DIR}htop install

clean:
	$(MAKE) -C ${PACKAGE_DIR}htop clean

.PHONY: htop