#!/bin/bash

echo "Adding custom packages..."

cd package

# 克隆small-package仓库
git clone https://github.com/kenzok8/small-package.git small

# 复制iStore相关包
cp -r small/luci-app-istorex .
cp -r small/luci-app-quickstart .
cp -r small/luci-app-store .
cp -r small/luci-lib-taskd .
cp -r small/quickstart .
cp -r small/luci-lib-xterm .
cp -r small/taskd .

# 清理
rm -rf small

echo "Custom packages added successfully"
