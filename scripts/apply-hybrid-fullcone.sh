#!/bin/bash
# 混合 Fullcone NAT 方案
# 结合 iStoreOS 的 BCM 内核优化和 ImmortalWrt 的用户空间兼容性

set -e

echo "=== 应用混合 Fullcone NAT 方案 ==="

# 参数
TURBOACC_METHOD=$1
INCLUDE_SFE=$2

echo "参数: TURBOACC_METHOD=$TURBOACC_METHOD, INCLUDE_SFE=$INCLUDE_SFE"

apply_hybrid_solution() {
    echo "应用混合 Fullcone NAT 方案..."
    
    # 1. 使用 ImmortalWrt 的 nftables 1.1.5 用户空间
    echo "✅ 使用 ImmortalWrt nftables 1.1.5 用户空间"
    
    # 2. 有条件地应用 iStoreOS 的 BCM 内核优化
    apply_bcm_kernel_optimizations
    
    # 3. 应用标准 Fullcone 配置
    apply_standard_fullcone_config
}

apply_bcm_kernel_optimizations() {
    echo "应用 iStoreOS BCM 内核优化..."
    
    # 下载 BCM Fullcone 内核补丁
    local retries=3
    local timeout=30
    
    mkdir -p target/linux/generic/hack-6.12
    
    for i in $(seq 1 $retries); do
        echo "下载 BCM Fullcone 内核补丁尝试 $i..."
        if curl -f --connect-timeout $timeout -sSL \
            "https://raw.githubusercontent.com/istoreos/istoreos/istoreos-24.10/target/linux/generic/hack-6.6/982-add-bcm-fullconenat-support.patch" \
            -o "target/linux/generic/hack-6.12/982-add-bcm-fullconenat-support.patch"; then
            echo "✅ BCM Fullcone 内核补丁下载成功"
            
            # 应用 nftables BCM 补丁
            curl -f --connect-timeout $timeout -sSL \
                "https://raw.githubusercontent.com/istoreos/istoreos/istoreos-24.10/target/linux/generic/hack-6.6/983-add-bcm-fullconenat-to-nft.patch" \
                -o "target/linux/generic/hack-6.12/983-add-bcm-fullconenat-to-nft.patch" && \
            echo "✅ nftables BCM 补丁下载成功"
            return 0
        else
            echo "❌ 下载失败 $i"
            sleep 2
        fi
    done
    
    echo "⚠️ 跳过 BCM 内核优化，使用标准 Fullcone"
}

apply_standard_fullcone_config() {
    echo "应用标准 Fullcone 配置..."
    
    # 基础配置
    echo "CONFIG_ALL_KMODS=y" >> .config
    echo "CONFIG_USE_APK=y" >> .config
    
    # Fullcone NAT 支持
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
    
    echo "✅ 标准 Fullcone 配置完成"
}

# 主执行函数
main() {
    case "$TURBOACC_METHOD" in
        "hybrid")
            apply_hybrid_solution
            ;;
        "immortalwrt")
            apply_standard_fullcone_config
            ;;
        "script")
            echo "使用脚本方案，跳过混合方案"
            ;;
        *)
            echo "❌ 未知的 TurboACC 方案: $TURBOACC_METHOD"
            exit 1
            ;;
    esac
    
    echo "=== Fullcone NAT 方案应用完成 ==="
}

# 执行主函数
main "$@"
