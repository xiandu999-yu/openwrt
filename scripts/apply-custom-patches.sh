#!/bin/bash

set -e

echo "Applying custom patches and features..."

# 修改默认IP地址
sed -i 's/192.168.1.1/192.168.20.1/g' package/base-files/files/bin/config_generate

# 检查并安装Python依赖
echo "检查Python依赖..."
python3 -c "import elftools" 2>/dev/null || {
    echo "安装Python elftools..."
    pip3 install pyelftools
}

# 集成TurboACC和Fullcone NAT
echo "集成TurboACC和Fullcone NAT..."
if [ -f "scripts/integrate-features.sh" ]; then
    chmod +x scripts/integrate-features.sh
    # 根据参数决定是否包含SFE
    if [ "$1" = "--with-sfe" ]; then
        ./scripts/integrate-features.sh --with-sfe
    else
        ./scripts/integrate-features.sh
    fi
else
    echo "⚠️ integrate-features.sh 不存在，跳过TurboACC集成"
fi

echo "Custom patches applied successfully"
