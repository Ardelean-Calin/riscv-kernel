#!/usr/bin/env bash

set -e

KERNEL_VERSION=6.1.74
BUSYBOX_VERSION=1.36.1


# Create initrd
mkdir -p initrd
cd initrd || exit

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
