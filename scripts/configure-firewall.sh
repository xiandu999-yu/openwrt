#!/bin/bash
# 防火墙配置脚本
# 作者: AI Assistant
# 功能: 配置 TurboACC 相关的防火墙设置

set -e

echo "=== 配置 TurboACC 防火墙功能 ==="

# 参数处理
TURBOACC_METHOD=${1:-"immortalwrt"}  # 默认值
INCLUDE_SFE=${2:-"true"}              # 默认值
BUILD_MODE=${3:-"firmware"}           # 默认值
INCLUDE_ISTORE=${4:-"true"}           # 默认值

echo "参数: TURBOACC_METHOD=$TURBOACC_METHOD, INCLUDE_SFE=$INCLUDE_SFE, BUILD_MODE=$BUILD_MODE, INCLUDE_ISTORE=$INCLUDE_ISTORE"

configure_script_solution() {
    echo "配置脚本方案的 TurboACC..."
    
    # 启用TurboACC相关包
    echo "CONFIG_PACKAGE_luci-app-turboacc=y" >> .config
    echo "CONFIG_PACKAGE_kmod-nft-fullcone=y" >> .config
    
    # 根据SFE选择配置
    if [ "$INCLUDE_SFE" = "true" ]; then
        echo "CONFIG_PACKAGE_kmod-shortcut-fe=y" >> .config
        echo "CONFIG_PACKAGE_kmod-fast-classifier=y" >> .config
        echo "CONFIG_PACKAGE_kmod-shortcut-fe-cm=y" >> .config
    fi
}

configure_immortalwrt_solution() {
    echo "配置 ImmortalWrt Fullcone NAT 方案..."
    
    # 启用全内核模块
    echo "CONFIG_ALL_KMODS=y" >> .config
    
    # 基础系统配置
    echo "CONFIG_USE_APK=y" >> .config
    
    # 禁用有问题的包
    echo "# CONFIG_PACKAGE_rtpengine is not set" >> .config
    echo "# CONFIG_PACKAGE_freeswitch is not set" >> .config
    echo "# CONFIG_PACKAGE_asterisk is not set" >> .config
    
    # Fullcone NAT - ImmortalWrt 标准方案
    echo "CONFIG_PACKAGE_firewall4=y" >> .config
    echo "CONFIG_PACKAGE_nftables-json=y" >> .config
    echo "CONFIG_PACKAGE_kmod-nft-fullcone=y" >> .config
    echo "CONFIG_PACKAGE_iptables-mod-fullconenat=y" >> .config
    echo "CONFIG_PACKAGE_kmod-ipt-fullconenat=y" >> .config
    
    # 启用标准 Fullcone 支持
    echo "CONFIG_PACKAGE_kmod-nft-nat=y" >> .config
    echo "CONFIG_PACKAGE_kmod-nf-conntrack=y" >> .config
    echo "CONFIG_PACKAGE_kmod-nf-nat=y" >> .config
    
    # Shortcut FE配置
    if [ "$INCLUDE_SFE" = "true" ]; then
        echo "CONFIG_PACKAGE_kmod-shortcut-fe=y" >> .config
        echo "CONFIG_PACKAGE_kmod-fast-classifier=y" >> .config
        echo "CONFIG_PACKAGE_kmod-shortcut-fe-drv=y" >> .config
    fi
}

configure_build_mode() {
    echo "配置编译模式: $BUILD_MODE"
    
    if [ "$BUILD_MODE" = "full" ]; then
        echo "CONFIG_PACKAGE_bash=y" >> .config
        echo "CONFIG_PACKAGE_htop=y" >> .config
        echo "CONFIG_PACKAGE_nano=y" >> .config
        echo "CONFIG_PACKAGE_vim=y" >> .config
        echo "CONFIG_PACKAGE_curl=y" >> .config
    fi
}

configure_istore() {
    echo "配置 iStore: $INCLUDE_ISTORE"
    
    if [ "$INCLUDE_ISTORE" = "true" ]; then
        echo "CONFIG_PACKAGE_luci-app-istorex=y" >> .config
        echo "CONFIG_PACKAGE_luci-app-store=y" >> .config
        echo "CONFIG_PACKAGE_luci-app-quickstart=y" >> .config
    fi
}

configure_kernel_modules() {
    echo "配置必需的内核模块..."
    
    # 网络核心模块
    echo "CONFIG_PACKAGE_kmod-ppp=y" >> .config
    echo "CONFIG_PACKAGE_kmod-pppoe=y" >> .config
    echo "CONFIG_PACKAGE_kmod-nf-nat=y" >> .config
    echo "CONFIG_PACKAGE_kmod-ipt-core=y" >> .config
    echo "CONFIG_PACKAGE_kmod-ipv6=y" >> .config
    
    # Fullcone NAT 依赖模块
    echo "CONFIG_PACKAGE_kmod-nf-conntrack=y" >> .config
    echo "CONFIG_PACKAGE_kmod-nf-conntrack-netlink=y" >> .config
    echo "CONFIG_PACKAGE_kmod-nf-nat=y" >> .config
    
    # 文件系统
    echo "CONFIG_PACKAGE_kmod-fs-ext4=y" >> .config
    echo "CONFIG_PACKAGE_kmod-fs-squashfs=y" >> .config
    echo "CONFIG_PACKAGE_kmod-fs-vfat=y" >> .config
    
    # USB支持
    echo "CONFIG_PACKAGE_kmod-usb-core=y" >> .config
    echo "CONFIG_PACKAGE_kmod-usb-storage=y" >> .config
    echo "CONFIG_PACKAGE_kmod-usb2=y" >> .config
    echo "CONFIG_PACKAGE_kmod-usb3=y" >> .config
    
    # 加密
    echo "CONFIG_PACKAGE_kmod-crypto-core=y" >> .config
    echo "CONFIG_PACKAGE_kmod-crypto-hash=y" >> .config
    
    # 其他核心模块
    echo "CONFIG_PACKAGE_kmod-nls-base=y" >> .config
    echo "CONFIG_PACKAGE_kmod-nls-utf8=y" >> .config
}

# 主执行函数
main() {
    # 根据方案选择配置
    case "$TURBOACC_METHOD" in
        "script")
            configure_script_solution
            ;;
        "immortalwrt"|"")
            configure_immortalwrt_solution
            ;;
        *)
            echo "❌ 未知的 TurboACC 方案: $TURBOACC_METHOD"
            echo "可用方案: script, immortalwrt"
            exit 1
            ;;
    esac
    
    # 通用配置
    configure_build_mode
    configure_istore
    configure_kernel_modules
    
    # 重新应用配置
    make defconfig
    echo "✅ TurboACC 配置完成"
}

# 执行主函数
main "$@"
