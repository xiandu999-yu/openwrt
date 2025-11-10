#!/bin/bash

echo "=== 添加 Shortcut FE 支持 ==="

# 创建 shortcut-fe 包目录
mkdir -p package/network/shortcut-fe

# 下载 Makefile
echo "下载 Shortcut FE Makefile..."
curl -sSL https://raw.githubusercontent.com/coolsnowwolf/lede/master/package/qca/shortcut-fe/Makefile \
     -o package/network/shortcut-fe/Makefile

# 下载源码文件
mkdir -p package/network/shortcut-fe/src
echo "下载 Shortcut FE 源码..."
curl -sSL https://raw.githubusercontent.com/coolsnowwolf/lede/master/package/qca/shortcut-fe/shortcut-fe/src/sfe_ecm.c \
     -o package/network/shortcut-fe/src/sfe_ecm.c
curl -sSL https://raw.githubusercontent.com/coolsnowwolf/lede/master/package/qca/shortcut-fe/shortcut-fe/src/sfe_ipv4.c \
     -o package/network/shortcut-fe/src/sfe_ipv4.c
curl -sSL https://raw.githubusercontent.com/coolsnowwolf/lede/master/package/qca/shortcut-fe/shortcut-fe/src/sfe_ipv6.c \
     -o package/network/shortcut-fe/src/sfe_ipv6.c

# 下载内核补丁
echo "下载 Shortcut FE 内核补丁..."
mkdir -p target/linux/generic/hack-6.1
curl -sSL https://raw.githubusercontent.com/coolsnowwolf/lede/master/target/linux/generic/hack-6.1/953-net-patch-linux-kernel-to-support-shortcut-fe.patch \
     -o target/linux/generic/hack-6.1/953-net-patch-linux-kernel-to-support-shortcut-fe.patch

echo "✅ Shortcut FE 支持添加完成"
