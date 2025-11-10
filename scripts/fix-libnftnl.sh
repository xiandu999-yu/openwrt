#!/bin/bash

echo "=== 修复 libnftnl 编译问题 ==="

# 检查是否有 libnftnl 补丁冲突
if [ -f "package/libs/libnftnl/patches/999-11-masq-fullcone-expr.patch" ]; then
    echo "检测到 libnftnl Fullcone 补丁，检查兼容性..."
    
    # 备份原始补丁
    cp package/libs/libnftnl/patches/999-11-masq-fullcone-expr.patch \
       package/libs/libnftnl/patches/999-11-masq-fullcone-expr.patch.backup
    
    # 简化补丁或使用兼容版本
    echo "尝试使用兼容的 Fullcone 补丁..."
    curl -sSL https://raw.githubusercontent.com/istoreos/istoreos/istoreos-24.10/package/libs/libnftnl/patches/999-11-masq-fullcone-expr.patch \
        -o package/libs/libnftnl/patches/999-11-masq-fullcone-expr.patch
fi

echo "✅ libnftnl 修复完成"
