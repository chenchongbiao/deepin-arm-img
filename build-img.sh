#!/bin/bash

# 何命令失败（退出状态非0），则脚本会终止执行
set -o errexit
# 尝试使用未设置值的变量，脚本将停止执行
set -o nounset

ROOTFS=`mktemp -d`
TARGET_DEVICE=FVP
TARGET_ARCH=arm64
COMPONENTS=standard
DISKSIZE=2048
readarray -t REPOS < ./profiles/sources.list
PACKAGES=`cat ./profiles/packages.txt | grep -v "^-" | xargs | sed -e 's/ /,/g'`
DISKIMG="deepin-$TARGET_DEVICE-$TARGET_ARCH.img"

sudo apt update -y
sudo apt-get install -y qemu-user-static binfmt-support mmdebstrap arch-test usrmerge usr-is-merged

# 生成 img
# 创建一个空白的镜像文件。
dd if=/dev/zero of=$DISKIMG bs=1M count=$DISKSIZE
# 将img文件格式化为ext4文件系统
mkfs.ext4 $DISKIMG

# 创建根文件系统
sudo mmdebstrap \
    --hook-dir=/usr/share/mmdebstrap/hooks/merged-usr \
    --include=$PACKAGES \
    --architectures=$TARGET_ARCH $COMPONENTS \
    --customize=./profiles/stage2.sh \
    $ROOTFS \
    "${REPOS[@]}"

sudo echo "deepin-tc" | sudo tee $ROOTFS/etc/hostname > /dev/null
sudo echo "Asia/Shanghai" | sudo tee $ROOTFS/etc/timezone > /dev/null
sudo ln -sf /usr/share/zoneinfo/Asia/Shanghai $ROOTFS/etc/localtime

# 挂载 deepin.img 镜像
sudo mount -o loop $DISKIMG $ROOTFS
# 卸载
sudo umount -l $ROOTFS
sudo losetup -D
sudo rm -rf $ROOTFS