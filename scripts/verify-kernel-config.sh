#!/bin/bash
echo "=== 内核配置验证 ==="

check_config() {
    local config=$1
    local description=$2
    if grep -q "^${config}=y" .config || grep -q "^${config}=m" .config; then
        echo "✅ $description: 启用"
        return 0
    else
        echo "❌ $description: 未启用"
        return 1
    fi
}

echo "1. 核心功能:"
check_config "CONFIG_MODULES" "模块支持"
check_config "CONFIG_PACKAGE_kmod-ppp" "PPP支持"
check_config "CONFIG_PACKAGE_kmod-nf-nat" "Netfilter NAT"
check_config "CONFIG_PACKAGE_kmod-ipt-core" "iptables核心"
check_config "CONFIG_PACKAGE_kmod-ipv6" "IPv6支持"

echo ""
echo "2. 文件系统:"
check_config "CONFIG_PACKAGE_kmod-fs-ext4" "EXT4文件系统"
check_config "CONFIG_PACKAGE_kmod-fs-squashfs" "SquashFS文件系统"
check_config "CONFIG_PACKAGE_kmod-fs-nfs" "NFS客户端"

echo ""
echo "3. 硬件支持:"
check_config "CONFIG_PACKAGE_kmod-usb-core" "USB核心"
check_config "CONFIG_PACKAGE_kmod-usb-storage" "USB存储"
check_config "CONFIG_PACKAGE_kmod-pci" "PCIe支持"
check_config "CONFIG_PACKAGE_kmod-hwmon-core" "硬件监控"

echo ""
echo "=== 配置统计 ==="
echo "内核配置项总数: $(grep -c "^CONFIG_" .config)"
echo "编译进内核: $(grep "^CONFIG_.*=y" .config | wc -l)"
echo "编译为模块: $(grep "^CONFIG_.*=m" .config | wc -l)"
echo "禁用项: $(grep "^# CONFIG_.* is not set" .config | wc -l)"
