#!/bin/bash
# 配置应用脚本 - 支持所有方案的 luci-app-turboacc

set -e

echo "=== 应用配置（支持所有方案）==="

# 参数
TARGET_DEVICE=$1
TURBOACC_METHOD=$2
INCLUDE_SFE=$3
INCLUDE_ISTORE=$4
BUILD_MODE=$5
ENABLE_TURBOACC_UI=$6  # 新增：是否启用 Web 界面

echo "参数: TARGET_DEVICE=$TARGET_DEVICE, TURBOACC_METHOD=$TURBOACC_METHOD"
echo "参数: INCLUDE_SFE=$INCLUDE_SFE, INCLUDE_ISTORE=$INCLUDE_ISTORE"
echo "参数: BUILD_MODE=$BUILD_MODE, ENABLE_TURBOACC_UI=$ENABLE_TURBOACC_UI"

# 应用 TurboACC 配置
apply_turboacc_config() {
    echo "应用 TurboACC 配置: $TURBOACC_METHOD"
    
    # 所有方案都可以启用 Web 界面
    if [ "$ENABLE_TURBOACC_UI" = "true" ]; then
        echo "✅ 启用 luci-app-turboacc Web 界面"
        echo "CONFIG_PACKAGE_luci-app-turboacc=y" >> .config
    fi
    
    case "$TURBOACC_METHOD" in
        "script")
            apply_script_turboacc
            ;;
        "immortalwrt"|"")
            apply_immortalwrt_turboacc
            ;;
        "hybrid")
            apply_hybrid_turboacc
            ;;
        *)
            echo "❌ 未知的 TurboACC 方案: $TURBOACC_METHOD"
            exit 1
            ;;
    esac
}

apply_script_turboacc() {
    echo "配置脚本方案 TurboACC..."
    # 脚本会自动处理，这里只做标记
    echo "# CONFIG_PACKAGE_kmod-nft-fullcone is not set" >> .config
}

apply_immortalwrt_turboacc() {
    echo "配置 ImmortalWrt Fullcone NAT 方案..."
    
    # Fullcone NAT
    echo "CONFIG_PACKAGE_kmod-nft-fullcone=y" >> .config
    echo "CONFIG_PACKAGE_iptables-mod-fullconenat=y" >> .config
    echo "CONFIG_PACKAGE_kmod-ipt-fullconenat=y" >> .config
    
    # 如果启用 Web 界面，确保相关模块也启用
    if [ "$ENABLE_TURBOACC_UI" = "true" ]; then
        echo "CONFIG_PACKAGE_kmod-nft-fullcone=y" >> .config
    fi
}

apply_hybrid_turboacc() {
    echo "配置混合 Fullcone NAT 方案..."
    
    # 使用标准 Fullcone 配置
    echo "CONFIG_PACKAGE_kmod-nft-fullcone=y" >> .config
    echo "CONFIG_PACKAGE_iptables-mod-fullconenat=y" >> .config
    echo "CONFIG_PACKAGE_kmod-ipt-fullconenat=y" >> .config
    
    # Web 界面支持
    if [ "$ENABLE_TURBOACC_UI" = "true" ]; then
        echo "CONFIG_PACKAGE_kmod-nft-fullcone=y" >> .config
    fi
}

# 其他函数保持不变...
