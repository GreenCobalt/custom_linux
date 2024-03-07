**custom linux**
build linux for raspberry pi from scratch

includes kernel, a basic busybox userland and a small number of external programs including:
 - neofetch
 - htop

build process automatically uses all cpu cores (nproc * 1.5)

**usage**

 1. *install dependencies (and toolchain)*

`sudo apt install git bc bison flex libssl-dev make libc6-dev libncurses5-dev dosfstools gcc-aarch64-linux-gnu kpartx`

 2. *begin build*

`make deps` ← downloads git repos for linux etc. may take a while depending on internet speed
`make defconfig` ← sets up configurations for downloaded programs (linux etc)
`make` ← builds all codebases and generates a filesystem. packages that FS into `out/disk.img`
this takes around 15 minutes on a Ryzen 7 3700x.

 3. *install*

an SD card image will be generated at `out/disk.img`
this image can be burned with balena Etcher or similar to an SD card and run by the Pi
