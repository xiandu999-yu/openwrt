#!/bin/bash

echo "=== 检查构建前提条件 ==="

# 检查系统依赖
echo "1. 检查系统工具..."
for cmd in gcc g++ make git python3 pip3; do
    if command -v $cmd &> /dev/null; then
        echo "✅ $cmd: $(which $cmd)"
    else
        echo "❌ $cmd: 未找到"
    fi
done

# 检查Python模块
echo "2. 检查Python模块..."
python3 -c "import elftools; print('✅ elftools:', elftools.__version__)" 2>/dev/null || echo "❌ elftools: 未安装"
python3 -c "import cffi; print('✅ cffi: 已安装')" 2>/dev/null || echo "❌ cffi: 未安装"
python3 -c "import Crypto; print('✅ pycrypto: 已安装')" 2>/dev/null || echo "❌ pycrypto: 未安装"
python3 -c "import scapy; print('✅ scapy: 已安装')" 2>/dev/null || echo "❌ scapy: 未安装"

# 检查OpenWrt前提条件
echo "3. 检查OpenWrt前提条件..."
if [ -f "include/prereq.mk" ]; then
    echo "✅ OpenWrt源码完整"
else
    echo "❌ OpenWrt源码不完整"
fi

# 运行OpenWrt的prereq检查
echo "4. 运行OpenWrt前提条件检查..."
make prereq 2>&1 | grep -E "(error|warning|missing)" || echo "✅ 前提条件检查通过"

echo "=== 检查完成 ==="
