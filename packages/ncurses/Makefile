REPO=https://ftp.gnu.org/gnu/ncurses/ncurses-6.4.tar.gz

ARCH=arm64
KERNEL=kernel8
CROSS_COMPILE=aarch64-linux-gnu-

PACKAGE_DIR=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/
ROOT_DIR:=$(PACKAGE_DIR)/../../

deps:
	if cd ${PACKAGE_DIR}ncurses-6.4; then echo DOWNLOADED; else wget -O ${PACKAGE_DIR}ncurses.tar.gz $(REPO); gunzip ${PACKAGE_DIR}ncurses.tar.gz; tar xf ${PACKAGE_DIR}ncurses.tar; rm ${PACKAGE_DIR}ncurses.tar; fi

configure:
	cd ${PACKAGE_DIR}ncurses-6.4; ./configure --prefix=${ROOT_DIR}out/rootfs

build:
	$(MAKE) -C ${PACKAGE_DIR}ncurses-6.4 -j`nproc`

install:
	$(MAKE) -C ${PACKAGE_DIR}ncurses-6.4 install

clean:
	$(MAKE) -C ${PACKAGE_DIR}ncurses-6.4 clean

.PHONY: ncurses