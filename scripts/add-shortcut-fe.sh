#!/bin/bash

echo "=== 从 LEDE 添加 Shortcut FE 支持 ==="

# 切换到 package 目录
cd package

# 直接从 LEDE 仓库克隆 shortcut-fe 包
echo "从 LEDE 仓库克隆 shortcut-fe..."
if [ ! -d "qca" ]; then
    mkdir qca
fi

cd qca

# 克隆整个 shortcut-fe 目录
if [ ! -d "shortcut-fe" ]; then
    echo "克隆 shortcut-fe 仓库..."
    # 使用 sparse checkout 只下载 shortcut-fe 相关文件
    git init shortcut-fe
    cd shortcut-fe
    git remote add origin https://github.com/coolsnowwolf/lede.git
    git config core.sparsecheckout true
    echo "package/qca/shortcut-fe/*" >> .git/info/sparse-checkout
    git pull --depth=1 origin master
    
    # 移动文件到正确位置
    if [ -d "package/qca/shortcut-fe" ]; then
        mv package/qca/shortcut-fe/* .
        rm -rf package
        echo "✅ shortcut-fe 文件移动完成"
    else
        echo "❌ 文件结构不符合预期，使用备用方案"
        # 备用方案：手动创建文件结构
        cd ..
        rm -rf shortcut-fe
        create_shortcut_fe_manually
    fi
else
    echo "✅ shortcut-fe 目录已存在"
fi

cd ../..

echo "✅ Shortcut FE 支持添加完成"

# 备用方案：手动创建 shortcut-fe 结构
create_shortcut_fe_manually() {
    echo "使用备用方案创建 shortcut-fe..."
    mkdir -p shortcut-fe
    cd shortcut-fe
    
    # 创建三个组件的目录
    mkdir -p fast-classifier shortcut-fe simulated-driver
    
    # 创建 fast-classifier Makefile
    cat > fast-classifier/Makefile << 'EOF'
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=fast-classifier
PKG_VERSION:=2.0.3
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/shortcut-fe.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2020-06-11
PKG_SOURCE_VERSION:=2d71de8bd0c0f36c8e3f0b5dbecb4b7a6c1b3470
PKG_MIRROR_HASH:=skip

PKG_MAINTAINER:=Felix Fietkau <nbd@nbd.name>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define KernelPackage/fast-classifier
  SUBMENU:=Network Support
  TITLE:=Fast Classifier
  DEPENDS:=+kmod-shortcut-fe
  KCONFIG:=CONFIG_FAST_CLASSIFIER=y
  FILES:=$(PKG_BUILD_DIR)/fast-classifier/fast-classifier.ko
  AUTOLOAD:=$(call AutoLoad,09,fast-classifier)
endef

define KernelPackage/fast-classifier/description
  Kernel module for fast packet classification.
endef

define Build/Compile
	+$(KERNEL_MAKE) M=$(PKG_BUILD_DIR) modules
endef

$(eval $(call KernelPackage,fast-classifier))
EOF

    # 创建 shortcut-fe Makefile
    cat > shortcut-fe/Makefile << 'EOF'
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=shortcut-fe
PKG_VERSION:=2.0.3
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/shortcut-fe.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2020-06-11
PKG_SOURCE_VERSION:=2d71de8bd0c0f36c8e3f0b5dbecb4b7a6c1b3470
PKG_MIRROR_HASH:=skip

PKG_MAINTAINER:=Felix Fietkau <nbd@nbd.name>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define KernelPackage/shortcut-fe
  SUBMENU:=Network Support
  TITLE:=Shortcut Forwarding Engine
  DEPENDS:=@!TARGET_uml
  KCONFIG:=CONFIG_SHORTCUT_FE=y
  FILES:=$(PKG_BUILD_DIR)/shortcut-fe/sfe.ko
  AUTOLOAD:=$(call AutoLoad,09,shortcut-fe)
endef

define KernelPackage/shortcut-fe/description
  Kernel module for Shortcut Forwarding Engine.
endef

define Build/Compile
	+$(KERNEL_MAKE) M=$(PKG_BUILD_DIR) modules
endef

$(eval $(call KernelPackage,shortcut-fe))
EOF

    # 创建 simulated-driver Makefile
    cat > simulated-driver/Makefile << 'EOF'
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=shortcut-fe-drv
PKG_VERSION:=2.0.3
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/shortcut-fe.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2020-06-11
PKG_SOURCE_VERSION:=2d71de8bd0c0f36c8e3f0b5dbecb4b7a6c1b3470
PKG_MIRROR_HASH:=skip

PKG_MAINTAINER:=Felix Fietkau <nbd@nbd.name>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define KernelPackage/shortcut-fe-drv
  SUBMENU:=Network Support
  TITLE:=Shortcut FE Simulated Driver
  DEPENDS:=+kmod-shortcut-fe
  KCONFIG:=CONFIG_SHORTCUT_FE_DRV=y
  FILES:=$(PKG_BUILD_DIR)/shortcut-fe/shortcut-fe-drv.ko
  AUTOLOAD:=$(call AutoLoad,09,shortcut-fe-drv)
endef

define KernelPackage/shortcut-fe-drv/description
  Simulated driver for Shortcut Forwarding Engine.
endef

define Build/Compile
	+$(KERNEL_MAKE) M=$(PKG_BUILD_DIR) modules
endef

$(eval $(call KernelPackage,shortcut-fe-drv))
EOF

    echo "✅ 手动创建 shortcut-fe 完成"
}
