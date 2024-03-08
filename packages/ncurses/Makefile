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

AUTOCONF_ENV = STRIP="aarch64-linux-gnu-strip" CPPFLAGS="-I${ROOT_DIR}out/rootfs/include" LDFLAGS="-L${ROOT_DIR}out/rootfs/lib"
AUTOCONF_TARGET = --host=${HOST}
AUTOCONF_CACHE = 

deps:
	if cd ${PACKAGE_DIR}${NAME}; then echo DOWNLOADED; else wget -O ${PACKAGE_DIR}ncurses.tar.gz $(REPO); gunzip ${PACKAGE_DIR}ncurses.tar.gz; tar xf ${PACKAGE_DIR}ncurses.tar; rm ${PACKAGE_DIR}ncurses.tar; fi
	cd ${PACKAGE_DIR}${NAME}; sed -i 's/INSTALL_OPT_S="-s"/INSTALL_OPT_S="-s --strip-program=$${STRIP}"/g' configure

configure:
	cd ${PACKAGE_DIR}${NAME};\
	${AUTOCONF_ENV} ./configure --prefix=${ROOT_DIR}out/rootfs ${AUTOCONF_TARGET} ${AUTOCONF_CACHE} \
	--with-normal --without-bash-malloc --with-system-type=${HOST} --with-fallbacks=vt100,vt102,screen

build:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} -j`nproc`

install:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} install

clean:
	$(MAKE) -C ${PACKAGE_DIR}ncurses-6.4 clean

.PHONY: build