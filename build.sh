#!/usr/bin/env bash

set -e

KERNEL_VERSION=6.1.74
UROOT_VERSION=0.12.0
GO_VERSION=1.22.0

mkdir -p build
cd build || exit

  # Prerequisites
  mkdir -p tools
  export PATH=$PATH:$(pwd)/tools/go/bin

  # Download and install go
  cd tools || exit
    wget "https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz" 
    rm -rf go && tar -C ./ -xzf go$GO_VERSION.linux-amd64.tar.gz
  cd ..

  # Download and build the Kernel
  mkdir -p src
  cd src || exit

    # Download the linux kernel
    KERNEL_MAJOR=$(echo $KERNEL_VERSION | sed 's/\(\d*\)\..*/\1/')
    wget -O linux-kernel.tar.xz "https://cdn.kernel.org/pub/linux/kernel/v$KERNEL_MAJOR.x/linux-$KERNEL_VERSION.tar.xz" 
    tar xf linux-kernel.tar.xz

    # Build the Linux Kernel
    cd "linux-$KERNEL_VERSION" || exit
      make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- defconfig
      cp ../../../.config .
      make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j"$(nproc)"
      cp arch/riscv/boot/Image ../../
    cd ..

    # Download U-Root userland
    wget -O uroot.zip "https://github.com/u-root/u-root/archive/refs/tags/v$UROOT_VERSION.zip" 
    unzip -n uroot.zip

    # Create initramfs (binary root file system)
    cd "u-root-$UROOT_VERSION" || exit
      go build
      GOOS=linux GOARCH=riscv64 ./u-root -o ../../initramfs.linux_riscv64.cpio
    cd ..
  
  cd ..

cd ..

# Done. Print simulation command.
GREEN='\033[0;32m'
NC='\033[0m' 
echo -e "${GREEN}Done! To test your kernel you can run:${NC}\n  qemu-system-riscv64 -machine virt -kernel build/Image -nographic -serial mon:stdio -append 'console=ttyS0' -m 512 -initrd build/initramfs.linux_riscv64.cpio"
# Note: This is the command for web access
# qemu-system-riscv64 -machine virt -kernel build/Image -nographic -serial mon:stdio -append 'console=ttyS0' -m 512 -initrd build/initramfs.linux_riscv64.cpio -device virtio-net-device,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::10000-:22 -device virtio-rng-pci
