#!/bin/bash

echo "=== 详细检查 Shortcut FE 状态 ==="

# 检查可能的路径
PATHS=(
    "package/qca/shortcut-fe"
    "package/network/shortcut-fe" 
    "package/shortcut-fe"
    "feeds/packages/net/shortcut-fe"
    "feeds/luci/applications/luci-app-turboacc"
)

found=0

for path in "${PATHS[@]}"; do
    if [ -d "$path" ]; then
        echo "✅ 找到: $path"
        found=1
        
        # 显示目录内容
        echo "目录内容:"
        ls -la "$path/" 2>/dev/null || echo "   (空目录)"
        
        # 检查子组件
        if [ -d "$path/fast-classifier" ]; then
            echo "  📁 fast-classifier:"
            ls -la "$path/fast-classifier/" 2>/dev/null | head -10
        fi
        
        if [ -d "$path/shortcut-fe" ]; then
            echo "  📁 shortcut-fe:"
            ls -la "$path/shortcut-fe/" 2>/dev/null | head -10
        fi
        
        if [ -d "$path/simulated-driver" ]; then
            echo "  📁 simulated-driver:"
            ls -la "$path/simulated-driver/" 2>/dev/null | head -10
        fi
        echo ""
    fi
done

if [ $found -eq 0 ]; then
    echo "❌ 在所有路径中都未找到 shortcut-fe"
    echo ""
    echo "当前 package 目录结构:"
    find package -maxdepth 2 -type d -name "*shortcut*" -o -name "*sfe*" -o -name "*turboacc*" 2>/dev/null || echo "   (未找到相关目录)"
    echo ""
    echo "当前 feeds 目录结构:"
    find feeds -maxdepth 3 -type d -name "*shortcut*" -o -name "*sfe*" -o -name "*turboacc*" 2>/dev/null | head -10
fi

# 检查 TurboACC 相关包
echo ""
echo "=== 检查 TurboACC 相关包 ==="
turboacc_paths=(
    "package/turboacc"
    "feeds/luci/applications/luci-app-turboacc"
    "package/lean/luci-app-turboacc"
)

for path in "${turboacc_paths[@]}"; do
    if [ -d "$path" ]; then
        echo "✅ 找到: $path"
        if [ -f "$path/Makefile" ]; then
            echo "  Makefile 依赖信息:"
            grep -E "DEPENDS.*=.*shortcut\|DEPENDS.*=.*sfe\|DEPENDS.*=.*fast-classifier" "$path/Makefile" || echo "   (未找到相关依赖)"
        fi
    fi
done

echo ""
echo "=== 检查完成 ==="
