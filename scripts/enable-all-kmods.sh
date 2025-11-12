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

# 函数：检查并启用包（如果尚未启用）
check_and_enable_package() {
    local pkg=$1
    local description=$2
    
    # 检查包是否已经启用
    if ./scripts/config --state "PACKAGE_$pkg" 2>/dev/null | grep -q "undef"; then
        echo "启用包: $pkg ($description)"
        ./scripts/config --enable "PACKAGE_$pkg" 2>/dev/null && echo "✅ 成功" || echo "⚠️ 无法设置 PACKAGE_$pkg"
    else
        echo "✅ 包已启用: $pkg ($description)"
    fi
}

# 函数：启用基础系统包（修复依赖警告）
enable_base_packages() {
    echo "2. 启用基础系统包（修复依赖）..."
    
    BASE_PACKAGES=(
        # 核心工具（修复依赖警告）
        "coreutils:coreutils工具集"
        "coreutils-sort:排序工具"
        "coreutils-od:八进制转储工具"
        "coreutils-stat:文件状态工具"
        "coreutils-tee:分流输出工具"
        "coreutils-mktemp:创建临时文件"
        "coreutils-chroot:改变根目录"
        "coreutils-sha1sum:SHA1校验"
        "coreutils-sleep:延时工具"
        "coreutils-date:日期时间工具"
        "coreutils-timeout:超时控制"
        "coreutils-dirname:目录名工具"
        "coreutils-stty:终端设置"
        
        # 系统库（修复依赖警告）
        "libpam:PAM认证库"
        "libtirpc:RPC库"
        "python3-distutils:Python分发工具"
        "python3-lib2to3:Python代码转换"
        "luci-lua-runtime:Luci Lua运行时"
        
        # 基础网络工具
        "iptables:iptables防火墙"
        "ip6tables:IPv6 iptables"
        "firewall:防火墙"
        "firewall4:IPv4防火墙"
        
        # Python 支持
        "python3:Python 3"
        "python3-light:Python 3轻量版"
        
        # Luci 相关
        "luci:Luci网页界面"
        "luci-base:Luci基础"
        "luci-compat:Luci兼容层"
        "luci-theme-bootstrap:Bootstrap主题"
        "luci-theme-argon:Argon主题"
    )
    
    for pkg_info in "${BASE_PACKAGES[@]}"; do
        pkg=$(echo "$pkg_info" | cut -d: -f1)
        description=$(echo "$pkg_info" | cut -d: -f2)
        check_and_enable_package "$pkg" "$description"
    done
    echo "✅ 基础包配置完成"
}

# 函数：启用特定功能包
enable_feature_packages() {
    echo "3. 启用特定功能包..."
    
    FEATURE_PACKAGES=(
        # TurboACC
        "luci-app-turboacc:TurboACC加速"
        "nft-fullcone:Fullcone NAT"
        
        # iStore 相关
        "luci-app-istorex:iStore应用商店"
        "luci-app-quickstart:快速开始"
        "luci-app-store:应用商店"
        "luci-lib-taskd:任务库"
        "quickstart:快速开始"
        "luci-lib-xterm:终端库"
        "taskd:任务服务"
        
        # 网络服务
        "ddns-scripts:动态DNS脚本"
        "watchcat:看门狗"
        "wol:网络唤醒"
        "upnp:UPnP服务"
        
        # 存储工具
        "block-mount:块设备挂载"
        "fdisk:磁盘分区"
        "lsblk:列出块设备"
        "e2fsprogs:EXT文件系统工具"
        
        # 诊断工具
        "tcpdump:网络抓包"
        "iperf3:网络性能测试"
        "iputils-ping:ping工具"
        "iputils-traceroute:traceroute工具"
        
        # 系统工具
        "bash:Bash shell"
        "htop:进程监控"
        "nano:文本编辑器"
        "curl:网络工具"
        "wget:下载工具"
        "tar:归档工具"
    )
    
    for pkg_info in "${FEATURE_PACKAGES[@]}"; do
        pkg=$(echo "$pkg_info" | cut -d: -f1)
        description=$(echo "$pkg_info" | cut -d: -f2)
        check_and_enable_package "$pkg" "$description"
    done
    echo "✅ 功能包配置完成"
}

# 函数：验证 kmod 包状态
verify_kmods_status() {
    echo "4. 验证 kmod 包状态..."
    
    # 检查一些关键 kmod 包的状态
    KEY_KMODS=(
        "kmod-ppp:PPP支持"
        "kmod-pppoe:PPPoE支持"
        "kmod-nf-nat:Netfilter NAT"
        "kmod-ipt-core:iptables核心"
        "kmod-fs-ext4:EXT4文件系统"
        "kmod-usb-core:USB核心"
        "kmod-usb-storage:USB存储"
        "kmod-crypto-core:加密核心"
    )
    
    echo "关键 kmod 包状态:"
    for kmod_info in "${KEY_KMODS[@]}"; do
        kmod=$(echo "$kmod_info" | cut -d: -f1)
        description=$(echo "$kmod_info" | cut -d: -f2)
        
        # 检查包状态
        state=$(./scripts/config --state "PACKAGE_$kmod" 2>/dev/null || echo "unknown")
        case "$state" in
            "y") echo "  ✅ $kmod: 编译进固件 ($description)" ;;
            "m") echo "  📦 $kmod: 编译为模块 ($description)" ;;
            "undef") echo "  ❌ $kmod: 未启用 ($description)" ;;
            *) echo "  ⚠️ $kmod: 状态未知 ($state)" ;;
        esac
    done
    echo "✅ kmod 状态验证完成"
}

# 函数：生成包状态报告
generate_package_report() {
    echo "5. 生成包状态报告..."
    
    # 统计包状态
    total_packages=$(grep "^CONFIG_PACKAGE_" .config | wc -l)
    enabled_packages=$(grep "^CONFIG_PACKAGE_.*=y" .config | wc -l)
    module_packages=$(grep "^CONFIG_PACKAGE_.*=m" .config | wc -l)
    disabled_packages=$(grep "^# CONFIG_PACKAGE_.* is not set" .config | wc -l)
    
    echo "=== 包状态统计 ==="
    echo "总包数: $total_packages"
    echo "编译进固件: $enabled_packages"
    echo "编译为模块: $module_packages"
    echo "禁用包数: $disabled_packages"
    
    # 检查 CONFIG_ALL_KMODS 状态
    if grep -q "^CONFIG_ALL_KMODS=y" .config; then
        echo "✅ CONFIG_ALL_KMODS: 已启用 (自动包含所有内核模块)"
    else
        echo "❌ CONFIG_ALL_KMODS: 未启用"
    fi
}

# 主执行流程
main() {
    echo "开始配置包..."
    
    setup_config_tool
    enable_base_packages
    enable_feature_packages
    verify_kmods_status
    generate_package_report
    
    echo "🎉 包配置完成！"
    echo ""
    echo "注意: 由于 CONFIG_ALL_KMODS=y 已启用，所有内核模块包已自动包含"
    echo "此脚本主要修复依赖警告和启用用户空间包"
}

# 运行主函数
main "$@"
