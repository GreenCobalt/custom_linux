NAME=bash
REPO=https://git.savannah.gnu.org/git/bash.git

ARCH=arm64
KERNEL=kernel8
CROSS_COMPILE=aarch64-linux-gnu-
HOST=aarch64-linux-gnu
CC=aarch64-linux-gnu-gcc

PACKAGE_DIR=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/
ROOT_DIR:=$(PACKAGE_DIR)../../

deps:
	if cd ${PACKAGE_DIR}${NAME}; then git pull; else cd ${PACKAGE_DIR}; git clone --depth 1 $(REPO); fi

configure:
	cd ${PACKAGE_DIR}${NAME}; ./configure --prefix=${ROOT_DIR}out/rootfs --config-cache --cache-file=${ROOT_DIR}.config_cache --build=${HOST} --target=${HOST} --enable-static-link --without-bash-malloc

build:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} -j`nproc`

install:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} install

clean:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} clean

.PHONY: build