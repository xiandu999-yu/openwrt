#!/bin/bash

echo "=== 检查已集成的功能 ==="

# 检查TurboACC
if [ -d "package/lean/luci-app-turboacc" ] || [ -d "package/luci-app-turboacc" ]; then
    echo "✅ TurboACC 已安装"
else
    echo "❌ TurboACC 未安装"
fi

# 检查Fullcone补丁
if [ -d "patches/fullcone" ]; then
    echo "✅ Fullcone NAT补丁 已下载"
    count=$(find patches/fullcone -name "*.patch" | wc -l)
    echo "   找到 $count 个补丁文件"
else
    echo "❌ Fullcone NAT补丁 未下载"
fi

# 检查Shortcut FE
if [ -d "package/network/shortcut-fe" ]; then
    echo "✅ Shortcut FE 已安装"
else
    echo "⚠️  Shortcut FE 未安装 (可选)"
fi

# 检查内核补丁
if [ -f "target/linux/generic/hack-6.6/982-add-bcm-fullconenat-support.patch" ]; then
    echo "✅ 内核Fullcone支持补丁 已应用"
else
    echo "❌ 内核Fullcone支持补丁 未应用"
fi

echo "=== 检查完成 ==="
