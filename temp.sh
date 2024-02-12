#!/usr/bin/env bash

set -e

KERNEL_VERSION=6.1.74
UROOT_VERSION=0.12.0
GO_VERSION=1.22.0


mkdir -p tools
cd tools || exit

cd ..
# Create initrd
cd src || exit

  wget "https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz" 
  mkdir -p ../tools
  rm -rf ../tools/go && tar -C ../tools -xzf go$GO_VERSION.linux-amd64.tar.gz

  ../tools/go/bin/go version
cd ..
