#!/bin/bash

echo "Applying custom patches and features..."

# 修改默认IP地址
sed -i 's/192.168.1.1/192.168.20.1/g' package/base-files/files/bin/config_generate

# 集成TurboACC和Fullcone NAT（不带SFE）
echo "Integrating TurboACC and Fullcone NAT..."
chmod +x scripts/integrate-features.sh
./scripts/integrate-features.sh --with-sfe  # 如果需要SFE，使用这个
# ./scripts/integrate-features.sh           # 如果不需要SFE，使用这个

# 应用Fullcone补丁
if [ -f "scripts/apply-fullcone-patches.sh" ]; then
    ./scripts/apply-fullcone-patches.sh
fi

echo "Custom patches applied successfully"
