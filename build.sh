#!/usr/bin/env bash

set -e

KERNEL_VERSION=6.1.74
UROOT_VERSION=0.12.0

mkdir -p src
cd src || exit

  # Download the linux kernel
  KERNEL_MAJOR=$(echo $KERNEL_VERSION | sed 's/\(\d*\)\..*/\1/')
  wget -O linux-kernel.tar.xz "https://cdn.kernel.org/pub/linux/kernel/v$KERNEL_MAJOR.x/linux-$KERNEL_VERSION.tar.xz"
  tar xf linux-kernel.tar.xz
  rm linux-kernel.tar.xz

  # Build the Linux Kernel
  cd "linux-$KERNEL_VERSION" || exit
    make defconfig
    make -j"$(nproc)" bzImage
    cp arch/x86_64/boot/bzImage ../../
  cd ..

  # Download U-Root userland
  wget -O uroot.zip "https://github.com/u-root/u-root/archive/refs/tags/v$UROOT_VERSION.zip"
  unzip uroot.zip
  rm uroot.zip

  # Create initramfs (binary root file system)
  cd "u-root-$UROOT_VERSION" || exit
    go build
    ./u-root -o ../../initramfs.linux_amd64.cpio
  cd ..
  
cd ..

GREEN='\033[0;32m'
NC='\033[0m' 
echo -e "${GREEN}Done! To test your kernel you can run:${NC}\n  qemu-system-x86_64 -kernel bzImage -nographic -serial mon:stdio -append 'console=ttyS0' -m 512 -initrd initramfs.linux_amd64.cpio"
