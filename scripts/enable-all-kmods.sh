#!/bin/bash

set -e

echo "=== 启用所有内核模块和功能 ==="

# 函数：设置配置工具
setup_config_tool() {
    echo "1. 设置配置工具..."
    if [ ! -f "./scripts/config" ]; then
        echo "编译config工具..."
        make tools/install -j$(nproc) V=0 > /dev/null 2>&1
        echo "✅ 配置工具就绪"
    fi
}

# 函数：启用所有内核网络功能
enable_network_features() {
    echo "2. 启用网络功能..."
    
    NETWORK_CONFIGS=(
        # PPP 相关
        "CONFIG_PPP" "CONFIG_PPPOE" "CONFIG_PPP_ASYNC" "CONFIG_PPP_SYNC_TTY"
        "CONFIG_PPP_DEFLATE" "CONFIG_PPP_MPPE" "CONFIG_PPPOL2TP" "CONFIG_PPPOX"
        
        # 网络协议
        "CONFIG_NET" "CONFIG_INET" "CONFIG_IPV6" "CONFIG_NETDEVICES"
        "CONFIG_NET_CORE" "CONFIG_NETWORK_FILESYSTEMS"
        
        # 网络过滤和防火墙
        "CONFIG_NETFILTER" "CONFIG_NETFILTER_ADVANCED" "CONFIG_NF_CONNTRACK"
        "CONFIG_NF_NAT" "CONFIG_NF_TABLES" "CONFIG_NFT_COMPAT" "CONFIG_NFT_COUNTER"
        "CONFIG_NFT_CT" "CONFIG_NFT_LIMIT" "CONFIG_NFT_LOG" "CONFIG_NFT_MASQ"
        "CONFIG_NFT_REDIR" "CONFIG_NFT_REJECT" "CONFIG_NFT_SET"
        
        # 网络调度和质量服务
        "CONFIG_NET_SCHED" "CONFIG_NET_SCH_FQ_CODEL" "CONFIG_NET_SCH_CAKE"
        "CONFIG_NET_SCH_SFQ" "CONFIG_NET_SCH_HTB" "CONFIG_NET_SCH_PRIO"
        
        # 网络加密和VPN
        "CONFIG_NET_IPGRE" "CONFIG_NET_IPGRE_BROADCAST" "CONFIG_NET_IPIP"
        "CONFIG_NET_FOU" "CONFIG_NET_FOU_IP_TUNNELS"
        
        # 无线网络
        "CONFIG_WIRELESS" "CONFIG_CFG80211" "CONFIG_MAC80211"
        "CONFIG_WLAN" "CONFIG_WLAN_VENDOR_ATH" "CONFIG_WLAN_VENDOR_MEDIATEK"
        
        # 蓝牙
        "CONFIG_BT" "CONFIG_BT_RFCOMM" "CONFIG_BT_BNEP" "CONFIG_BT_HIDP"
        "CONFIG_BT_HS" "CONFIG_BT_LE" "CONFIG_BT_6LOWPAN"
        
        # USB网络
        "CONFIG_USB_USBNET" "CONFIG_USB_NET_AX8817X" "CONFIG_USB_NET_AX88179_178A"
        "CONFIG_USB_NET_CDCETHER" "CONFIG_USB_NET_CDC_EEM" "CONFIG_USB_NET_CDC_NCM"
        
        # 虚拟网络设备
        "CONFIG_VETH" "CONFIG_TUN" "CONFIG_MACVLAN" "CONFIG_IPVLAN"
        "CONFIG_VXLAN" "CONFIG_GENEVE"
    )
    
    for config in "${NETWORK_CONFIGS[@]}"; do
        ./scripts/config --set-val "$config" y 2>/dev/null || echo "⚠️ 无法设置 $config"
    done
    echo "✅ 网络功能配置完成"
}

