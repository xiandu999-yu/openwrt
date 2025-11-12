#!/bin/bash

set -e

echo "=== 应用内核配置预设 ==="

# 函数：设置内核配置
set_kernel_config() {
    local config=$1
    local value=$2
    local description=$3
    
    echo "设置内核: $config=$value ($description)"
    ./scripts/config --set-val "$config" "$value" 2>/dev/null && echo "✅ 成功" || echo "❌ 失败: $config"
}

# 函数：启用内核配置
enable_kernel_config() {
    local config=$1
    local description=$2
    set_kernel_config "$config" "y" "$description"
}

# 函数：禁用内核配置  
disable_kernel_config() {
    local config=$1
    local description=$2
    set_kernel_config "$config" "n" "$description"
}

# 函数：模块化内核配置
module_kernel_config() {
    local config=$1
    local description=$2
    set_kernel_config "$config" "m" "$description"
}

main() {
    echo "1. 设置配置工具..."
    if [ ! -f "./scripts/config" ]; then
        make tools/install -j$(nproc) > /dev/null 2>&1
    fi

    echo "2. 应用内核基础配置..."
    
    # 模块系统
    enable_kernel_config "CONFIG_MODULES" "模块支持"
    enable_kernel_config "CONFIG_MODULE_UNLOAD" "模块卸载"
    enable_kernel_config "CONFIG_MODULE_FORCE_UNLOAD" "强制模块卸载"
    module_kernel_config "CONFIG_MODULE_SIG" "模块签名"
    module_kernel_config "CONFIG_MODULE_SIG_ALL" "所有模块签名"
    module_kernel_config "CONFIG_MODULE_SIG_SHA512" "模块SHA512签名"
    
    # 内存管理
    enable_kernel_config "CONFIG_SWAP" "交换分区支持"
    enable_kernel_config "CONFIG_ZSWAP" "压缩交换缓存"
    enable_kernel_config "CONFIG_ZRAM" "压缩内存盘"
    enable_kernel_config "CONFIG_ZSMALLOC" "小内存分配器"
    enable_kernel_config "CONFIG_HIGHMEM" "高端内存支持"
    enable_kernel_config "CONFIG_TRANSPARENT_HUGEPAGE" "透明大页"
    
    # 进程调度
    enable_kernel_config "CONFIG_PREEMPT" "内核抢占"
    enable_kernel_config "CONFIG_CPU_IDLE" "CPU空闲"
    enable_kernel_config "CONFIG_CPUFREQ_DT" "设备树CPU频率"
    
    # 电源管理
    enable_kernel_config "CONFIG_PM" "电源管理"
    enable_kernel_config "CONFIG_PM_WAKELOCKS" "唤醒锁"
    module_kernel_config "CONFIG_PM_DEBUG" "电源管理调试"
    
    # 设备树
    enable_kernel_config "CONFIG_OF" "设备树支持"
    enable_kernel_config "CONFIG_OF_OVERLAY" "设备树覆盖"

    echo "3. 应用网络配置..."
    
    # PPP 支持
    enable_kernel_config "CONFIG_PPP" "PPP协议"
    module_kernel_config "CONFIG_PPPOE" "PPPoE"
    module_kernel_config "CONFIG_PPP_ASYNC" "PPP异步串口"
    module_kernel_config "CONFIG_PPP_SYNC_TTY" "PPP同步TTY"
    module_kernel_config "CONFIG_PPP_DEFLATE" "PPP压缩"
    module_kernel_config "CONFIG_PPP_MPPE" "PPP加密"
    module_kernel_config "CONFIG_PPPOL2TP" "PPP over L2TP"
    module_kernel_config "CONFIG_PPPOX" "PPP over Ethernet"
    
    # 网络核心
    enable_kernel_config "CONFIG_NET" "网络支持"
    enable_kernel_config "CONFIG_INET" "IPv4"
    enable_kernel_config "CONFIG_IPV6" "IPv6"
    enable_kernel_config "CONFIG_NETDEVICES" "网络设备"
    enable_kernel_config "CONFIG_NET_CORE" "网络核心"
    enable_kernel_config "CONFIG_NETWORK_FILESYSTEMS" "网络文件系统"
    
    # Netfilter
    enable_kernel_config "CONFIG_NETFILTER" "Netfilter"
    enable_kernel_config "CONFIG_NETFILTER_ADVANCED" "高级Netfilter"
    enable_kernel_config "CONFIG_NF_CONNTRACK" "连接跟踪"
    enable_kernel_config "CONFIG_NF_NAT" "NAT支持"
    enable_kernel_config "CONFIG_NF_TABLES" "nftables"
    module_kernel_config "CONFIG_NFT_COMPAT" "nftables兼容"
    module_kernel_config "CONFIG_NFT_COUNTER" "nftables计数器"
    module_kernel_config "CONFIG_NFT_CT" "nftables连接跟踪"
    module_kernel_config "CONFIG_NFT_LIMIT" "nftables限制"
    module_kernel_config "CONFIG_NFT_LOG" "nftables日志"
    module_kernel_config "CONFIG_NFT_MASQ" "nftables伪装"
    module_kernel_config "CONFIG_NFT_REDIR" "nftables重定向"
    module_kernel_config "CONFIG_NFT_REJECT" "nftables拒绝"
    module_kernel_config "CONFIG_NFT_SET" "nftables集合"
    
    # 网络调度
    enable_kernel_config "CONFIG_NET_SCHED" "网络流量调度"
    module_kernel_config "CONFIG_NET_SCH_FQ_CODEL" "FQ-Codel"
    module_kernel_config "CONFIG_NET_SCH_CAKE" "CAKE"
    module_kernel_config "CONFIG_NET_SCH_SFQ" "SFQ"
    module_kernel_config "CONFIG_NET_SCH_HTB" "HTB"
    module_kernel_config "CONFIG_NET_SCH_PRIO" "PRIO"
    
    # 隧道协议
    module_kernel_config "CONFIG_NET_IPGRE" "GRE隧道"
    module_kernel_config "CONFIG_NET_IPGRE_BROADCAST" "GRE广播"
    module_kernel_config "CONFIG_NET_IPIP" "IPIP隧道"
    module_kernel_config "CONFIG_NET_FOU" "Foo over UDP"
    module_kernel_config "CONFIG_NET_FOU_IP_TUNNELS" "Foo over UDP隧道"

    echo "4. 应用文件系统配置..."
    
    # 基础文件系统
    enable_kernel_config "CONFIG_EXT4_FS" "EXT4文件系统"
    module_kernel_config "CONFIG_VFAT_FS" "VFAT文件系统"
    module_kernel_config "CONFIG_FAT_FS" "FAT文件系统"
    module_kernel_config "CONFIG_MSDOS_FS" "MSDOS文件系统"
    module_kernel_config "CONFIG_NTFS_FS" "NTFS文件系统"
    enable_kernel_config "CONFIG_TMPFS" "临时文件系统"
    enable_kernel_config "CONFIG_DEVTMPFS" "设备临时文件系统"
    enable_kernel_config "CONFIG_PROC_FS" "proc文件系统"
    enable_kernel_config "CONFIG_SYSFS" "sys文件系统"
    module_kernel_config "CONFIG_CONFIGFS_FS" "configfs"
    module_kernel_config "CONFIG_EFIVAR_FS" "EFI变量文件系统"
    
    # 网络文件系统
    module_kernel_config "CONFIG_NFS_FS" "NFS客户端"
    module_kernel_config "CONFIG_NFS_V3" "NFS v3"
    module_kernel_config "CONFIG_NFS_V4" "NFS v4"
    module_kernel_config "CONFIG_ROOT_NFS" "NFS根文件系统"
    module_kernel_config "CONFIG_CIFS" "CIFS/SMB客户端"
    module_kernel_config "CONFIG_SMB_SERVER" "SMB服务器"
    module_kernel_config "CONFIG_9P_FS" "9P文件系统"
    
    # 压缩文件系统
    enable_kernel_config "CONFIG_SQUASHFS" "SquashFS"
    enable_kernel_config "CONFIG_SQUASHFS_XZ" "SquashFS XZ压缩"
    enable_kernel_config "CONFIG_SQUASHFS_LZO" "SquashFS LZO压缩"
    enable_kernel_config "CONFIG_SQUASHFS_LZ4" "SquashFS LZ4压缩"
    enable_kernel_config "CONFIG_SQUASHFS_ZSTD" "SquashFS ZSTD压缩"
    
    # 加密文件系统
    module_kernel_config "CONFIG_FS_ENCRYPTION" "文件系统加密"
    module_kernel_config "CONFIG_FSCRYPT_SDP" "文件系统加密SDP"
    module_kernel_config "CONFIG_EXT4_ENCRYPTION" "EXT4加密"
    
    # FUSE
    module_kernel_config "CONFIG_FUSE_FS" "FUSE文件系统"
    module_kernel_config "CONFIG_CUSE" "字符设备FUSE"

    echo "5. 应用硬件支持配置..."
    
    # 架构特定
    enable_kernel_config "CONFIG_ARM64" "ARM64架构"
    enable_kernel_config "CONFIG_ARCH_ROCKCHIP" "Rockchip平台"
    enable_kernel_config "CONFIG_CPU_FREQ" "CPU频率调节"
    module_kernel_config "CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND" "按需调频"
    module_kernel_config "CONFIG_CPU_FREQ_GOV_PERFORMANCE" "性能调频"
    
    # USB支持
    enable_kernel_config "CONFIG_USB" "USB支持"
    enable_kernel_config "CONFIG_USB_SUPPORT" "USB子系统"
    enable_kernel_config "CONFIG_USB_XHCI_HCD" "xHCI USB控制器"
    enable_kernel_config "CONFIG_USB_EHCI_HCD" "EHCI USB控制器"
    enable_kernel_config "CONFIG_USB_OHCI_HCD" "OHCI USB控制器"
    module_kernel_config "CONFIG_USB_ACM" "USB ACM设备"
    module_kernel_config "CONFIG_USB_SERIAL" "USB串口设备"
    module_kernel_config "CONFIG_USB_SERIAL_FTDI_SIO" "FTDI串口"
    module_kernel_config "CONFIG_USB_SERIAL_PL2303" "PL2303串口"
    
    # PCIe支持
    enable_kernel_config "CONFIG_PCI" "PCI支持"
    enable_kernel_config "CONFIG_PCIEPORTBUS" "PCIe端口总线"
    enable_kernel_config "CONFIG_PCIE_ROCKCHIP" "Rockchip PCIe"
    
    # GPIO和I2C
    enable_kernel_config "CONFIG_GPIOLIB" "GPIO库"
    module_kernel_config "CONFIG_GPIO_SYSFS" "GPIO Sysfs"
    enable_kernel_config "CONFIG_I2C" "I2C支持"
    module_kernel_config "CONFIG_I2C_CHARDEV" "I2C字符设备"
    
    # 硬件监控
    enable_kernel_config "CONFIG_HWMON" "硬件监控"
    enable_kernel_config "CONFIG_SENSORS_CORE" "传感器核心"
    enable_kernel_config "CONFIG_THERMAL" "热管理"
    enable_kernel_config "CONFIG_CPU_THERMAL" "CPU热管理"
    enable_kernel_config "CONFIG_DEVFREQ_THERMAL" "设备频率热管理"
    
    # 实时时钟
    enable_kernel_config "CONFIG_RTC_CLASS" "RTC类"
    module_kernel_config "CONFIG_RTC_DRV_RK808" "RK808 RTC"
    
    # DMA
    enable_kernel_config "CONFIG_DMADEVICES" "DMA设备"
    enable_kernel_config "CONFIG_PL330_DMA" "PL330 DMA"
    
    # 加密加速
    module_kernel_config "CONFIG_CRYPTO_DEV_ROCKCHIP" "Rockchip加密加速"
    module_kernel_config "CONFIG_CRYPTO_SHA1_ARM64_CE" "ARM64 SHA1加速"
    module_kernel_config "CONFIG_CRYPTO_SHA2_ARM64_CE" "ARM64 SHA2加速"
    module_kernel_config "CONFIG_CRYPTO_AES_ARM64_CE" "ARM64 AES加速"

    echo "6. 应用虚拟化配置..."
    
    enable_kernel_config "CONFIG_VIRTUALIZATION" "虚拟化"
    module_kernel_config "CONFIG_KVM" "KVM虚拟化"
    module_kernel_config "CONFIG_VHOST" "vhost"
    module_kernel_config "CONFIG_VHOST_NET" "vhost网络"
    
    # 命名空间
    enable_kernel_config "CONFIG_NAMESPACES" "命名空间"
    enable_kernel_config "CONFIG_UTS_NS" "UTS命名空间"
    enable_kernel_config "CONFIG_IPC_NS" "IPC命名空间"
    enable_kernel_config "CONFIG_USER_NS" "用户命名空间"
    enable_kernel_config "CONFIG_PID_NS" "PID命名空间"
    enable_kernel_config "CONFIG_NET_NS" "网络命名空间"
    
    # 控制组
    enable_kernel_config "CONFIG_CGROUPS" "控制组"
    enable_kernel_config "CONFIG_CGROUP_CPUACCT" "CPU统计控制组"
    enable_kernel_config "CONFIG_CGROUP_DEVICE" "设备控制组"
    enable_kernel_config "CONFIG_CGROUP_FREEZER" "冻结控制组"
    enable_kernel_config "CONFIG_CGROUP_SCHED" "调度控制组"
    enable_kernel_config "CONFIG_CPUSETS" "CPU集合"
    enable_kernel_config "CONFIG_MEMCG" "内存控制组"

    echo "7. 应用安全配置..."
    
    enable_kernel_config "CONFIG_SECURITY" "安全框架"
    enable_kernel_config "CONFIG_SECURITYFS" "安全文件系统"
    module_kernel_config "CONFIG_SECURITY_SELINUX" "SELinux"
    module_kernel_config "CONFIG_SECURITY_APPARMOR" "AppArmor"
    enable_kernel_config "CONFIG_KEYS" "密钥管理"
    enable_kernel_config "CONFIG_CRYPTO" "加密算法"
    
    # 加密算法
    enable_kernel_config "CONFIG_CRYPTO_AES" "AES加密"
    enable_kernel_config "CONFIG_CRYPTO_CBC" "CBC模式"
    enable_kernel_config "CONFIG_CRYPTO_ECB" "ECB模式"
    enable_kernel_config "CONFIG_CRYPTO_SHA1" "SHA1哈希"
    enable_kernel_config "CONFIG_CRYPTO_SHA256" "SHA256哈希"
    enable_kernel_config "CONFIG_CRYPTO_SHA512" "SHA512哈希"
    enable_kernel_config "CONFIG_CRYPTO_MD5" "MD5哈希"
    enable_kernel_config "CONFIG_CRYPTO_HMAC" "HMAC"
    module_kernel_config "CONFIG_CRYPTO_RSA" "RSA加密"
    module_kernel_config "CONFIG_CRYPTO_ECDH" "ECDH加密"
    enable_kernel_config "CONFIG_CRYPTO_DRBG" "确定性随机数"
    enable_kernel_config "CONFIG_CRYPTO_JITTERENTROPY" "抖动熵"
    
    # 用户空间加密API
    module_kernel_config "CONFIG_CRYPTO_USER_API" "用户空间加密API"
    module_kernel_config "CONFIG_CRYPTO_USER_API_HASH" "用户空间哈希API"
    module_kernel_config "CONFIG_CRYPTO_USER_API_SKCIPHER" "用户空间对称加密API"
    module_kernel_config "CONFIG_CRYPTO_USER_API_RNG" "用户空间随机数API"
    module_kernel_config "CONFIG_CRYPTO_USER_API_AEAD" "用户空间AEAD API"

    echo "8. 应用调试配置..."
    
    enable_kernel_config "CONFIG_DEBUG_FS" "调试文件系统"
    enable_kernel_config "CONFIG_DEBUG_KERNEL" "内核调试"
    enable_kernel_config "CONFIG_DEBUG_INFO" "调试信息"
    enable_kernel_config "CONFIG_PROFILING" "性能分析"
    enable_kernel_config "CONFIG_PERF_EVENTS" "性能事件"
    enable_kernel_config "CONFIG_FTRACE" "函数跟踪"
    module_kernel_config "CONFIG_KPROBES" "内核探针"
    module_kernel_config "CONFIG_UPROBES" "用户空间探针"
    enable_kernel_config "CONFIG_KALLSYMS" "内核符号"
    enable_kernel_config "CONFIG_KALLSYMS_ALL" "所有内核符号"
    enable_kernel_config "CONFIG_STACKTRACE" "堆栈跟踪"

    echo "✅ 内核配置应用完成"
}

main "$@"
