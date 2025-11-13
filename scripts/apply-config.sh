#!/bin/bash
# 配置应用脚本
# 作者: AI Assistant
# 功能: 在无终端环境下应用配置

set -e

echo "=== 应用配置（无终端环境）==="

# 参数
TARGET_DEVICE=$1
TURBOACC_METHOD=$2
INCLUDE_SFE=$3
INCLUDE_ISTORE=$4
BUILD_MODE=$5

echo "参数: TARGET_DEVICE=$TARGET_DEVICE, TURBOACC_METHOD=$TURBOACC_METHOD"
echo "参数: INCLUDE_SFE=$INCLUDE_SFE, INCLUDE_ISTORE=$INCLUDE_ISTORE, BUILD_MODE=$BUILD_MODE"

# 应用基础设备配置
apply_device_config() {
    echo "应用设备配置: $TARGET_DEVICE"
    
    case "$TARGET_DEVICE" in
        "nanopi-r3s")
            if [ -f "configs/nanopi-r3s.config" ]; then
                cp configs/nanopi-r3s.config .config
                echo "使用 NanoPi R3S 配置"
            else
                echo "❌ 找不到 NanoPi R3S 配置文件"
                exit 1
            fi
            ;;
        "nanopi-r6s")
            if [ -f "configs/nanopi-r6s.config" ]; then
                cp configs/nanopi-r6s.config .config
                echo "使用 NanoPi R6S 配置"
            else
                echo "❌ 找不到 NanoPi R6S 配置文件"
                exit 1
            fi
            ;;
        *)
            echo "❌ 未知设备: $TARGET_DEVICE"
            exit 1
            ;;
    esac
}

# 应用 TurboACC 配置
apply_turboacc_config() {
    echo "应用 TurboACC 配置: $TURBOACC_METHOD"
    
    case "$TURBOACC_METHOD" in
        "script")
            apply_script_turboacc
            ;;
        "immortalwrt"|"")
            apply_immortalwrt_turboacc
            ;;
        *)
            echo "❌ 未知的 TurboACC 方案: $TURBOACC_METHOD"
            exit 1
            ;;
    esac
}

apply_script_turboacc() {
    echo "配置脚本方案 TurboACC..."
    
    echo "CONFIG_PACKAGE_luci-app-turboacc=y" >> .config
    echo "CONFIG_PACKAGE_kmod-nft-fullcone=y" >> .config
    
    if [ "$INCLUDE_SFE" = "true" ]; then
        echo "CONFIG_PACKAGE_kmod-shortcut-fe=y" >> .config
        echo "CONFIG_PACKAGE_kmod-fast-classifier=y" >> .config
        echo "CONFIG_PACKAGE_kmod-shortcut-fe-cm=y" >> .config
    fi
}

apply_immortalwrt_turboacc() {
    echo "配置 ImmortalWrt Fullcone NAT 方案..."
    
    # 基础配置
    echo "CONFIG_ALL_KMODS=y" >> .config
    echo "CONFIG_USE_APK=y" >> .config
    
    # 禁用有问题的包
    echo "# CONFIG_PACKAGE_rtpengine is not set" >> .config
    echo "# CONFIG_PACKAGE_freeswitch is not set" >> .config
    echo "# CONFIG_PACKAGE_asterisk is not set" >> .config
    
    # Fullcone NAT
    echo "CONFIG_PACKAGE_firewall4=y" >> .config
    echo "CONFIG_PACKAGE_nftables-json=y" >> .config
    echo "CONFIG_PACKAGE_kmod-nft-fullcone=y" >> .config
    echo "CONFIG_PACKAGE_iptables-mod-fullconenat=y" >> .config
    echo "CONFIG_PACKAGE_kmod-ipt-fullconenat=y" >> .config
    
    # 网络核心模块
    echo "CONFIG_PACKAGE_kmod-nft-nat=y" >> .config
    echo "CONFIG_PACKAGE_kmod-nf-conntrack=y" >> .config
    echo "CONFIG_PACKAGE_kmod-nf-nat=y" >> .config
    
    # Shortcut FE
    if [ "$INCLUDE_SFE" = "true" ]; then
        echo "CONFIG_PACKAGE_kmod-shortcut-fe=y" >> .config
        echo "CONFIG_PACKAGE_kmod-fast-classifier=y" >> .config
        echo "CONFIG_PACKAGE_kmod-shortcut-fe-drv=y" >> .config
    fi
}

