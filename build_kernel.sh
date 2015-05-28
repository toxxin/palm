#!/bin/sh

LOADADDR=0x80200000
SOURCE_PATH=./kernel_palm/
TFTP_PATH=/tftpboot/
export PATH=$PATH:/home/anton/Source/nmv/uboot_palm/tools/
export ARCH=arm
export CROSS_COMPILE=/home/anton/Distrib/arm-2013.05/bin/arm-none-linux-gnueabi-

cd ${SOURCE_PATH}
make -j8 && \
cat ./arch/arm/boot/zImage ./arch/arm/boot/dts/nmv.dtb > zImage-with-dtb && \
mkimage -A arm -O linux -T kernel -C none -a ${LOADADDR} -e ${LOADADDR} -d zImage-with-dtb ${TFTP_PATH}uImage
