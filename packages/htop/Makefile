NAME=htop
REPO=https://github.com/htop-dev/htop

ARCH=arm64
KERNEL=kernel8
CROSS_COMPILE=aarch64-linux-gnu-

PACKAGE_DIR=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/
ROOT_DIR:=$(PACKAGE_DIR)../../

deps:
	if cd ${PACKAGE_DIR}${NAME}; then git pull; else cd ${PACKAGE_DIR}; git clone --depth 1 $(REPO); fi

configure:
	cd ${PACKAGE_DIR}${NAME}; ./autogen.sh
	cd ${PACKAGE_DIR}${NAME}; ./configure --enable-static --enable-sensors --prefix=${ROOT_DIR}out/rootfs --config-cache --cache-file=${ROOT_DIR}config.cache

build:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} -j`nproc`

install:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} install

clean:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} clean

.PHONY: build