# 应用 iStore 配置
apply_istore_config() {
    echo "应用 iStore 配置: $INCLUDE_ISTORE"
    
    if [ "$INCLUDE_ISTORE" = "true" ]; then
        echo "✅ 启用 iStore 相关功能"
        
        # iStore 核心包
        echo "CONFIG_PACKAGE_luci-app-istorex=y" >> .config
        echo "CONFIG_PACKAGE_luci-app-store=y" >> .config
        echo "CONFIG_PACKAGE_luci-app-quickstart=y" >> .config
        
        # iStore 依赖
        echo "CONFIG_PACKAGE_luci-lib-xray=y" >> .config
        echo "CONFIG_PACKAGE_luci-compat=y" >> .config
        
        # 常用工具（iStore 需要）
        echo "CONFIG_PACKAGE_bash=y" >> .config
        echo "CONFIG_PACKAGE_curl=y" >> .config
        echo "CONFIG_PACKAGE_wget-ssl=y" >> .config
        echo "CONFIG_PACKAGE_opkg=y" >> .config
        
        # 文件管理
        echo "CONFIG_PACKAGE_luci-app-filemanager=y" >> .config
        
        # Docker 支持（可选）
        echo "# CONFIG_PACKAGE_luci-app-dockerman=y" >> .config
        
        echo "✅ iStore 配置完成"
    else
        echo "ℹ️ 不包含 iStore"
        echo "# CONFIG_PACKAGE_luci-app-istorex is not set" >> .config
        echo "# CONFIG_PACKAGE_luci-app-store is not set" >> .config
    fi
}

# 应用编译模式配置
apply_build_mode() {
    echo "应用编译模式: $BUILD_MODE"
    
    case "$BUILD_MODE" in
        "full")
            echo "✅ 使用完整模式"
            echo "CONFIG_PACKAGE_bash=y" >> .config
            echo "CONFIG_PACKAGE_htop=y" >> .config
            echo "CONFIG_PACKAGE_nano=y" >> .config
            echo "CONFIG_PACKAGE_vim=y" >> .config
            echo "CONFIG_PACKAGE_curl=y" >> .config
            echo "CONFIG_PACKAGE_tmux=y" >> .config
            echo "CONFIG_PACKAGE_git=y" >> .config
            ;;
        "firmware"|"")
            echo "ℹ️ 使用固件模式（基础功能）"
            # 基础工具
            echo "CONFIG_PACKAGE_bash=y" >> .config
            echo "CONFIG_PACKAGE_curl=y" >> .config
            ;;
        *)
            echo "❌ 未知的编译模式: $BUILD_MODE"
            exit 1
            ;;
    esac
}

# 应用必需的内核模块
apply_kernel_modules() {
    echo "应用必需的内核模块..."
    
    # 网络核心模块
    echo "CONFIG_PACKAGE_kmod-ppp=y" >> .config
    echo "CONFIG_PACKAGE_kmod-pppoe=y" >> .config
    echo "CONFIG_PACKAGE_kmod-ipt-core=y" >> .config
    echo "CONFIG_PACKAGE_kmod-ipv6=y" >> .config
    
    # 文件系统
    echo "CONFIG_PACKAGE_kmod-fs-ext4=y" >> .config
    echo "CONFIG_PACKAGE_kmod-fs-squashfs=y" >> .config
    echo "CONFIG_PACKAGE_kmod-fs-vfat=y" >> .config
    echo "CONFIG_PACKAGE_kmod-fs-ntfs=y" >> .config
    
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
    echo "CONFIG_PACKAGE_kmod-nls-cp437=y" >> .config
    echo "CONFIG_PACKAGE_kmod-nls-iso8859-1=y" >> .config
}

# 应用配置并验证
apply_and_validate() {
    echo "应用配置..."
    
    # 应用基础配置
    apply_device_config
    
    # 应用 TurboACC 配置
    apply_turboacc_config
    
    # 应用 iStore 配置
    apply_istore_config
    
    # 应用编译模式
    apply_build_mode
    
    # 应用内核模块
    apply_kernel_modules
    
    # 使用 defconfig 而不是 menuconfig
    echo "运行 make defconfig..."
    make defconfig
    
    # 验证配置
    echo "=== 最终配置验证 ==="
    echo "检查关键配置项:"
    
    echo "TurboACC:"
    grep -E "CONFIG_PACKAGE_(luci-app-turboacc|kmod-nft-fullcone)" .config || echo "⚠️ TurboACC 配置可能缺失"
    
    echo "iStore:"
    if [ "$INCLUDE_ISTORE" = "true" ]; then
        grep -E "CONFIG_PACKAGE_luci-app-(istorex|store|quickstart)" .config || echo "⚠️ iStore 配置可能缺失"
    fi
    
    echo "网络模块:"
    grep -E "CONFIG_PACKAGE_(firewall4|nftables-json)" .config || echo "⚠️ 网络配置可能缺失"
    
    echo "✅ 配置应用完成"
}

# 主执行函数
main() {
    if [ -z "$TARGET_DEVICE" ]; then
        echo "❌ 缺少目标设备参数"
        exit 1
    fi
    
    # 设置默认值
    INCLUDE_SFE=${INCLUDE_SFE:-"true"}
    INCLUDE_ISTORE=${INCLUDE_ISTORE:-"true"}
    BUILD_MODE=${BUILD_MODE:-"firmware"}
    
    apply_and_validate
}

# 执行主函数
main "$@"
