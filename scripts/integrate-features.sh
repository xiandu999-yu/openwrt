#!/bin/bash

set -e

echo "=== 开始集成TurboACC和Fullcone NAT功能 ==="

# 创建必要的目录
mkdir -p patches/fullcone
mkdir -p packages/network

# 工作目录
WORK_DIR=$(pwd)
PATCH_DIR="$WORK_DIR/patches/fullcone"
PKG_DIR="$WORK_DIR/packages"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检测是否在OpenWrt源码目录
check_environment() {
    if [ ! -f "rules.mk" ] && [ ! -d "package" ]; then
        log_error "请在OpenWrt源码根目录运行此脚本"
        exit 1
    fi
    log_info "环境检查通过"
}

# 下载并应用TurboACC
install_turboacc() {
    local include_sfe=$1
    
    log_info "下载TurboACC安装脚本..."
    curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o /tmp/add_turboacc.sh
    
    if [ "$include_sfe" = "true" ]; then
        log_info "安装TurboACC (包含SFE)..."
        bash /tmp/add_turboacc.sh
    else
        log_info "安装TurboACC (不包含SFE)..."
        bash /tmp/add_turboacc.sh --no-sfe
    fi
    
    # 清理临时文件
    rm -f /tmp/add_turboacc.sh
}

# 下载iStoreOS的Fullcone NAT补丁
download_istoreos_patches() {
    log_info "下载iStoreOS Fullcone NAT补丁..."
    
    # 创建补丁目录结构
    mkdir -p $PATCH_DIR/libnftnl
    mkdir -p $PATCH_DIR/nftables
    mkdir -p $PATCH_DIR/firewall4
    mkdir -p $PATCH_DIR/firewall
    mkdir -p $PATCH_DIR/iptables
    mkdir -p $PATCH_DIR/kernel
    
    # 下载各个补丁文件
    local base_url="https://raw.githubusercontent.com/istoreos/istoreos/istoreos-24.10"
    
    # libnftnl补丁
    curl -sSL "$base_url/package/libs/libnftnl/patches/999-11-masq-fullcone-expr.patch" \
        -o "$PATCH_DIR/libnftnl/999-11-masq-fullcone-expr.patch"
    
    # nftables补丁
    curl -sSL "$base_url/package/network/utils/nftables/patches/999-11-masq-fullcone-flag.patch" \
        -o "$PATCH_DIR/nftables/999-11-masq-fullcone-flag.patch"
    
    # firewall4补丁
    curl -sSL "$base_url/package/network/config/firewall4/patches/999-03-fw4-masq-fullcone.patch" \
        -o "$PATCH_DIR/firewall4/999-03-fw4-masq-fullcone.patch"
    
    # 传统firewall补丁
    curl -sSL "$base_url/package/network/config/firewall/patches/100-fullconenat.patch" \
        -o "$PATCH_DIR/firewall/100-fullconenat.patch"
    curl -sSL "$base_url/package/network/config/firewall/patches/101-bcm-fullconenat.patch" \
        -o "$PATCH_DIR/firewall/101-bcm-fullconenat.patch"
    
    # iptables补丁
    curl -sSL "$base_url/package/network/utils/iptables/patches/900-bcm-fullconenat.patch" \
        -o "$PATCH_DIR/iptables/900-bcm-fullconenat.patch"
    
    # 内核补丁
    curl -sSL "$base_url/target/linux/generic/hack-6.6/982-add-bcm-fullconenat-support.patch" \
        -o "$PATCH_DIR/kernel/982-add-bcm-fullconenat-support.patch"
    curl -sSL "$base_url/target/linux/generic/hack-6.6/983-add-bcm-fullconenat-to-nft.patch" \
        -o "$PATCH_DIR/kernel/983-add-bcm-fullconenat-to-nft.patch"
    
    # UCI默认配置
    curl -sSL "$base_url/package/istoreos-files/files/etc/uci-defaults/99_fullcone_nat_fw4" \
        -o "$PATCH_DIR/99_fullcone_nat_fw4"
    
    log_info "iStoreOS补丁下载完成"
}

