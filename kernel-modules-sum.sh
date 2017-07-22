#!/bin/bash
# This file should be updated after every kernel build.
#
# If the checksum changes for one of the kernel, all extra
# modules need to be recompiled. 
#
# In rare cases extra modules need to been recompliled, 
# even if the checksum is same.
#
# Please also test your system with at least one virtualbox
# module installed

arch=$(uname -m)

if [ -e kernel-modules-$arch.sum ]; then
	timestamp=$(stat -c %y kernel-modules-$arch.sum | sed s'~ ~-~'g | cut -d. -f1)
	mv kernel-modules-$arch.sum kernel-modules-$timestamp-$arch.sum
fi
md5sum /usr/lib/modules/*-MANJARO/build/Module.symvers | sed s'~/usr/lib/modules/~Kernel: ~'g | sed s'~/build/Module.symvers~~'g > kernel-modules-$arch.sum
if [ -e kernel-modules-$timestamp-$arch.sum ]; then
	echo "Possible ABI-change detected. Please check:"
	echo " "
	diff -Npur kernel-modules-$timestamp-$arch.sum kernel-modules-$arch.sum > abi-change-since-$timestamp-$arch.abi
	cat abi-change-since-$timestamp-$arch.abi
fi
