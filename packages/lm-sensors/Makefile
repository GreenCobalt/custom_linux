NAME=lm-sensors
REPO=https://github.com/lm-sensors/lm-sensors/

ARCH=arm64
KERNEL=kernel8
CROSS_COMPILE=aarch64-linux-gnu-

PACKAGE_DIR=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/
ROOT_DIR:=$(PACKAGE_DIR)../../

deps:
	if cd ${PACKAGE_DIR}${NAME}; then git pull; else cd ${PACKAGE_DIR}; git clone --depth 1 $(REPO); fi

configure:

build:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} -j`nproc` all

install:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} PREFIX=${ROOT_DIR}out/rootfs install

clean:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} clean

.PHONY: build