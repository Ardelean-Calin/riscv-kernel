#!/usr/bin/env bash

set -e

KERNEL_VERSION=6.1.74
UROOT_VERSION=0.12.0


# Create initrd
cd src || exit
  wget -O uroot.zip "https://github.com/u-root/u-root/archive/refs/tags/v$UROOT_VERSION.zip"
  unzip uroot.zip
  rm uroot.zip

  cd "u-root-$UROOT_VERSION" || exit

    go build
    ./u-root -o ../../initramfs.linux_amd64.cpio

  cd ..
cd ..
