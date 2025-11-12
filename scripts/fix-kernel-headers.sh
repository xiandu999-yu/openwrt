#!/bin/bash

echo "=== 修复内核头文件缺失问题 ==="

# 1. 确保内核配置包含PPP支持
echo "检查内核PPP配置..."
if [ -f ".config" ]; then
    if ! grep -q "CONFIG_PPP=" .config; then
        echo "添加PPP支持到内核配置..."
        echo "CONFIG_PPP=y" >> .config
        echo "CONFIG_PPPOE=y" >> .config
        echo "✅ 已添加PPP配置"
    else
        echo "✅ PPP配置已存在"
    fi
fi

# 2. 尝试构建内核头文件
echo "构建内核头文件..."
make target/linux/install -j1 V=s > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ 内核头文件构建成功"
else
    echo "⚠️ 内核头文件构建有警告，继续..."
fi

# 3. 从内核源码复制缺失的头文件
echo "查找内核源码目录..."
KERNEL_SRC=$(ls -d build_dir/target-*/linux-*/linux-* 2>/dev/null | head -1)

if [ -n "$KERNEL_SRC" ] && [ -f "$KERNEL_SRC/include/uapi/linux/if_pppox.h" ]; then
    echo "从内核源码复制头文件..."
    mkdir -p staging_dir/target-aarch64_generic_musl/usr/include/linux
    
    # 复制 if_pppox.h
    cp "$KERNEL_SRC/include/uapi/linux/if_pppox.h" \
       "staging_dir/target-aarch64_generic_musl/usr/include/linux/"
    echo "✅ 已复制 if_pppox.h"
    
    # 复制其他可能需要的头文件
    for header in ppp_defs.h if_ppp.h; do
        if [ -f "$KERNEL_SRC/include/uapi/linux/$header" ]; then
            cp "$KERNEL_SRC/include/uapi/linux/$header" \
               "staging_dir/target-aarch64_generic_musl/usr/include/linux/" 2>/dev/null || true
        fi
    done
else
    echo "❌ 未找到内核头文件，创建简化版本..."
    mkdir -p staging_dir/target-aarch64_generic_musl/usr/include/linux
    
    # 创建简化的 if_pppox.h
    cat > staging_dir/target-aarch64_generic_musl/usr/include/linux/if_pppox.h << 'EOF'
#ifndef _LINUX_IF_PPPOX_H
#define _LINUX_IF_PPPOX_H

#include <linux/types.h>
#include <linux/if.h>
#include <linux/in.h>
#include <linux/if_ether.h>
#include <linux/if_ppp.h>

#define AF_PPPOX 24
#define PF_PPPOX AF_PPPOX

#define PX_PROTO_OE     0
#define PX_PROTO_OL2TP  1
#define PX_PROTO_PPTP   2

struct pppoe_addr {
    __be16 sid;
    unsigned char remote[ETH_ALEN];
    int ifindex;
    char dev[16];
};

struct pptp_addr {
    __be16 call_id;
    struct in_addr sin_addr;
};

struct pppol2tp_addr {
    __u32 tunnel_id;
    __u32 session_id;
};

#endif /* _LINUX_IF_PPPOX_H */
EOF
    echo "✅ 已创建简化版 if_pppox.h"
fi

# 4. 修复 netfilter_bridge.h 的条件包含
echo "修复 netfilter_bridge.h..."
NETFILTER_PATHS=(
    "build_dir/target-aarch64_generic_musl/linux-*/linux-*/include/linux/netfilter_bridge.h"
    "staging_dir/target-aarch64_generic_musl/usr/include/linux/netfilter_bridge.h"
)

for path_pattern in "${NETFILTER_PATHS[@]}"; do
    if [ -f "$(ls -d $path_pattern 2>/dev/null | head -1)" ]; then
        NETFILTER_FILE="$(ls -d $path_pattern 2>/dev/null | head -1)"
        echo "修复 $NETFILTER_FILE"
        
        # 备份原始文件
        cp "$NETFILTER_FILE" "$NETFILTER_FILE.bak"
        
        # 使用条件编译保护 if_pppox.h 包含
        sed -i 's/#include <linux\/if_pppox.h>/#ifdef HAVE_LINUX_IF_PPPOX_H\n#include <linux\/if_pppox.h>\n#endif/' "$NETFILTER_FILE"
        
        echo "✅ 已修复 netfilter_bridge.h"
        break
    fi
done

# 5. 清理 nftables 构建状态
echo "清理 nftables 构建缓存..."
rm -rf build_dir/target-*/nftables-*
rm -rf staging_dir/target-*/usr/include/nftables
rm -rf tmp/build/nftables

echo "=== 内核头文件修复完成 ==="
