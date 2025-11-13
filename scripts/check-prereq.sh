#!/bin/bash
# 替代 make prereq - 非交互式依赖检查
# 解决 GitHub Actions 无终端环境问题

set -e

echo "=== 运行非交互式依赖检查 ==="

check_build_environment() {
    echo "检查编译环境..."
    
    # 检查基本工具
    local tools="make gcc g++ awk git curl python3"
    for tool in $tools; do
        if command -v $tool >/dev/null 2>&1; then
            echo "✅ $tool: $(which $tool)"
        else
            echo "❌ $tool: 未找到"
            return 1
        fi
    done
    
    # 检查库文件
    local libraries="libssl libncurses"
    for lib in $libraries; do
        if ldconfig -p | grep -q $lib; then
            echo "✅ 库 $lib: 已安装"
        else
            echo "⚠️ 库 $lib: 可能需要安装"
        fi
    done
    
    return 0
}

check_openwrt_structure() {
    echo "检查 OpenWrt 代码结构..."
    
    local required_dirs="package scripts include tools"
    for dir in $required_dirs; do
        if [ -d "$dir" ]; then
            echo "✅ 目录 $dir: 存在"
        else
            echo "❌ 目录 $dir: 缺失"
            return 1
        fi
    done
    
    local required_files="Makefile feeds.conf.default"
    for file in $required_files; do
        if [ -f "$file" ]; then
            echo "✅ 文件 $file: 存在"
        else
            echo "❌ 文件 $file: 缺失"
            return 1
        fi
    done
    
    return 0
}

setup_basic_config() {
    echo "设置基础配置..."
    
    # 如果还没有配置文件，创建一个最简配置
    if [ ! -f ".config" ]; then
        echo "创建最简 .config 文件..."
        cat > .config << 'EOF'
# 基础配置
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_Generic=y

# 基础包
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-ssl-openssl=y
CONFIG_PACKAGE_wpad-basic-wolfssl=y

# 工具链
CONFIG_TOOLCHAIN=y
CONFIG_TOOLCHAIN_LIBC_USE_MUSL=y
EOF
        echo "✅ 基础配置创建完成"
    else
        echo "✅ 配置文件已存在"
    fi
}

# 主执行函数
main() {
    echo "开始非交互式依赖检查..."
    
    if check_build_environment && check_openwrt_structure; then
        setup_basic_config
        echo "✅ 所有依赖检查通过"
        return 0
    else
        echo "❌ 依赖检查失败"
        return 1
    fi
}

# 执行主函数
main "$@"