# 应用补丁
apply_patches() {
    log_info "开始应用补丁..."
    
    # 应用内核补丁
    if [ -d "target/linux/generic/hack-6.6" ]; then
        cp $PATCH_DIR/kernel/*.patch target/linux/generic/hack-6.6/
        log_info "内核补丁已复制"
    fi
    
    # 应用libnftnl补丁
    if [ -d "package/libs/libnftnl/patches" ]; then
        cp $PATCH_DIR/libnftnl/*.patch package/libs/libnftnl/patches/
        log_info "libnftnl补丁已复制"
    fi
    
    # 应用nftables补丁
    if [ -d "package/network/utils/nftables/patches" ]; then
        cp $PATCH_DIR/nftables/*.patch package/network/utils/nftables/patches/
        log_info "nftables补丁已复制"
    fi
    
    # 应用firewall4补丁
    if [ -d "package/network/config/firewall4/patches" ]; then
        cp $PATCH_DIR/firewall4/*.patch package/network/config/firewall4/patches/
        log_info "firewall4补丁已复制"
    fi
    
    # 应用传统firewall补丁（如果需要）
    if [ -d "package/network/config/firewall/patches" ]; then
        cp $PATCH_DIR/firewall/*.patch package/network/config/firewall/patches/
        log_info "传统firewall补丁已复制"
    fi
    
    # 应用iptables补丁
    if [ -d "package/network/utils/iptables/patches" ]; then
        cp $PATCH_DIR/iptables/*.patch package/network/utils/iptables/patches/
        log_info "iptables补丁已复制"
    fi
    
    # 复制UCI默认配置
    if [ -d "package/base-files/files/etc/uci-defaults" ]; then
        cp $PATCH_DIR/99_fullcone_nat_fw4 package/base-files/files/etc/uci-defaults/
        chmod +x package/base-files/files/etc/uci-defaults/99_fullcone_nat_fw4
        log_info "UCI默认配置已复制"
    fi
}

# 添加Shortcut FE包（从coolsnowwolf/lede）
add_shortcut_fe() {
    log_info "添加Shortcut FE包..."
    
    local shortcut_fe_dir="package/network/shortcut-fe"
    
    if [ ! -d "$shortcut_fe_dir" ]; then
        mkdir -p $shortcut_fe_dir
        
        # 下载Makefile
        curl -sSL "https://raw.githubusercontent.com/coolsnowwolf/lede/master/package/qca/shortcut-fe/shortcut-fe/Makefile" \
            -o "$shortcut_fe_dir/Makefile"
        
        # 下载源码文件
        mkdir -p "$shortcut_fe_dir/src"
        curl -sSL "https://raw.githubusercontent.com/coolsnowwolf/lede/master/package/qca/shortcut-fe/shortcut-fe/src/sfe_ecm.c" \
            -o "$shortcut_fe_dir/src/sfe_ecm.c"
        curl -sSL "https://raw.githubusercontent.com/coolsnowwolf/lede/master/package/qca/shortcut-fe/shortcut-fe/src/sfe_ipv4.c" \
            -o "$shortcut_fe_dir/src/sfe_ipv4.c"
        curl -sSL "https://raw.githubusercontent.com/coolsnowwolf/lede/master/package/qca/shortcut-fe/shortcut-fe/src/sfe_ipv6.c" \
            -o "$shortcut_fe_dir/src/sfe_ipv6.c"
        
        log_info "Shortcut FE包已添加"
    else
        log_warn "Shortcut FE包已存在，跳过"
    fi
}

# 创建应用脚本
create_apply_script() {
    log_info "创建应用脚本..."
    
    cat > scripts/apply-fullcone-patches.sh << 'EOF'
#!/bin/bash

# 应用所有补丁
echo "应用Fullcone NAT补丁..."

# 应用内核补丁
for patch in patches/fullcone/kernel/*.patch; do
    if [ -f "$patch" ]; then
        echo "应用内核补丁: $(basename $patch)"
        patch -p1 --forward < "$patch" || true
    fi
done

# 应用libnftnl补丁
for patch in patches/fullcone/libnftnl/*.patch; do
    if [ -f "$patch" ]; then
        echo "应用libnftnl补丁: $(basename $patch)"
        patch -p1 --forward < "$patch" || true
    fi
done

# 应用nftables补丁
for patch in patches/fullcone/nftables/*.patch; do
    if [ -f "$patch" ]; then
        echo "应用nftables补丁: $(basename $patch)"
        patch -p1 --forward < "$patch" || true
    fi
done

echo "Fullcone NAT补丁应用完成"
EOF

    chmod +x scripts/apply-fullcone-patches.sh
}

# 主函数
main() {
    local include_sfe=false
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --with-sfe)
                include_sfe=true
                shift
                ;;
            --help)
                echo "用法: $0 [选项]"
                echo "选项:"
                echo "  --with-sfe    包含Shortcut FE加速"
                echo "  --help        显示此帮助信息"
                exit 0
                ;;
            *)
                log_error "未知选项: $1"
                exit 1
                ;;
        esac
    done
    
    log_info "开始集成网络加速功能..."
    
    # 执行各个步骤
    check_environment
    download_istoreos_patches
    install_turboacc $include_sfe
    
    if [ "$include_sfe" = "true" ]; then
        add_shortcut_fe
    fi
    
    apply_patches
    create_apply_script
    
    log_info "=== 功能集成完成 ==="
    log_info "接下来请执行:"
    log_info "1. make menuconfig"
    log_info "2. 在 LuCI -> Applications 中选中 luci-app-turboacc"
    if [ "$include_sfe" = "true" ]; then
        log_info "3. 在 Kernel modules -> Network Support 中选中 kmod-shortcut-fe"
    fi
    log_info "4. make -j\$(nproc) V=s"
}

# 运行主函数
main "$@"
