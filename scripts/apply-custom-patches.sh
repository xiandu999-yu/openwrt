#!/bin/bash

echo "Applying custom patches..."

# 修改默认IP地址
sed -i 's/192.168.1.1/192.168.20.1/g' package/base-files/files/bin/config_generate

# 添加TurboACC (Fullcone NAT)
echo "Adding TurboACC..."
curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh
bash add_troboacc.sh --no-sfe

# 应用Fullcone NAT补丁
if [ -d "patches" ]; then
    for patch in patches/*.patch; do
        echo "Applying patch: $patch"
        patch -p1 < "$patch"
    done
fi
