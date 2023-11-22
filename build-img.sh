#!/bin/bash

set -e

apt update

# 不进行交互安装
export DEBIAN_FRONTEND=noninteractive

apt install multistrap -y

mkdir -p /beige-rootfs/etc/apt/trusted.gpg.d
cp deepin.gpg /beige-rootfs/etc/apt/trusted.gpg.d

arch=${1}
echo -e "[General]\n\
arch=$arch\n\
directory=/beige-rootfs/\n\
cleanup=true\n\
noauth=false\n\
unpack=true\n\
explicitsuite=false\n\
multiarch=\n\
aptsources=Debian\n\
bootstrap=Deepin\n\
[Deepin]\n\
packages=apt ca-certificates systemd\n\
source=https://community-packages.deepin.com/beige/\n\
suite=beige\n\
" >/beige.multistrap

multistrap -f /beige.multistrap

echo "deb     https://community-packages.deepin.com/beige/ beige main commercial community" > /beige-rootfs/etc/apt/sources.list && \
echo "deb-src https://community-packages.deepin.com/beige/ beige main commercial community" >> /beige-rootfs/etc/apt/sources.list


# 生成 img
# 创建一个空白的镜像文件。
dd if=/dev/zero of=/tmp/deepin.img bs=1M count=2048
# 将img文件格式化为ext4文件系统
mkfs.ext4 /tmp/deepin.img
mkdir -p /mnt/rootfs
# 挂载 deepin.img 镜像
mount -o loop /tmp/deepin.img /mnt/rootfs
# 拷贝根文件系统到 /mnt/rootfs
cp -a /beige-rootfs/* /mnt/rootfs/
# 卸载
umount /mnt/rootfs