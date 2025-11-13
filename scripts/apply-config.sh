#!/bin/bash
# 配置应用脚本 - 修复版
# 完全避免交互式命令

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

apply_device_config() {
    echo "应用设备配置: $TARGET_DEVICE"
    
    case "$TARGET_DEVICE" in
        "nanopi-r3s")
            if [ -f "configs/nanopi-r3s.config" ]; then
                # 直接复制配置文件，不运行 menuconfig
                cp configs/nanopi-r3s.config .config
                echo "使用 NanoPi R3S 配置"
            else
                echo "❌ 找不到 NanoPi R3S 配置文件"
                # 创建基础配置
                make defconfig
            fi
            ;;
        "nanopi-r6s")
            if [ -f "configs/nanopi-r6s.config" ]; then
                cp configs/nanopi-r6s.config .config
                echo "使用 NanoPi R6S 配置"
            else
                echo "❌ 找不到 NanoPi R6S 配置文件"
                make defconfig
            fi
            ;;
        *)
            echo "❌ 未知设备: $TARGET_DEVICE"
            # 使用默认配置继续
            make defconfig
            ;;
    esac
}

# 其他函数保持不变...
# [保持之前的 apply_turboacc_config, apply_istore_config 等函数]

apply_and_validate() {
    echo "应用配置..."
    
    # 首先创建基础配置
    if [ ! -f ".config" ]; then
        echo "创建基础配置..."
        make defconfig
    fi
    
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
    
    # 使用 defconfig 验证配置（不交互）
    echo "运行 make defconfig 验证配置..."
    if ! make defconfig; then
        echo "❌ defconfig 失败，使用默认配置重试"
        rm -f .config
        make defconfig
    fi
    
    # 验证配置
    echo "=== 最终配置验证 ==="
    if [ -f ".config" ]; then
        echo "✅ 配置文件创建成功"
        echo "关键配置项:"
        grep -E "CONFIG_TARGET|CONFIG_PACKAGE" .config | head -20 || true
    else
        echo "❌ 配置文件创建失败"
        exit 1
    fi
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

main "$@"
