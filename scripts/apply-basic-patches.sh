#!/bin/bash

echo "Applying basic patches only..."

# 修改默认IP地址
sed -i 's/192.168.1.1/192.168.20.1/g' package/base-files/files/bin/config_generate

# 只应用必要的补丁，不集成TurboACC
echo "跳过TurboACC集成，仅应用基础补丁"

echo "Basic patches applied successfully"
