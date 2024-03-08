NAME=ncurses-6.4
REPO=https://ftp.gnu.org/gnu/ncurses/ncurses-6.4.tar.gz

ARCH=arm64
KERNEL=kernel8
CROSS_COMPILE=aarch64-linux-gnu-
HOST=aarch64-linux-gnu
CC=aarch64-linux-gnu-gcc
CXX=aarch64-linux-gnu-g++

PACKAGE_DIR=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/
ROOT_DIR:=$(PACKAGE_DIR)../../

deps:
	if cd ${PACKAGE_DIR}${NAME}; then echo DOWNLOADED; else wget -O ${PACKAGE_DIR}ncurses.tar.gz $(REPO); gunzip ${PACKAGE_DIR}ncurses.tar.gz; tar xf ${PACKAGE_DIR}ncurses.tar; rm ${PACKAGE_DIR}ncurses.tar; fi

configure:
	cd ${PACKAGE_DIR}${NAME}; ./configure --prefix=${ROOT_DIR}out/rootfs --config-cache --cache-file=${ROOT_DIR}.config_cache --build=${HOST} --target=${HOST}

build:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} -j`nproc`

install:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} install

clean:
	$(MAKE) -C ${PACKAGE_DIR}ncurses-6.4 clean

.PHONY: build