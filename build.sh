#!/bin/sh

LOADADDR=0x80200000
KERNEL_SOURCE_PATH=./kernel_palm/
BOOTLOADER_SOURCE_PATH=./uboot_palm/
TFTP_PATH=/tftpboot/
NFS_ROOTFS_PATH=/srv/nmv_wheezy/
export PATH=$PATH:/home/anton/Source/nmv/uboot_palm/tools/
export ARCH=arm
export CROSS_COMPILE=/home/anton/Distrib/arm-2013.05/bin/arm-none-linux-gnueabi-

#
# Build U-Boot
#
cd ${BOOTLOADER_SOURCE_PATH}
make -j8

#
# Create MLO for eMMC
#
if [ -f EMMC_raw_header.dat ] && [ -f MLO ]; then
	dd if=./EMMC_raw_header.dat of=./EMMC_MLO.tmp
	dd if=./MLO of=./EMMC_MLO.tmp bs=512 seek=1 skip=1
	mv ./EMMC_MLO.tmp EMMC_MLO
else
	echo "###########################################################"
	echo "########### EMMC header for MLO doesn't exist! ############"
	echo "###########################################################"
fi
cd ..

#
# Check tools
#
if [ ! -f ./uboot_palm/tools/mkimage ]; then
	echo "Mkimage tool not found. Seems u-boot wasn't built."
	exit 0
fi

#
# Build Linux kernel and make uImage
#
if [ "$1" = "evm" ]; then
	echo "############# Evm board! ##############"
	DTB=am3517-evm.dtb
elif [ "$1" = "omap2plus" ]; then
	echo "########### Omap2plus board! ##########"
	DTB=am3517-evm.dtb
else
	echo "########### Default board! ############"
	DTB=nmv.dtb
fi


cd ${KERNEL_SOURCE_PATH}
make -j8 && \
cat ./arch/arm/boot/zImage ./arch/arm/boot/dts/${DTB} > zImage-with-dtb && \
mkimage -A arm -O linux -T kernel -C none -a ${LOADADDR} -e ${LOADADDR} -d zImage-with-dtb ${TFTP_PATH}uImage

#
# Build and install kernel modules
#
make modules
make INSTALL_MOD_PATH=${NFS_ROOTFS_PATH} modules_install
