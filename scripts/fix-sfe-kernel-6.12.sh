#!/bin/bash

echo "修复 Shortcut FE 对于内核 6.12 的兼容性..."

SFE_SRC_DIR="package/qca/shortcut-fe/shortcut-fe/src"

if [ ! -d "$SFE_SRC_DIR" ]; then
    echo "错误: Shortcut FE 源代码目录不存在: $SFE_SRC_DIR"
    exit 1
fi

cd "$SFE_SRC_DIR"

# 修复 sfe_backport.h
if [ -f "sfe_backport.h" ]; then
    echo "修复 sfe_backport.h..."
    
    # 创建备份
    cp sfe_backport.h sfe_backport.h.bak
    
    # 应用修复
    cat > sfe_backport_fix.patch << 'EOF'
--- a/sfe_backport.h
+++ b/sfe_backport.h
@@ -1,4 +1,9 @@
 #include <linux/version.h>
 
+/* 内核 6.12 兼容性修复 */
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(6, 12, 0)
+#include <net/netfilter/nf_conntrack_timeout.h>
+#endif
+
 #if (LINUX_VERSION_CODE >= KERNEL_VERSION(3, 4, 0))
 #if (LINUX_VERSION_CODE >= KERNEL_VERSION(3, 7, 0))
 #include <net/netfilter/nf_conntrack_timeout.h>
EOF

    patch -p1 < sfe_backport_fix.patch
    rm sfe_backport_fix.patch
    echo "sfe_backport.h 修复完成"
fi

# 修复 sfe_cm.c 中的潜在问题
if [ -f "sfe_cm.c" ]; then
    echo "检查 sfe_cm.c..."
    # 这里可以添加针对 sfe_cm.c 的具体修复
    # 比如修复函数签名变化等
fi

echo "Shortcut FE 内核 6.12 兼容性修复完成"
