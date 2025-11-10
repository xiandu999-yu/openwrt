# 在适当位置添加以下代码：

add_shortcut_fe_support() {
    log_info "添加完整的 Shortcut FE 支持..."
    
    # 调用专门的脚本
    if [ -f "scripts/add-shortcut-fe.sh" ]; then
        ./scripts/add-shortcut-fe.sh
    else
        # 备用方法
        mkdir -p package/network/shortcut-fe
        curl -sSL https://raw.githubusercontent.com/coolsnowwolf/lede/master/package/qca/shortcut-fe/Makefile \
            -o package/network/shortcut-fe/Makefile
    fi
}

# 在主函数中修改：
main() {
    # ... 其他代码 ...
    
    if [ "$include_sfe" = "true" ]; then
        add_shortcut_fe_support
    fi
    
    # ... 其他代码 ...
}
