#!/bin/bash

echo "Adding custom packages..."

cd package

# 克隆small-package仓库
if [ ! -d "small" ]; then
    git clone https://github.com/kenzok8/small-package.git small
fi

# 复制iStore相关包（选择性复制，避免依赖问题）
if [ -d "small/luci-app-istorex" ]; then
    echo "Adding luci-app-istorex..."
    cp -r small/luci-app-istorex .
    
    # 修复luci-app-istorex的依赖
    if [ -f "luci-app-istorex/Makefile" ]; then
        # 备份原文件
        cp luci-app-istorex/Makefile luci-app-istorex/Makefile.bak
        # 使用更安全的sed命令
        sed -i 's/DEPENDS:=.*/DEPENDS:=+lua +libc +LUCI_LANG_zh-cn/g' luci-app-istorex/Makefile
        echo "✅ luci-app-istorex 依赖修复完成"
    fi
fi

if [ -d "small/luci-app-quickstart" ]; then
    echo "Adding luci-app-quickstart..."
    cp -r small/luci-app-quickstart .
    
    # 修复luci-app-quickstart的依赖
    if [ -f "luci-app-quickstart/Makefile" ]; then
        cp luci-app-quickstart/Makefile luci-app-quickstart/Makefile.bak
        sed -i 's/DEPENDS:=.*/DEPENDS:=+lua +libc +LUCI_LANG_zh-cn/g' luci-app-quickstart/Makefile
        echo "✅ luci-app-quickstart 依赖修复完成"
    fi
fi

if [ -d "small/luci-app-store" ]; then
    echo "Adding luci-app-store..."
    cp -r small/luci-app-store .
    
    # 修复luci-app-store的依赖
    if [ -f "luci-app-store/Makefile" ]; then
        cp luci-app-store/Makefile luci-app-store/Makefile.bak
        # 修复依赖，确保格式正确
        sed -i 's/DEPENDS:=.*/DEPENDS:=+curl +tar +luci-base/g' luci-app-store/Makefile
        # 修复其他依赖问题
        sed -i 's/luci-lua-runtime//g' luci-app-store/Makefile
        echo "✅ luci-app-store 依赖修复完成"
    fi
fi

# 复制基础库包
if [ -d "small/luci-lib-taskd" ]; then
    echo "Adding luci-lib-taskd..."
    cp -r small/luci-lib-taskd .
    
    # 修复依赖
    if [ -f "luci-lib-taskd/Makefile" ]; then
        cp luci-lib-taskd/Makefile luci-lib-taskd/Makefile.bak
        sed -i 's/DEPENDS:=.*/DEPENDS:=+lua +libc/g' luci-lib-taskd/Makefile
        echo "✅ luci-lib-taskd 依赖修复完成"
    fi
fi

if [ -d "small/quickstart" ]; then
    echo "Adding quickstart..."
    cp -r small/quickstart .
    
    # 修复quickstart的依赖 - 使用更安全的方法
    if [ -f "quickstart/Makefile" ]; then
        cp quickstart/Makefile quickstart/Makefile.bak
        # 完全重写DEPENDS行
        sed -i '/^DEPENDS:=/c\DEPENDS:=+coreutils +parted +smartmontools +bash' quickstart/Makefile
        echo "✅ quickstart 依赖修复完成"
    fi
fi

if [ -d "small/luci-lib-xterm" ]; then
    echo "Adding luci-lib-xterm..."
    cp -r small/luci-lib-xterm .
    
    # 修复依赖
    if [ -f "luci-lib-xterm/Makefile" ]; then
        cp luci-lib-xterm/Makefile luci-lib-xterm/Makefile.bak
        sed -i 's/DEPENDS:=.*/DEPENDS:=+lua +libc/g' luci-lib-xterm/Makefile
        echo "✅ luci-lib-xterm 依赖修复完成"
    fi
fi

if [ -d "small/taskd" ]; then
    echo "Adding taskd..."
    cp -r small/taskd .
    
    # 修复taskd的依赖
    if [ -f "taskd/Makefile" ]; then
        cp taskd/Makefile taskd/Makefile.bak
        # 完全重写DEPENDS行
        sed -i '/^DEPENDS:=/c\DEPENDS:=+coreutils +coreutils-stty +procd' taskd/Makefile
        echo "✅ taskd 依赖修复完成"
    fi
fi

# 添加其他有用的包（可选）
if [ -d "small/luci-theme-argon" ]; then
    echo "Adding luci-theme-argon..."
    cp -r small/luci-theme-argon .
fi

if [ -d "small/luci-app-argon-config" ]; then
    echo "Adding luci-app-argon-config..."
    cp -r small/luci-app-argon-config .
fi

# 清理
rm -rf small

echo "Custom packages added and dependencies fixed successfully"
