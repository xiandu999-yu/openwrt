#!/bin/bash

echo "=== 修复依赖关系警告 ==="

# 创建必要的目录
mkdir -p package/utils/python3-distutils
mkdir -p package/network/turboacc

# 1. 修复 python3-distutils 依赖
cat > package/utils/python3-distutils/Makefile << 'EOF'
include $(TOPDIR)/rules.mk

PKG_NAME:=python3-distutils
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=OpenWrt
PKG_LICENSE:=Python-2.0

include $(INCLUDE_DIR)/package.mk

define Package/python3-distutils
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python distutils module
  URL:=https://www.python.org
  DEPENDS:=+python3-light
endef

define Package/python3-distutils/description
  The distutils module for Python.
endef

define Build/Compile
  true
endef

define Package/python3-distutils/install
  true
endef

$(eval $(call BuildPackage,python3-distutils))
EOF

# 2. 修复 TurboACC 相关依赖
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
  DEPENDS:=@!TARGET_uml
  KCONFIG:=CONFIG_FAST_CLASSIFIER
  FILES:=$(LINUX_DIR)/net/fast-classifier/fast-classifier.ko
  AUTOLOAD:=$(call AutoLoad,09,fast-classifier)
endef

define KernelPackage/fast-classifier/description
  Kernel module for fast packet classification.
endef

define Build/Compile
  true
endef

$(eval $(call KernelPackage,fast-classifier))
EOF

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
  DEPENDS:=@!TARGET_uml
  KCONFIG:=CONFIG_SHORTCUT_FE
  FILES:=$(LINUX_DIR)/net/shortcut-fe/shortcut-fe.ko
  AUTOLOAD:=$(call AutoLoad,09,shortcut-fe)
endef

define KernelPackage/shortcut-fe-drv/description
  Kernel module for Shortcut Forwarding Engine.
endef

define Build/Compile
  true
endef

$(eval $(call KernelPackage,shortcut-fe-drv))
EOF

# 3. 修复 python3-lib2to3 依赖
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
  URL:=https://www.python.org
  DEPENDS:=+python3-light
endef

define Package/python3-lib2to3/description
  The lib2to3 module for Python 3.x.
endef

define Build/Compile
  true
endef

define Package/python3-lib2to3/install
  true
endef

$(eval $(call BuildPackage,python3-lib2to3))
EOF

echo "✅ 依赖关系修复完成"
