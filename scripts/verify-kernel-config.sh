#!/bin/bash

echo "=== 内核配置验证 ==="

# 检查关键配置是否启用
check_config() {
    local config=$1
    local description=$2
    
    if grep -q "^$config=y" .config; then
        echo "✅ $description: 已启用"
    elif grep -q "^$config=m" .config; then
        echo "⚠️ $description: 模块方式"
    else
        echo "❌ $description: 未启用"
    fi
}

echo "1. 网络功能检查:"
check_config "CONFIG_PPP" "PPP支持"
check_config "CONFIG_PPPOE" "PPPoE支持"
check_config "CONFIG_NETFILTER" "Netfilter"
check_config "CONFIG_NF_NAT" "NAT支持"
check_config "CONFIG_NFTABLES" "nftables"

echo ""
echo "2. 文件系统检查:"
check_config "CONFIG_EXT4_FS" "EXT4文件系统"
check_config "CONFIG_NFS_FS" "NFS客户端"
check_config "CONFIG_CIFS" "CIFS/SMB客户端"
check_config "CONFIG_FUSE_FS" "FUSE文件系统"

echo ""
echo "3. 硬件支持检查:"
check_config "CONFIG_USB" "USB支持"
check_config "CONFIG_PCI" "PCIe支持"
check_config "CONFIG_HWMON" "硬件监控"
check_config "CONFIG_RTC_CLASS" "实时时钟"

echo ""
echo "4. 虚拟化检查:"
check_config "CONFIG_VIRTUALIZATION" "虚拟化"
check_config "CONFIG_KVM" "KVM虚拟化"
check_config "CONFIG_NAMESPACES" "命名空间"
check_config "CONFIG_CGROUPS" "控制组"

echo ""
echo "5. 安全功能检查:"
check_config "CONFIG_SECURITY" "安全框架"
check_config "CONFIG_KEYS" "密钥管理"
check_config "CONFIG_CRYPTO" "加密算法"

echo ""
echo "=== 配置统计 ==="
echo "总配置项: $(grep -c "^CONFIG_" .config)"
echo "直接编译进内核: $(grep "^CONFIG_.*=y" .config | wc -l)"
echo "编译为模块: $(grep "^CONFIG_.*=m" .config | wc -l)"
echo "禁用项: $(grep "^# CONFIG_.* is not set" .config | wc -l)"
