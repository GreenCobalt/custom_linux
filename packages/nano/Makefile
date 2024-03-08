NAME=nano-7.2
REPO=https://www.nano-editor.org/dist/v7/nano-7.2.tar.gz

ARCH=arm64
KERNEL=kernel8
CROSS_COMPILE=aarch64-linux-gnu-
HOST=aarch64-linux-gnu
CC=aarch64-linux-gnu-gcc
CXX=aarch64-linux-gnu-g++
STRIP=aarch64-linux-gnu-strip

PACKAGE_DIR=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/
ROOT_DIR:=$(PACKAGE_DIR)../../

AUTOCONF_ENV = STRIP="${STRIP}" CPPFLAGS="-static -I${ROOT_DIR}out/rootfs/include" LDFLAGS="-L${ROOT_DIR}out/rootfs/lib -t" CFLAGS="-O2 -Wall -static"
AUTOCONF_TARGET = --host=${HOST}
AUTOCONF_CACHE = 

deps:
	if cd ${PACKAGE_DIR}${NAME}; then echo DOWNLOADED; else wget -O ${PACKAGE_DIR}nano.tar.gz $(REPO); gunzip ${PACKAGE_DIR}nano.tar.gz; tar xf ${PACKAGE_DIR}nano.tar; rm ${PACKAGE_DIR}nano.tar; fi

configure:
	cd ${PACKAGE_DIR}${NAME};\
	${AUTOCONF_ENV} ./configure --prefix=${ROOT_DIR}out/rootfs ${AUTOCONF_TARGET} ${AUTOCONF_CACHE} \
	--disable-nls --disable-dependency-tracking \
	CFLAGS="-O2 -Wall --static"

build:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} CFLAGS="-O2 -Wall -static" -j`nproc`
	cd ${PACKAGE_DIR}${NAME}; ${STRIP} src/nano

install:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} install

clean:
	$(MAKE) -C ${PACKAGE_DIR}${NAME} clean

.PHONY: build