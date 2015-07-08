#!/bin/bash

# Extract partitions from an img file and put them into a folder structure.
# Requires kpartx and execution with root/su/sudo permissions.

IMAGE=$1

# Validate that we're getting a .img file
if [ ! ${IMAGE: -4} = '.img' ] ; then
	echo "Error: Need a .img file!" 1>&2
	exit 1
fi

echo Mounting image: $IMAGE

IMGROOT=${IMAGE%.img}
if [ -d $IMGROOT ]; then
	echo "Error: $IMGROOT directory already exists!" 1>&2
	exit 1
fi

# TODO get rid of kpartx dependency by parsing 'fdisk -l $IMAGE'?
PARTITIONS=$(kpartx -avs "$IMAGE" | awk '{print $3}')
for PARTITION in $PARTITIONS
do
	# Make sure the output from kpartx makes sense
	if [ ! ${PARTITION:0:4} = "loop" ] ; then
		echo "Error: kpartx gave invalid output: $PARTITION" 1>&2
		exit 1
	fi
	PMAPPED=/dev/mapper/$PARTITION
	echo -e '\t'Operating on $PMAPPED
	PARTITION_LABEL=$(lsblk --noheadings -o label $PMAPPED)
	# If the drive has no label, use the mapper partition name
	if [ ! $PARTITION_LABEL ] ; then
		PARTITION_LABEL=$PARTITION	
	fi
	# Create a temporary mount point to mount the partition
	MOUNTPT=/mnt/$PARTITION_LABEL
	mkdir $MOUNTPT
	mount $PMAPPED $MOUNTPT
	# Copy the files and delete the temporary mount point
	mkdir -p $IMGROOT/$PARTITION_LABEL
	cp -r $MOUNTPT $IMGROOT
	umount $MOUNTPT
	rm -rf $MOUNTPT
done
kpartx -d $IMAGE

