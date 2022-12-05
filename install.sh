#!/usr/bin/env bash

# Jeffrey Borcean
# Beaverton School District

# USAGE
# bash -c "$(curl https://raw.githubusercontent.com/borcean/opencore/main/install.sh)"


# Set to location where OpenCore disk images are located
# script expects files named like: opencore-iMac14,1.dmg
BINARY_HOST="https://raw.githubusercontent.com/borcean/opencore/main/"

if [ "$(uname -s)" != "Darwin" ]; then
   echo "Only supports macOS, exiting..." 1>&2
   exit 1
fi

# Get the model identifier
HW_MODEL=$(sysctl hw.model | awk '{print $2}')

# Check if a disk image exists for the model identifier
if ! $(curl -Isf --output /dev/null "$BINARY_HOST"opencore-"$HW_MODEL".dmg); then
    echo "OpenCore disk image does not found for $HW_MODEL, exiting..." 1<&2
    exit 1
fi

# Download and mount the OpenCore image
curl -sfLo /tmp/opencore.dmg "$BINARY_HOST"opencore-"$HW_MODEL".dmg
hdiutil attach /tmp/opencore.dmg

# Find the EFI partition, usually /dev/disk0s1
EFI_PARTITION=$(diskutil list | \
 sed -ne '/^$/q' -e '/internal\, physical/,$p' | \
 awk '/EFI/{gsub(/:/,"");print $6}')

# Mount the EFI partition
diskutil mount /dev/"$EFI_PARTITION"

# Copy OpenCore to the EFI partition
rsync -r /Volumes/OPENCORE/ /Volumes/EFI/

# Unmount the EFI partion
diskutil unmount /dev/"$EFI_PARTITION"

# Unmount OpenCore disk image
diskutil unmount /Volumes/OPENCORE
