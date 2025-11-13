#!/bin/bash
# 构建优化脚本
# 作者: AI Assistant
# 功能: 优化 OpenWrt 构建配置以节省空间

set -e

echo "=== 开始优化构建配置 ==="

# 应用空间优化配置
apply_space_optimization() {
    echo "应用空间优化配置..."
    
    # 禁用调试符号
    echo "CONFIG_DEBUG_INFO=n" >> .config
    echo "CONFIG_DEBUG_KERNEL=n" >> .config
    
    # 禁用不必要的驱动
    echo "CONFIG_PACKAGE_kmod-usb-serial=n" >> .config
    echo "CONFIG_PACKAGE_kmod-usb-serial-ftdi=n" >> .config
    echo "CONFIG_PACKAGE_kmod-usb-serial-pl2303=n" >> .config
    
    # 禁用不必要的语言包
    echo "CONFIG_PACKAGE_luci-i18n-base-zh-cn=n" >> .config
    echo "CONFIG_PACKAGE_luci-i18n-base-en=n" >> .config
    
    # 禁用文档
    echo "CONFIG_PACKAGE_doc=n" >> .config
    
    # 优化编译选项
    echo "CONFIG_STRIP_KERNEL_EXPORTS=y" >> .config
    echo "CONFIG_SMALL_FLASH=y" >> .config
    
    # 精简内核模块
    echo "CONFIG_PACKAGE_kmod-usb-core=y" >> .config
    echo "CONFIG_PACKAGE_kmod-usb2=y" >> .config
    echo "CONFIG_PACKAGE_kmod-usb3=y" >> .config
    echo "CONFIG_PACKAGE_kmod-usb-storage=y" >> .config
    
    # 禁用不必要的网络协议
    echo "CONFIG_PACKAGE_kmod-ipv6=y" >> .config  # 保留 IPv6
    echo "CONFIG_PACKAGE_kmod-ppp=y" >> .config
    
    echo "✅ 空间优化配置完成"
}

# 精简软件包选择
optimize_packages() {
    echo "精简软件包选择..."
    
    local build_mode=$1
    local include_istore=$2
    
    if [ "$build_mode" = "firmware" ]; then
        echo "使用精简模式..."
        # 禁用不必要的应用
        echo "CONFIG_PACKAGE_htop=n" >> .config
        echo "CONFIG_PACKAGE_nano=n" >> .config
        echo "CONFIG_PACKAGE_vim=n" >> .config
    fi
    
    if [ "$include_istore" != "true" ]; then
        echo "禁用 iStore 相关包..."
        echo "CONFIG_PACKAGE_luci-app-istorex=n" >> .config
        echo "CONFIG_PACKAGE_luci-app-store=n" >> .config
        echo "CONFIG_PACKAGE_luci-app-quickstart=n" >> .config
    fi
    
    echo "✅ 软件包精简完成"
}

# 主执行函数
main() {
    local build_mode=${1:-"firmware"}
    local include_istore=${2:-"true"}
    
    echo "参数: BUILD_MODE=$build_mode, INCLUDE_ISTORE=$include_istore"
    
    apply_space_optimization
    optimize_packages "$build_mode" "$include_istore"
    
    # 重新应用配置
    make defconfig
    
    echo "=== 构建优化完成 ==="
}

# 执行主函数
main "$@"
