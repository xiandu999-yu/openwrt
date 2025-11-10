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
        sed -i 's/luci-lua-runtime//g' luci-app-istorex/Makefile
        sed -i 's/luci-base\/host//g' luci-app-istorex/Makefile
        sed -i 's/csstidy\/host//g' luci-app-istorex/Makefile
        sed -i 's/luasrcdiet\/host//g' luci-app-istorex/Makefile
    fi
fi

if [ -d "small/luci-app-quickstart" ]; then
    echo "Adding luci-app-quickstart..."
    cp -r small/luci-app-quickstart .
    
    # 修复luci-app-quickstart的依赖
    if [ -f "luci-app-quickstart/Makefile" ]; then
        sed -i 's/luci-lua-runtime//g' luci-app-quickstart/Makefile
        sed -i 's/luci-base\/host//g' luci-app-quickstart/Makefile
        sed -i 's/csstidy\/host//g' luci-app-quickstart/Makefile
        sed -i 's/luasrcdiet\/host//g' luci-app-quickstart/Makefile
    fi
fi

if [ -d "small/luci-app-store" ]; then
    echo "Adding luci-app-store..."
    cp -r small/luci-app-store .
    
    # 修复luci-app-store的依赖
    if [ -f "luci-app-store/Makefile" ]; then
        sed -i 's/luci-lua-runtime//g' luci-app-store/Makefile
        sed -i 's/luci-base\/host//g' luci-app-store/Makefile
        sed -i 's/csstidy\/host//g' luci-app-store/Makefile
        sed -i 's/luasrcdiet\/host//g' luci-app-store/Makefile
        # 添加缺失的依赖
        sed -i 's/DEPENDS:=/DEPENDS:=+curl +tar +luci-base/g' luci-app-store/Makefile
    fi
fi

# 复制基础库包
if [ -d "small/luci-lib-taskd" ]; then
    echo "Adding luci-lib-taskd..."
    cp -r small/luci-lib-taskd .
    
    # 修复依赖
    if [ -f "luci-lib-taskd/Makefile" ]; then
        sed -i 's/luci-lua-runtime//g' luci-lib-taskd/Makefile
        sed -i 's/luci-base\/host//g' luci-lib-taskd/Makefile
        sed -i 's/csstidy\/host//g' luci-lib-taskd/Makefile
        sed -i 's/luasrcdiet\/host//g' luci-lib-taskd/Makefile
    fi
fi

if [ -d "small/quickstart" ]; then
    echo "Adding quickstart..."
    cp -r small/quickstart .
    
    # 修复quickstart的依赖
    if [ -f "quickstart/Makefile" ]; then
        sed -i 's/shadow-utils//g' quickstart/Makefile
        sed -i 's/shadow-useradd//g' quickstart/Makefile
        sed -i 's/parted//g' quickstart/Makefile
        sed -i 's/smartmontools//g' quickstart/Makefile
        sed -i 's/smartd//g' quickstart/Makefile
        sed -i 's/bash//g' quickstart/Makefile
        # 添加基础依赖
        sed -i 's/DEPENDS:=/DEPENDS:=+coreutils +parted +smartmontools +bash/g' quickstart/Makefile
    fi
fi

if [ -d "small/luci-lib-xterm" ]; then
    echo "Adding luci-lib-xterm..."
    cp -r small/luci-lib-xterm .
    
    # 修复依赖
    if [ -f "luci-lib-xterm/Makefile" ]; then
        sed -i 's/luci-lua-runtime//g' luci-lib-xterm/Makefile
        sed -i 's/luci-base\/host//g' luci-lib-xterm/Makefile
        sed -i 's/csstidy\/host//g' luci-lib-xterm/Makefile
        sed -i 's/luasrcdiet\/host//g' luci-lib-xterm/Makefile
    fi
fi

if [ -d "small/taskd" ]; then
    echo "Adding taskd..."
    cp -r small/taskd .
    
    # 修复taskd的依赖
    if [ -f "taskd/Makefile" ]; then
        sed -i 's/coreutils//g' taskd/Makefile
        sed -i 's/coreutils-stty//g' taskd/Makefile
        # 添加基础依赖
        sed -i 's/DEPENDS:=/DEPENDS:=+coreutils +coreutils-stty/g' taskd/Makefile
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
