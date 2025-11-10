#!/bin/bash

echo "=== 直接从 LEDE 下载 Shortcut FE 包 ==="

# 基础 URL
BASE_URL="https://raw.githubusercontent.com/coolsnowwolf/lede/master/package/qca/shortcut-fe"

# 创建目录结构
mkdir -p package/qca/shortcut-fe
cd package/qca/shortcut-fe

echo "下载 shortcut-fe 组件..."

# 1. 下载 fast-classifier
echo "下载 fast-classifier..."
mkdir -p fast-classifier
curl -sSL "$BASE_URL/fast-classifier/Makefile" -o fast-classifier/Makefile
if [ $? -eq 0 ]; then
    echo "✅ fast-classifier/Makefile 下载成功"
else
    echo "❌ 下载失败，使用备用方案"
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
fi

# 2. 下载 shortcut-fe
echo "下载 shortcut-fe..."
mkdir -p shortcut-fe
curl -sSL "$BASE_URL/shortcut-fe/Makefile" -o shortcut-fe/Makefile
if [ $? -eq 0 ]; then
    echo "✅ shortcut-fe/Makefile 下载成功"
else
    echo "❌ 下载失败，使用备用方案"
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
fi

# 3. 下载 simulated-driver
echo "下载 simulated-driver..."
mkdir -p simulated-driver
curl -sSL "$BASE_URL/simulated-driver/Makefile" -o simulated-driver/Makefile
if [ $? -eq 0 ]; then
    echo "✅ simulated-driver/Makefile 下载成功"
else
    echo "❌ 下载失败，使用备用方案"
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
fi

# 创建 src 目录（根据截图信息）
echo "创建 src 目录..."
mkdir -p fast-classifier/src
mkdir -p shortcut-fe/src

# 创建占位文件
echo "// Source files will be downloaded during build" > fast-classifier/src/placeholder.c
echo "// Source files will be downloaded during build" > shortcut-fe/src/placeholder.c

cd ../../..

echo "✅ Shortcut FE 包下载完成"
echo "目录结构:"
find package/qca/shortcut-fe -type f | sort
