# 在脚本中添加以下函数：

add_complete_shortcut_fe() {
    log_info "添加完整的 Shortcut FE 组件支持..."
    
    # 调用专门的脚本
    if [ -f "scripts/add-shortcut-fe.sh" ]; then
        ./scripts/add-shortcut-fe.sh
    else
        log_warn "add-shortcut-fe.sh 不存在，使用备用方法"
        # 备用方法：直接使用 add_turboacc.sh 的 SFE 功能
    fi
    
    # 确保配置正确
    if [ -f "target/linux/generic/config-6.1" ]; then
        if ! grep -q "CONFIG_SHORTCUT_FE" "target/linux/generic/config-6.1"; then
            echo "# CONFIG_SHORTCUT_FE is not set" >> "target/linux/generic/config-6.1"
        fi
        if ! grep -q "CONFIG_FAST_CLASSIFIER" "target/linux/generic/config-6.1"; then
            echo "# CONFIG_FAST_CLASSIFIER is not set" >> "target/linux/generic/config-6.1"
        fi
    fi
}

# 在主函数中修改 TurboACC 集成部分：
main() {
    local include_sfe=false
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --with-sfe)
                include_sfe=true
                shift
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
    
    # 使用官方的 add_turboacc.sh 脚本
    log_info "使用官方 TurboACC 安装脚本..."
    curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o /tmp/add_turboacc.sh
    
    if [ "$include_sfe" = "true" ]; then
        log_info "安装 TurboACC (包含完整 SFE)..."
        bash /tmp/add_turboacc.sh
        # 额外添加完整的 Shortcut FE 组件
        add_complete_shortcut_fe
    else
        log_info "安装 TurboACC (不包含 SFE)..."
        bash /tmp/add_turboacc.sh --no-sfe
    fi
    
    # 清理临时文件
    rm -f /tmp/add_turboacc.sh
    
    log_info "=== 功能集成完成 ==="
    log_info "接下来请执行:"
    log_info "1. make menuconfig"
    log_info "2. 在 LuCI -> Applications 中选中 luci-app-turboacc"
    if [ "$include_sfe" = "true" ]; then
        log_info "3. 在 Kernel modules -> Network Support 中选中 kmod-shortcut-fe 和 kmod-fast-classifier"
    fi
    log_info "4. make -j\$(nproc) V=s"
}
