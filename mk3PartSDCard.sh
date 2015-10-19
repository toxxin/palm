#! /bin/sh
# mk3PartSDCard.sh v0.3
# Licensed under terms of GPLv2

if [ -z $1 ]
then
	echo "mk3PartSDCard.sh Usage:"
	echo "mk3PartSDCard.sh <device>"
	exit
fi

DRIVE=$1
dd if=/dev/zero of=$DRIVE bs=1024 count=1024

SIZE=`fdisk -l $DRIVE | grep Disk | awk '{print $5}'`

echo DISK SIZE - $SIZE bytes

CYLINDERS=`echo $SIZE/255/63/512 | bc`

sfdisk -D -H 255 -S 63 -C ${CYLINDERS} $DRIVE << EOF
,9,0x0C,*
10,,,-
EOF

mkfs.vfat -F 32 -n "boot" ${DRIVE}p1 > /dev/null 2>&1
umount ${DRIVE}p1
mkfs.ext4 -L "rootfs" ${DRIVE}p2 > /dev/null 2>&1
umount ${DRIVE}p2
