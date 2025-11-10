#!/bin/bash

echo "=== 专门检查 Shortcut FE 状态 ==="

# 检查所有可能的路径
PATHS=(
    "package/qca/shortcut-fe"
    "package/network/shortcut-fe" 
    "package/shortcut-fe"
    "feeds/packages/shortcut-fe"
    "feeds/luci/shortcut-fe"
)

found=0

for path in "${PATHS[@]}"; do
    if [ -d "$path" ]; then
        echo "✅ 找到 shortcut-fe 在: $path"
        found=1
        
        echo "详细文件结构:"
        find "$path" -type f -name "*.mk" -o -name "Makefile" -o -name "*.c" -o -name "*.h" 2>/dev/null | sort | head -20
        
        # 检查子组件
        echo "检查子组件:"
        for comp in fast-classifier shortcut-fe simulated-driver; do
            if [ -d "$path/$comp" ]; then
                echo "  ✅ $comp 目录存在"
                if [ -f "$path/$comp/Makefile" ]; then
                    echo "    ✅ Makefile 存在"
                    # 显示包名信息
                    grep -E "PKG_NAME|KernelPackage" "$path/$comp/Makefile" | head -2 | sed 's/^/      /'
                else
                    echo "    ❌ Makefile 不存在"
                fi
            else
                echo "  ❌ $comp 目录不存在"
            fi
        done
        break
    fi
done

if [ $found -eq 0 ]; then
    echo "❌ 在所有路径中都未找到 shortcut-fe"
    echo "搜索过的路径:"
    printf "  - %s\n" "${PATHS[@]}"
    
    # 检查是否有任何包含 shortcut 的文件
    echo "搜索包含 'shortcut' 的文件:"
    find package feeds -type f -name "*shortcut*" 2>/dev/null | head -10
fi

echo "=== Shortcut FE 检查完成 ==="
