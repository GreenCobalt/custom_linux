NAME=neofetch
REPO=https://github.com/dylanaraps/neofetch

ARCH=arm64
KERNEL=kernel8
CROSS_COMPILE=aarch64-linux-gnu-
HOST=aarch64-linux-gnu
CC=aarch64-linux-gnu-gcc
CXX=aarch64-linux-gnu-g++

PACKAGE_DIR=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/
ROOT_DIR:=$(PACKAGE_DIR)../../

AUTOCONF_ENV = STRIP="aarch64-linux-gnu-strip" CPPFLAGS="-I${ROOT_DIR}out/rootfs/include" LDFLAGS="-L${ROOT_DIR}out/rootfs/lib"
AUTOCONF_TARGET = --host=${HOST}
AUTOCONF_CACHE = 

deps:
	if cd ${PACKAGE_DIR}${NAME}; then git pull; else cd ${PACKAGE_DIR}; git clone --depth 1 $(REPO); fi

configure:

build:

install:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} PREFIX=${ROOT_DIR}out/rootfs install

clean:

.PHONY: build