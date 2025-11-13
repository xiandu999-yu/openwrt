#!/bin/bash
# 基础配置创建脚本 - 完全非交互式
# 解决 GitHub Actions 无终端环境问题

set -e

echo "=== 创建基础配置（非交互式）==="

# 参数
TARGET_DEVICE=$1

echo "目标设备: $TARGET_DEVICE"

create_base_config() {
    echo "创建基础 OpenWrt 配置..."
    
    # 删除可能存在的旧配置
    rm -f .config
    
    # 方法1: 使用设备特定配置
    if [ -f "configs/$TARGET_DEVICE.config" ]; then
        echo "使用预定义的设备配置: $TARGET_DEVICE"
        cp "configs/$TARGET_DEVICE.config" .config
        return 0
    fi
    
    # 方法2: 使用 defconfig 创建基础配置
    echo "使用 defconfig 创建基础配置..."
    if make defconfig 2>&1 | grep -q "Error"; then
        echo "❌ defconfig 失败，尝试手动创建配置"
        create_manual_config
    else
        echo "✅ defconfig 成功"
    fi
}

create_manual_config() {
    echo "手动创建基础配置..."
    
    # 创建最基础的 .config 文件
    cat > .config << 'EOF'
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_Generic=y
EOF

    # 如果是指定设备，设置对应的目标
    case "$TARGET_DEVICE" in
        "nanopi-r3s")
            cat >> .config << 'EOF'
CONFIG_TARGET_rockchip=y
CONFIG_TARGET_rockchip_armv8=y
CONFIG_TARGET_rockchip_armv8_DEVICE_friendlyarm_nanopi-r2s=y
CONFIG_TARGET_rockchip_armv8_DEVICE_friendlyarm_nanopi-r4s=y
EOF
            ;;
        "nanopi-r6s")
            cat >> .config << 'EOF'
CONFIG_TARGET_rockchip=y
CONFIG_TARGET_rockchip_armv8=y
CONFIG_TARGET_rockchip_armv8_DEVICE_friendlyarm_nanopi-r6s=y
EOF
            ;;
    esac
    
    # 添加基础包
    cat >> .config << 'EOF'
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-ssl-openssl=y
CONFIG_PACKAGE_wpad-basic-wolfssl=y
CONFIG_BUSYBOX_CUSTOM=y
EOF
}

verify_config() {
    echo "验证配置文件..."
    
    if [ ! -f ".config" ]; then
        echo "❌ 配置文件创建失败"
        return 1
    fi
    
    echo "✅ 配置文件创建成功"
    echo "配置文件大小: $(wc -l < .config) 行"
    echo "前20行配置:"
    head -20 .config
    
    return 0
}

# 主执行函数
main() {
    if [ -z "$TARGET_DEVICE" ]; then
        echo "❌ 缺少目标设备参数"
        exit 1
    fi
    
    create_base_config
    verify_config
    
    echo "=== 基础配置创建完成 ==="
}

main "$@"
