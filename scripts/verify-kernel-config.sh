#!/bin/bash

echo "=== 内核配置验证 ==="

check_kernel_config() {
    local config=$1
    local description=$2
    
    if grep -q "^$config=y" .config; then
        echo "✅ $description: 编译进内核"
    elif grep -q "^$config=m" .config; then
        echo "📦 $description: 编译为模块"
    else
        echo "❌ $description: 未启用"
    fi
}

echo "1. 核心功能:"
check_kernel_config "CONFIG_MODULES" "模块支持"
check_kernel_config "CONFIG_PPP" "PPP支持"
check_kernel_config "CONFIG_NETFILTER" "Netfilter"
check_kernel_config "CONFIG_IPV6" "IPv6支持"

echo ""
echo "2. 文件系统:"
check_kernel_config "CONFIG_EXT4_FS" "EXT4"
check_kernel_config "CONFIG_NFS_FS" "NFS客户端"
check_kernel_config "CONFIG_SQUASHFS" "SquashFS"

echo ""
echo "3. 硬件支持:"
check_kernel_config "CONFIG_USB" "USB"
check_kernel_config "CONFIG_PCI" "PCIe"
check_kernel_config "CONFIG_HWMON" "硬件监控"

echo ""
echo "=== 配置统计 ==="
echo "内核配置项总数: $(grep "^CONFIG_" .config | wc -l)"
echo "编译进内核: $(grep "^CONFIG_.*=y" .config | wc -l)"
echo "编译为模块: $(grep "^CONFIG_.*=m" .config | wc -l)"
