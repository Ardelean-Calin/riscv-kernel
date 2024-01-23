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
    cp arch/x86_64/boot/bzImage ../../
  cd ..

  # Build Busybox in static mode
  cd busybox-$BUSYBOX_VERSION || exit
    make defconfig
    # Configure it to be static
    sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
    # Then build busybox
    make -j"$(nproc)"
  cd ..

  
cd ..

# Create the Filesystem image
# Create initrd
mkdir -p initrd
cd initrd || exit

  mkdir -p bin dev proc sys
  cd bin || exit

    cp ../../src/busybox-$BUSYBOX_VERSION/busybox .
    for prog in $(./busybox --list); do
      ln -s ./busybox "./$prog"
    done

  cd ..

  # Create the devices and init script
  echo '#!/bin/sh' > init
  {
    echo 'mount -t sysfs sysfs /sys'
    echo 'mount -t proc proc /proc'
    echo 'mount -t devtmpfs udev /dev'
    echo 'sysctl -w kernel.printk="2 4 1 7"'
    echo 'clear'
    echo "cat <<!


Boot took $(cut -d' ' -f1 /proc/uptime) seconds

   ___        _  _           __  _                     
  / __\ __ _ | |(_) _ __    / / (_) _ __   _   _ __  __
 / /   / _' || || || '_ \  / /  | || '_ \ | | | |\ \/ /
/ /___| (_| || || || | | |/ /___| || | | || |_| | >  < 
\____/ \__,_||_||_||_| |_|\____/|_||_| |_| \__,_|/_/\_\ 


Welcome to Calin Linux


!"
    echo "/bin/sh"
    echo "poweroff -f"
  } >> init

  chmod -R 777 .

  find . | cpio -o -H newc > ../initrd.img

cd ..

GREEN='\033[0;32m'
NC='\033[0m' 
echo -e "${GREEN}Done! To test your kernel you can run:${NC}\n  qemu-system-x86_64 -kernel bzImage -nographic -serial mon:stdio -append 'console=
ttyS0' -m 512 -initrd initrd.img"
