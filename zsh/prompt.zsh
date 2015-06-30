ramdisk() {
    sudo mkdir -p /mnt/ramdisk
    sudo mount -t tmpfs -o size=$1 tmpfs /mnt/ramdisk
}
