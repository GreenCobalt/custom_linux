NAME=bash
REPO=https://git.savannah.gnu.org/git/bash.git

ARCH=arm64
KERNEL=kernel8
CROSS_COMPILE=aarch64-linux-gnu-
HOST=aarch64-linux-gnu
CC=aarch64-linux-gnu-gcc
CXX=aarch64-linux-gnu-g++
STRIP=aarch64-linux-gnu-strip

PACKAGE_DIR=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/
ROOT_DIR:=$(PACKAGE_DIR)../../

AUTOCONF_ENV = STRIP="${STRIP}" CPPFLAGS="-I${ROOT_DIR}out/rootfs/include" LDFLAGS="-L${ROOT_DIR}out/rootfs/lib"
AUTOCONF_TARGET = --host=${HOST}
AUTOCONF_CACHE = 

deps:
	if cd ${PACKAGE_DIR}${NAME}; then git pull; else cd ${PACKAGE_DIR}; git clone --depth 1 $(REPO); fi

configure:
	cd ${PACKAGE_DIR}${NAME};\
	${AUTOCONF_ENV} ./configure --prefix=${ROOT_DIR}out/rootfs ${AUTOCONF_TARGET} ${AUTOCONF_CACHE} \
	--enable-static-link --without-bash-malloc

build:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} -j`nproc`
	cd ${PACKAGE_DIR}${NAME}; ${STRIP} bash

install:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} install

clean:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} clean

.PHONY: build