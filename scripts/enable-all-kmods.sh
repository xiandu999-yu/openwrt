#!/bin/bash
echo "=== 启用所有内核模块和功能 ==="

# 备份当前配置
cp .config .config.backup

# 启用所有内核模块支持
echo "CONFIG_MODULES=y" >> .config
echo "CONFIG_ALL_KMODS=y" >> .config

# 核心网络功能
echo "CONFIG_PACKAGE_kmod-ppp=y" >> .config
echo "CONFIG_PACKAGE_kmod-pppoe=y" >> .config
echo "CONFIG_PACKAGE_kmod-pppox=y" >> .config

# Netfilter 核心功能
echo "CONFIG_PACKAGE_kmod-nf-nat=y" >> .config
echo "CONFIG_PACKAGE_kmod-nf-conntrack=y" >> .config
echo "CONFIG_PACKAGE_kmod-ipt-core=y" >> .config
echo "CONFIG_PACKAGE_kmod-ipt-nat=y" >> .config

# 文件系统
echo "CONFIG_PACKAGE_kmod-fs-ext4=y" >> .config
echo "CONFIG_PACKAGE_kmod-fs-vfat=y" >> .config
echo "CONFIG_PACKAGE_kmod-fs-ntfs=y" >> .config
echo "CONFIG_PACKAGE_kmod-fs-squashfs=y" >> .config
echo "CONFIG_PACKAGE_kmod-fs-nfs=y" >> .config
echo "CONFIG_PACKAGE_kmod-fs-nfs-common=y" >> .config

# USB 支持
echo "CONFIG_PACKAGE_kmod-usb-core=y" >> .config
echo "CONFIG_PACKAGE_kmod-usb-storage=y" >> .config
echo "CONFIG_PACKAGE_kmod-usb-ohci=y" >> .config
echo "CONFIG_PACKAGE_kmod-usb-uhci=y" >> .config
echo "CONFIG_PACKAGE_kmod-usb2=y" >> .config
echo "CONFIG_PACKAGE_kmod-usb3=y" >> .config

# 加密功能
echo "CONFIG_PACKAGE_kmod-crypto-core=y" >> .config
echo "CONFIG_PACKAGE_kmod-crypto-hash=y" >> .config
echo "CONFIG_PACKAGE_kmod-crypto-aead=y" >> .config
echo "CONFIG_PACKAGE_kmod-crypto-manager=y" >> .config

# PCIe 支持
echo "CONFIG_PACKAGE_kmod-pci=y" >> .config

# 硬件监控
echo "CONFIG_PACKAGE_kmod-hwmon-core=y" >> .config

# 网络驱动支持
echo "CONFIG_PACKAGE_kmod-mii=y" >> .config
echo "CONFIG_PACKAGE_kmod-phy-realtek=y" >> .config
echo "CONFIG_PACKAGE_kmod-phylib=y" >> .config

echo "✅ 内核模块配置完成"
