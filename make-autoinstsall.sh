#!/bin/bash

echo "Extracting Source Files"
mkdir source-files
7z -y x $1 -osource-files
mv source-files/\[BOOT\] BOOT

echo "Populating grub.cfg"
echo -e "menuentry "Autoinstall Ubuntu Server" {\n    set gfxpayload=keep\n    linux   /casper/vmlinuz quiet autoinstall ds=nocloud\;s=/cdrom/nocloud/  ---\n    initrd  /casper/initrd\n}" > source-files/boot/grub/grub.cfg

echo "Copying autoinstall user-data"
mkdir source-files/nocloud
cp -r $2/. source-files/nocloud

echo "making ISO file"
cd source-files
xorriso -as mkisofs -r \
  -V 'Ubuntu 24.04.1 LTS AUTO' \
  -o ../$(basename $1 .iso)$2-autoinstall.iso \
  --grub2-mbr ../BOOT/1-Boot-NoEmul.img \
  -partition_offset 16 \
  --mbr-force-bootable \
  -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b ../BOOT/2-Boot-NoEmul.img \
  -appended_part_as_gpt \
  -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
  -c '/boot.catalog' \
  -b '/boot/grub/i386-pc/eltorito.img' \
    -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
  -eltorito-alt-boot \
  -e '--interval:appended_partition_2:::' \
  -no-emul-boot \
  .

cd ..
rm -rf {BOOT,source-files}
