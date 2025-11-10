#!/bin/bash

set -e

echo "=== 应用自定义修改 ==="

# 修改默认IP地址
sed -i 's/192.168.1.1/192.168.20.1/g' package/base-files/files/bin/config_generate

# 安装Python依赖
python3 -c "import elftools" 2>/dev/null || pip3 install pyelftools

# 修复依赖关系警告
echo "修复依赖关系..."
if [ -f "scripts/fix-dependencies.sh" ]; then
    chmod +x scripts/fix-dependencies.sh
    ./scripts/fix-dependencies.sh
fi

# 集成TurboACC
if [ -f "scripts/integrate-features.sh" ]; then
    chmod +x scripts/integrate-features.sh
    if [ "$1" = "--with-sfe" ]; then
        echo "集成TurboACC (含SFE)..."
        ./scripts/integrate-features.sh --with-sfe
    else
        echo "集成TurboACC (仅Fullcone)..."
        ./scripts/integrate-features.sh
    fi
fi

# 添加软件包
if [ -f "scripts/add-packages.sh" ]; then
    ./scripts/add-packages.sh
fi

echo "✅ 自定义修改应用完成"
