#!/bin/bash

echo "=== 修复 TurboACC 依赖关系 ==="

# 创建必要的目录
mkdir -p package/network/turboacc

# 修复 kmod-fast-classifier 依赖
cat > package/network/turboacc/kmod-fast-classifier/Makefile << 'EOF'
include $(TOPDIR)/rules.mk

PKG_NAME:=kmod-fast-classifier
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=OpenWrt
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/fast-classifier
  SUBMENU:=Network Support
  TITLE:=Fast Classifier
  FILES:=
endef

define KernelPackage/fast-classifier/description
  Dummy package for fast classifier dependency
endef

define Build/Compile
  true
endef

$(eval $(call KernelPackage,fast-classifier))
EOF

# 修复 kmod-shortcut-fe-drv 依赖
cat > package/network/turboacc/kmod-shortcut-fe-drv/Makefile << 'EOF'
include $(TOPDIR)/rules.mk

PKG_NAME:=kmod-shortcut-fe-drv
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=OpenWrt
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/shortcut-fe-drv
  SUBMENU:=Network Support
  TITLE:=Shortcut Forwarding Engine Driver
  FILES:=
endef

define KernelPackage/shortcut-fe-drv/description
  Dummy package for shortcut fe driver dependency
endef

define Build/Compile
  true
endef

$(eval $(call KernelPackage,shortcut-fe-drv))
EOF

# 修复 python3-lib2to3 依赖
mkdir -p package/utils/python3-lib2to3
cat > package/utils/python3-lib2to3/Makefile << 'EOF'
include $(TOPDIR)/rules.mk

PKG_NAME:=python3-lib2to3
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=OpenWrt
PKG_LICENSE:=Python-2.0

include $(INCLUDE_DIR)/package.mk

define Package/python3-lib2to3
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python lib2to3 module
  DEPENDS:=+python3-light
endef

define Package/python3-lib2to3/description
  Dummy package for python3-lib2to3 dependency
endef

define Build/Compile
  true
endef

define Package/python3-lib2to3/install
  true
endef

$(eval $(call BuildPackage,python3-lib2to3))
EOF

echo "✅ TurboACC 依赖修复完成"
