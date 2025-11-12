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

# 函数：启用所有内核相关的包
enable_kernel_packages() {
    echo "2. 启用所有内核相关包..."
    
    # 内核模块包
    KERNEL_PACKAGES=(
        # PPP 相关
        "kmod-ppp" "kmod-pppoe" "kmod-pppox"
        
        # 网络功能
        "kmod-nf-nat" "kmod-nft-core" "kmod-nft-nat" "kmod-nft-offload"
        "kmod-ipt-core" "kmod-ipt-nat" "kmod-ipt-raw"
        "kmod-br-netfilter" "kmod-netlink-diag"
        
        # 文件系统
        "kmod-fs-ext4" "kmod-fs-vfat" "kmod-fs-ntfs" "kmod-fs-squashfs"
        "kmod-fs-nfs" "kmod-fs-nfs-common" "kmod-fs-nfs-v3" "kmod-fs-nfs-v4"
        "kmod-fs-cifs" "kmod-fs-f2fs" "kmod-fs-btrfs"
        
        # 硬件支持
        "kmod-usb-core" "kmod-usb-ohci" "kmod-usb-uhci" "kmod-usb2" "kmod-usb3"
        "kmod-usb-storage" "kmod-usb-serial" "kmod-usb-serial-ftdi"
        "kmod-usb-net" "kmod-usb-net-asix" "kmod-usb-net-rtl8152"
        "kmod-mmc" "kmod-sdhci"
        
        # 加密和压缩
        "kmod-crypto-core" "kmod-crypto-aead" "kmod-crypto-authenc"
        "kmod-crypto-cbc" "kmod-crypto-ecb" "kmod-crypto-hmac"
        "kmod-crypto-md5" "kmod-crypto-sha1" "kmod-crypto-sha256"
        "kmod-crypto-user" "kmod-cryptodev"
        
        # 虚拟化
        "kmod-veth" "kmod-tun" "kmod-macvlan" "kmod-ipvlan"
        "kmod-vxlan" "kmod-geneve"
        
        # 无线
        "kmod-cfg80211" "kmod-mac80211" "kmod-ath9k-common" "kmod-ath9k"
        "kmod-ath10k" "kmod-mt76-core" "kmod-mt76x2-common" "kmod-mt76x2"
        
        # 蓝牙
        "kmod-bluetooth" "kmod-btusb" "kmod-btintel"
        
        # 其他内核功能
        "kmod-ipsec" "kmod-ipsec4" "kmod-ipsec6"
        "kmod-gre" "kmod-gre6" "kmod-ipip" "kmod-sit"
        "kmod-dnsresolver" "kmod-ikconfig" "kmod-iptunnel"
        "kmod-lib-crc-ccitt" "kmod-lib-crc16"
        "kmod-nls-base" "kmod-nls-utf8"
    )
    
    for pkg in "${KERNEL_PACKAGES[@]}"; do
        echo "启用内核包: $pkg"
        ./scripts/config --enable "PACKAGE_$pkg" 2>/dev/null || echo "⚠️ 无法设置 PACKAGE_$pkg"
    done
    echo "✅ 内核包配置完成"
}

# 函数：启用基础系统包
enable_base_packages() {
    echo "3. 启用基础系统包..."
    
    BASE_PACKAGES=(
        # 核心工具
        "coreutils" "coreutils-sort" "coreutils-od" "coreutils-stat"
        "coreutils-tee" "coreutils-mktemp" "coreutils-chroot" 
        "coreutils-sha1sum" "coreutils-sleep" "coreutils-date"
        "coreutils-timeout" "coreutils-dirname" "coreutils-stty"
        
        # 系统库
        "libpam" "libtirpc" "libopenssl" "libcurl" "libpcre"
        
        # 网络工具
        "iptables" "ip6tables" "iptables-mod-extra" "iptables-mod-filter"
        "iptables-mod-ipopt" "iptables-mod-conntrack-extra"
        "firewall" "firewall4"
        
        # Python 支持
        "python3" "python3-light" "python3-distutils" "python3-lib2to3"
        
        # Luci 相关
        "luci" "luci-base" "luci-compat" "luci-lua-runtime"
        "luci-theme-bootstrap" "luci-theme-argon"
        
        # 其他工具
        "bash" "htop" "nano" "vim" "curl" "wget" "tar" "gzip"
        "procps-ng" "usbutils" "pciutils"
    )
    
    for pkg in "${BASE_PACKAGES[@]}"; do
        echo "启用基础包: $pkg"
        ./scripts/config --enable "PACKAGE_$pkg" 2>/dev/null || echo "⚠️ 无法设置 PACKAGE_$pkg"
    done
    echo "✅ 基础包配置完成"
}

# 函数：启用特定功能包
enable_feature_packages() {
    echo "4. 启用特定功能包..."
    
    FEATURE_PACKAGES=(
        # TurboACC
        "luci-app-turboacc" "nft-fullcone"
        
        # Shortcut FE
        "kmod-shortcut-fe" "kmod-fast-classifier" "kmod-shortcut-fe-drv"
        
        # iStore 相关
        "luci-app-istorex" "luci-app-quickstart" "luci-app-store"
        "luci-lib-taskd" "quickstart" "luci-lib-xterm" "taskd"
        
        # 网络服务
        "ddns-scripts" "ddns-scripts-cloudflare" "ddns-scripts-aliyun"
        "watchcat" "wol" "upnp" "qos"
        
        # 存储
        "block-mount" "fdisk" "lsblk" "e2fsprogs" "resize2fs"
        
        # 诊断工具
        "tcpdump" "iperf3" "netperf" "iputils-ping" "iputils-traceroute"
    )
    
    for pkg in "${FEATURE_PACKAGES[@]}"; do
        echo "启用功能包: $pkg"
        ./scripts/config --enable "PACKAGE_$pkg" 2>/dev/null || echo "⚠️ 无法设置 PACKAGE_$pkg"
    done
    echo "✅ 功能包配置完成"
}

# 函数：启用所有 kmod 包（通过通配符）
enable_all_kmods() {
    echo "5. 启用所有 kmod 包..."
    
    # 使用 config 工具启用所有 kmod-* 包
    ./scripts/config --enable-pattern "kmod-*" 2>/dev/null || echo "⚠️ 无法启用 kmod-* 模式"
    
    echo "✅ 所有 kmod 包配置完成"
}

# 主执行流程
main() {
    echo "开始启用所有内核功能..."
    
    setup_config_tool
    enable_kernel_packages
    enable_base_packages
    enable_feature_packages
    enable_all_kmods
    
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