# 函数：启用文件系统和存储功能
enable_filesystem_features() {
    echo "3. 启用文件系统和存储功能..."
    
    FS_CONFIGS=(
        # 基础文件系统
        "CONFIG_EXT4_FS" "CONFIG_VFAT_FS" "CONFIG_FAT_FS" "CONFIG_MSDOS_FS"
        "CONFIG_NTFS_FS" "CONFIG_TMPFS" "CONFIG_DEVTMPFS" "CONFIG_PROC_FS"
        "CONFIG_SYSFS" "CONFIG_CONFIGFS_FS" "CONFIG_EFIVAR_FS"
        
        # 网络文件系统
        "CONFIG_NFS_FS" "CONFIG_NFS_V3" "CONFIG_NFS_V4" "CONFIG_ROOT_NFS"
        "CONFIG_CIFS" "CONFIG_SMB_SERVER" "CONFIG_9P_FS"
        
        # 压缩文件系统
        "CONFIG_SQUASHFS" "CONFIG_SQUASHFS_XZ" "CONFIG_SQUASHFS_LZO"
        "CONFIG_SQUASHFS_LZ4" "CONFIG_SQUASHFS_ZSTD"
        
        # 加密文件系统
        "CONFIG_FS_ENCRYPTION" "CONFIG_FSCRYPT_SDP" "CONFIG_EXT4_ENCRYPTION"
        
        # FUSE
        "CONFIG_FUSE_FS" "CONFIG_CUSE"
        
        # 存储设备
        "CONFIG_BLK_DEV" "CONFIG_SCSI" "CONFIG_SATA_AHCI" "CONFIG_ATA"
        "CONFIG_USB_STORAGE" "CONFIG_MMC" "CONFIG_MMC_BLOCK"
        
        # RAID和LVM
        "CONFIG_MD" "CONFIG_BLK_DEV_MD" "CONFIG_MD_LINEAR" "CONFIG_MD_RAID0"
        "CONFIG_MD_RAID1" "CONFIG_MD_RAID10" "CONFIG_BLK_DEV_DM"
        
        # NVMe
        "CONFIG_NVME_CORE" "CONFIG_BLK_DEV_NVME"
    )
    
    for config in "${FS_CONFIGS[@]}"; do
        ./scripts/config --set-val "$config" y 2>/dev/null || echo "⚠️ 无法设置 $config"
    done
    echo "✅ 文件系统功能配置完成"
}

# 函数：启用硬件支持
enable_hardware_support() {
    echo "4. 启用硬件支持..."
    
    HARDWARE_CONFIGS=(
        # CPU架构
        "CONFIG_ARM64" "CONFIG_ARCH_ROCKCHIP" "CONFIG_CPU_FREQ"
        "CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND" "CONFIG_CPU_FREQ_GOV_PERFORMANCE"
        
        # USB支持
        "CONFIG_USB" "CONFIG_USB_SUPPORT" "CONFIG_USB_XHCI_HCD" "CONFIG_USB_EHCI_HCD"
        "CONFIG_USB_OHCI_HCD" "CONFIG_USB_ACM" "CONFIG_USB_SERIAL"
        "CONFIG_USB_SERIAL_FTDI_SIO" "CONFIG_USB_SERIAL_PL2303"
        
        # PCIe支持
        "CONFIG_PCI" "CONFIG_PCIEPORTBUS" "CONFIG_PCIE_ROCKCHIP"
        
        # GPIO和I2C
        "CONFIG_GPIOLIB" "CONFIG_GPIO_SYSFS" "CONFIG_I2C" "CONFIG_I2C_CHARDEV"
        
        # 硬件监控
        "CONFIG_HWMON" "CONFIG_SENSORS_CORE" "CONFIG_THERMAL"
        "CONFIG_CPU_THERMAL" "CONFIG_DEVFREQ_THERMAL"
        
        # 实时时钟
        "CONFIG_RTC_CLASS" "CONFIG_RTC_DRV_RK808"
        
        # DMA
        "CONFIG_DMADEVICES" "CONFIG_PL330_DMA"
        
        # 加密硬件加速
        "CONFIG_CRYPTO_DEV_ROCKCHIP" "CONFIG_CRYPTO_SHA1_ARM64_CE"
        "CONFIG_CRYPTO_SHA2_ARM64_CE" "CONFIG_CRYPTO_AES_ARM64_CE"
    )
    
    for config in "${HARDWARE_CONFIGS[@]}"; do
        ./scripts/config --set-val "$config" y 2>/dev/null || echo "⚠️ 无法设置 $config"
    done
    echo "✅ 硬件支持配置完成"
}

# 函数：启用虚拟化和容器支持
enable_virtualization_features() {
    echo "5. 启用虚拟化和容器支持..."
    
    VIRT_CONFIGS=(
        "CONFIG_VIRTUALIZATION" "CONFIG_KVM" "CONFIG_VHOST" "CONFIG_VHOST_NET"
        "CONFIG_NAMESPACES" "CONFIG_UTS_NS" "CONFIG_IPC_NS" "CONFIG_USER_NS"
        "CONFIG_PID_NS" "CONFIG_NET_NS" "CONFIG_CGROUPS" "CONFIG_CGROUP_CPUACCT"
        "CONFIG_CGROUP_DEVICE" "CONFIG_CGROUP_FREEZER" "CONFIG_CGROUP_SCHED"
        "CONFIG_CPUSETS" "CONFIG_MEMCG"
    )
    
    for config in "${VIRT_CONFIGS[@]}"; do
        ./scripts/config --set-val "$config" y 2>/dev/null || echo "⚠️ 无法设置 $config"
    done
    echo "✅ 虚拟化功能配置完成"
}

