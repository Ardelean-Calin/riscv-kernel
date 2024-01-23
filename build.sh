#!/usr/bin/env bash

set -e

KERNEL_VERSION=6.1.74
BUSYBOX_VERSION=1.36.1

mkdir -p src
cd src || exit

  # Download the linux kernel
  KERNEL_MAJOR=$(echo $KERNEL_VERSION | sed 's/\(\d*\)\..*/\1/')
  wget -O linux-kernel.tar.xz "https://cdn.kernel.org/pub/linux/kernel/v$KERNEL_MAJOR.x/linux-$KERNEL_VERSION.tar.xz"
  tar xf linux-kernel.tar.xz
  rm linux-kernel.tar.xz

  # Download Busybox
  wget -O busybox.tar.bz2 "https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2"
  tar xf busybox.tar.bz2
  rm busybox.tar.bz2

  # Build the Linux Kernel
  cd "linux-$KERNEL_VERSION" || exit
    make defconfig
    make -j"$(nproc)" bzImage
  cd ..
  
cd ..
