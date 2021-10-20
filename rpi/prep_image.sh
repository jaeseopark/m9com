#/bin/bash -e

IMG_URL="https://github.com/timebertt/pi-cloud-init/releases/download/2021-05-10/2021-05-10-raspios-buster-armhf-lite-cloud-init.zip "

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

function download_image() {
    apt-get install unzip # if not already installed
    wget ${IMG_URL} && unzip *.zip
}

function mount_image() {
    if [ -z $(which fdisk) ]; then
        alias fdisk="/sbin/fdisk"
    fi

    UNIT_BYTES=512 # double check by running: /sbin/fdisk -l *.img
    partition_start=$(/sbin/fdisk -l *.img | grep FAT|awk '{print $2}')
    offset=$((partition_start*UNIT_BYTES))
    mkdir /mnt/tmp -p
    mount -o loop,offset=${offset} *.img /mnt/tmp
}

function copy_files_to_mounted_volumn() {
    cp init/* /mnt/tmp/
    umount /mnt/tmp
}

download_image()
mount_image()
copy_files_to_mounted_volumn()

echo "Image is ready: $(ls *.img)"
