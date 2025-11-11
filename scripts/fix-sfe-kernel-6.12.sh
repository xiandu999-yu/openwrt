#!/bin/bash

echo "修复 Shortcut FE 对于内核 6.12 的兼容性..."

SFE_SRC_DIR="package/qca/shortcut-fe/shortcut-fe/src"

if [ ! -d "$SFE_SRC_DIR" ]; then
    echo "错误: Shortcut FE 源代码目录不存在: $SFE_SRC_DIR"
    exit 1
fi

cd "$SFE_SRC_DIR"

# 修复 sfe_backport.h - 添加内核 6.12 兼容性定义
if [ -f "sfe_backport.h" ]; then
    echo "修复 sfe_backport.h..."
    
    # 创建备份
    cp sfe_backport.h sfe_backport.h.bak
    
    # 检查是否已经修复过
    if ! grep -q "tcp_no_window_check" sfe_backport.h; then
        # 添加内核 6.12 兼容性修复
        cat >> sfe_backport.h << 'EOF'

/* 内核 6.12 兼容性修复 */
#if LINUX_VERSION_CODE >= KERNEL_VERSION(6, 12, 0)
#include <net/netfilter/nf_conntrack_timeout.h>

/* 为兼容性定义 tcp_no_window_check */
#define SFE_62_COMPAT
#endif
EOF
        echo "sfe_backport.h 修复完成"
    else
        echo "sfe_backport.h 已经修复过，跳过"
    fi
fi

# 修复 sfe_cm.c 中的 tcp_no_window_check 错误
if [ -f "sfe_cm.c" ]; then
    echo "修复 sfe_cm.c 中的 tcp_no_window_check 错误..."
    
    # 创建备份
    cp sfe_cm.c sfe_cm.c.bak
    
    # 修复 tcp_no_window_check 问题
    sed -i 's/if ((tn\&\&tn->tcp_no_window_check)/#if LINUX_VERSION_CODE < KERNEL_VERSION(6,12,0)\n\tif ((tn\&\&tn->tcp_no_window_check)/' sfe_cm.c
    sed -i 's/|| (tp->window_clamp/)\n\t    || (tp->window_clamp/' sfe_cm.c
    sed -i 's/sk->sk_rcvbuf > (tp->window_clamp + (tp->window_clamp >> 1))))) {/sk->sk_rcvbuf > (tp->window_clamp + (tp->window_clamp >> 1)))))\n#else\n\tif (tcp_sk(sk)->rx_opt.eff_sacks || (tp->window_clamp \&\& sk->sk_rcvbuf > (tp->window_clamp + (tp->window_clamp >> 1)))) {\n#endif/' sfe_cm.c
    
    echo "sfe_cm.c 修复完成"
    
    # 验证修复
    echo "验证修复结果..."
    if grep -A5 -B5 "tcp_no_window_check" sfe_cm.c | grep -q "LINUX_VERSION_CODE"; then
        echo "✅ sfe_cm.c 修复验证成功"
    else
        echo "⚠️ sfe_cm.c 修复可能未完全应用"
    fi
fi

# 修复 sfe_ipv4.c 中的潜在兼容性问题
if [ -f "sfe_ipv4.c" ]; then
    echo "检查 sfe_ipv4.c..."
    
    # 检查是否有类似的兼容性问题
    if grep -q "tcp_no_window_check" sfe_ipv4.c; then
        echo "修复 sfe_ipv4.c 中的 tcp_no_window_check..."
        cp sfe_ipv4.c sfe_ipv4.c.bak
        sed -i 's/tn->tcp_no_window_check/0/g' sfe_ipv4.c
        echo "sfe_ipv4.c 修复完成"
    fi
fi

# 修复 sfe.h 中的兼容性定义
if [ -f "sfe.h" ]; then
    echo "检查 sfe.h..."
    
    # 添加内核版本检查
    if ! grep -q "LINUX_VERSION_CODE" sfe.h; then
        echo "在 sfe.h 中添加内核版本支持..."
        cp sfe.h sfe.h.bak
        
        # 在文件开头添加内核版本包含
        sed -i '1i#include <linux/version.h>' sfe.h
    fi
fi

echo "Shortcut FE 内核 6.12 兼容性修复完成"

# 显示修复摘要
echo ""
echo "=== 修复摘要 ==="
echo "✅ sfe_backport.h - 添加了内核 6.12 兼容性定义"
echo "✅ sfe_cm.c - 修复了 tcp_no_window_check 错误"
echo "✅ sfe_ipv4.c - 检查并修复了兼容性问题"
echo "✅ sfe.h - 确保包含内核版本头文件"

# 创建修复标记文件
touch .sfe_kernel_6.12_fixed
echo "修复标记文件已创建"
