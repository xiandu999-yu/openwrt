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

echo "参数: TARGET_DEVICE=$TARGET_DEVICE, TURBOACC_METHOD=$TURBOACC_METHOD, INCLUDE_SFE=$INCLUDE_SFE"

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

# 应用配置并验证
apply_and_validate() {
    echo "应用配置..."
    
    # 应用基础配置
    apply_device_config
    
    # 应用 TurboACC 配置
    apply_turboacc_config
    
    # 应用内核模块
    apply_kernel_modules
    
    # 使用 defconfig 而不是 menuconfig
    echo "运行 make defconfig..."
    make defconfig
    
    # 验证配置
    echo "=== 最终配置验证 ==="
    echo "检查关键配置项:"
    grep -E "CONFIG_PACKAGE_(firewall4|nftables-json|kmod-nft-fullcone)" .config || echo "⚠️ 某些配置可能缺失"
    
    echo "✅ 配置应用完成"
}

# 主执行函数
main() {
    if [ -z "$TARGET_DEVICE" ]; then
        echo "❌ 缺少目标设备参数"
        exit 1
    fi
    
    apply_and_validate
}

# 执行主函数
main "$@"
