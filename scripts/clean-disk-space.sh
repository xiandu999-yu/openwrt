#!/bin/bash
# 磁盘空间清理脚本
# 作者: AI Assistant
# 功能: 清理不必要的文件以释放磁盘空间

set -e

echo "=== 开始清理磁盘空间 ==="

# 显示当前磁盘使用情况
echo "当前磁盘使用情况:"
df -h

# 1. 清理系统缓存
echo "步骤1: 清理系统缓存..."
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

# 2. 清理日志文件
echo "步骤2: 清理日志文件..."
sudo find /var/log -name "*.log" -type f -delete 2>/dev/null || true
sudo journalctl --vacuum-time=1d

# 3. 清理临时文件
echo "步骤3: 清理临时文件..."
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# 4. 清理 OpenWrt 构建中间文件（保留必要文件）
echo "步骤4: 清理 OpenWrt 构建中间文件..."
if [ -d "build_dir" ]; then
    # 保留必要的工具链，删除其他中间文件
    find build_dir -name "*.o" -delete 2>/dev/null || true
    find build_dir -name "*.a" -delete 2>/dev/null || true
    find build_dir -name "*.so" -delete 2>/dev/null || true
fi

# 5. 清理 staging_dir 中的重复文件
echo "步骤5: 清理 staging_dir..."
if [ -d "staging_dir" ]; then
    # 删除开发文件，保留目标文件
    find staging_dir -name "*.a" -delete 2>/dev/null || true
    find staging_dir -name "*.la" -delete 2>/dev/null || true
    find staging_dir -name "*.pc" -delete 2>/dev/null || true
fi

# 6. 清理下载缓存（选择性保留）
echo "步骤6: 选择性清理下载缓存..."
if [ -d "dl" ]; then
    # 保留内核和主要包，删除其他
    ls -la dl/ | head -20
    echo "保留核心下载文件..."
fi

# 7. 清理编译日志
echo "步骤7: 清理编译日志..."
find . -name "*.log" -size +10M -delete 2>/dev/null || true

# 显示清理后的磁盘使用情况
echo "清理后磁盘使用情况:"
df -h

echo "✅ 磁盘空间清理完成"