# 函数：启用安全功能
enable_security_features() {
    echo "6. 启用安全功能..."
    
    SECURITY_CONFIGS=(
        "CONFIG_SECURITY" "CONFIG_SECURITYFS" "CONFIG_SECURITY_SELINUX"
        "CONFIG_SECURITY_APPARMOR" "CONFIG_KEYS" "CONFIG_CRYPTO"
        "CONFIG_CRYPTO_AES" "CONFIG_CRYPTO_CBC" "CONFIG_CRYPTO_ECB"
        "CONFIG_CRYPTO_SHA1" "CONFIG_CRYPTO_SHA256" "CONFIG_CRYPTO_SHA512"
        "CONFIG_CRYPTO_MD5" "CONFIG_CRYPTO_HMAC" "CONFIG_CRYPTO_RSA"
        "CONFIG_CRYPTO_ECDH" "CONFIG_CRYPTO_DRBG" "CONFIG_CRYPTO_JITTERENTROPY"
        "CONFIG_CRYPTO_USER_API" "CONFIG_CRYPTO_USER_API_HASH"
        "CONFIG_CRYPTO_USER_API_SKCIPHER" "CONFIG_CRYPTO_USER_API_RNG"
        "CONFIG_CRYPTO_USER_API_AEAD"
    )
    
    for config in "${SECURITY_CONFIGS[@]}"; do
        ./scripts/config --set-val "$config" y 2>/dev/null || echo "⚠️ 无法设置 $config"
    done
    echo "✅ 安全功能配置完成"
}

# 函数：启用调试和性能分析
enable_debug_features() {
    echo "7. 启用调试和性能分析功能..."
    
    DEBUG_CONFIGS=(
        "CONFIG_DEBUG_FS" "CONFIG_DEBUG_KERNEL" "CONFIG_DEBUG_INFO"
        "CONFIG_PROFILING" "CONFIG_PERF_EVENTS" "CONFIG_FTRACE"
        "CONFIG_KPROBES" "CONFIG_UPROBES" "CONFIG_KALLSYMS"
        "CONFIG_KALLSYMS_ALL" "CONFIG_STACKTRACE"
    )
    
    for config in "${DEBUG_CONFIGS[@]}"; do
        ./scripts/config --set-val "$config" y 2>/dev/null || echo "⚠️ 无法设置 $config"
    done
    echo "✅ 调试功能配置完成"
}

# 函数：启用内核基础功能
enable_kernel_base_features() {
    echo "8. 启用内核基础功能..."
    
    BASE_CONFIGS=(
        "CONFIG_MODULES" "CONFIG_MODULE_UNLOAD" "CONFIG_MODULE_FORCE_UNLOAD"
        "CONFIG_MODVERSIONS" "CONFIG_MODULE_SIG" "CONFIG_MODULE_SIG_FORCE"
        "CONFIG_MODULE_SIG_ALL" "CONFIG_MODULE_SIG_SHA512"
        
        # 内存管理
        "CONFIG_SWAP" "CONFIG_ZSWAP" "CONFIG_ZRAM" "CONFIG_ZSMALLOC"
        "CONFIG_HIGHMEM" "CONFIG_TRANSPARENT_HUGEPAGE"
        
        # 进程调度
        "CONFIG_PREEMPT" "CONFIG_CPU_IDLE" "CONFIG_CPUFREQ_DT"
        
        # 电源管理
        "CONFIG_PM" "CONFIG_PM_WAKELOCKS" "CONFIG_PM_DEBUG"
        
        # 设备树
        "CONFIG_OF" "CONFIG_OF_OVERLAY"
    )
    
    for config in "${BASE_CONFIGS[@]}"; do
        ./scripts/config --set-val "$config" y 2>/dev/null || echo "⚠️ 无法设置 $config"
    done
    echo "✅ 内核基础功能配置完成"
}

# 主执行流程
main() {
    echo "开始启用所有内核功能..."
    
    setup_config_tool
    
    enable_kernel_base_features
    enable_network_features
    enable_filesystem_features
    enable_hardware_support
    enable_virtualization_features
    enable_security_features
    enable_debug_features
    
    echo "🎉 所有内核功能启用完成！"
    
    # 显示配置统计
    echo ""
    echo "=== 配置统计 ==="
    echo "已启用的配置项数量: $(grep "=y" .config | wc -l)"
    echo "已启用的模块数量: $(grep "=m" .config | wc -l)"
    echo "禁用的配置项数量: $(grep "is not set" .config | wc -l)"
}

# 运行主函数
main "$@"
