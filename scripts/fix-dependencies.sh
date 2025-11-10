#!/bin/bash

echo "=== 修复 TurboACC 依赖关系 ==="

# 只需要修复 python3-lib2to3 依赖，其他的让 TurboACC 脚本自己处理
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

echo "✅ 依赖修复完成 - 只修复了 python3-lib2to3"
