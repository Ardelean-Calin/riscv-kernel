#!/usr/bin/env bash

KERNEL_VERSION=6.1.74
BUSYBOX_VERSION=1.36.1

cd src || exit

  # Build the Linux Kernel
  cd "linux-$KERNEL_VERSION" || exit
    make defconfig
    make -j"$(nproc)" bzImage
  cd ..

cd ..
