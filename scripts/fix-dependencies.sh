#!/bin/bash

echo "=== 修复依赖关系 ==="

# 1. 修复 python3-lib2to3 依赖
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

# 2. 修复 coreutils 相关依赖
mkdir -p package/utils/coreutils
cat > package/utils/coreutils/Makefile << 'EOF'
include $(TOPDIR)/rules.mk

PKG_NAME:=coreutils
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=OpenWrt
PKG_LICENSE:=GPL-3.0

include $(INCLUDE_DIR)/package.mk

define Package/coreutils
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=GNU core utilities
endef

define Package/coreutils/description
  Dummy package for coreutils dependency
endef

define Build/Compile
  true
endef

define Package/coreutils/install
  true
endef

$(eval $(call BuildPackage,coreutils))
EOF

# 3. 创建 coreutils 子包
coreutils_utils=("sort" "od" "stat" "tee" "mktemp" "chroot" "sha1sum" "sleep" "date" "timeout" "dirname")
for util in "${coreutils_utils[@]}"; do
    mkdir -p package/utils/coreutils-$util
    cat > package/utils/coreutils-$util/Makefile << EOF
include \$(TOPDIR)/rules.mk

PKG_NAME:=coreutils-$util
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=OpenWrt
PKG_LICENSE:=GPL-3.0

include \$(INCLUDE_DIR)/package.mk

define Package/coreutils-$util
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=coreutils $util utility
  DEPENDS:=+coreutils
endef

define Package/coreutils-$util/description
  Dummy package for coreutils-$util dependency
endef

define Build/Compile
  true
endef

define Package/coreutils-$util/install
  true
endef

\$(eval \$(call BuildPackage,coreutils-$util))
EOF
done

# 4. 修复 libpam 依赖
mkdir -p package/libs/libpam
cat > package/libs/libpam/Makefile << 'EOF'
include $(TOPDIR)/rules.mk

PKG_NAME:=libpam
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=OpenWrt
PKG_LICENSE:=BSD-3-Clause

include $(INCLUDE_DIR)/package.mk

define Package/libpam
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Pluggable Authentication Modules library
endef

define Package/libpam/description
  Dummy package for libpam dependency
endef

define Build/Compile
  true
endef

define Package/libpam/install
  true
endef

$(eval $(call BuildPackage,libpam))
EOF

# 5. 修复 libtirpc 依赖
mkdir -p package/libs/libtirpc
cat > package/libs/libtirpc/Makefile << 'EOF'
include $(TOPDIR)/rules.mk

PKG_NAME:=libtirpc
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=OpenWrt
PKG_LICENSE:=BSD-3-Clause

include $(INCLUDE_DIR)/package.mk

define Package/libtirpc
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Libtirpc library
endef

define Package/libtirpc/description
  Dummy package for libtirpc dependency
endef

define Build/Compile
  true
endef

define Package/libtirpc/install
  true
endef

$(eval $(call BuildPackage,libtirpc))
EOF

# 6. 修复 shadow-utils 依赖
mkdir -p package/utils/shadow-utils
cat > package/utils/shadow-utils/Makefile << 'EOF'
include $(TOPDIR)/rules.mk

PKG_NAME:=shadow-utils
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=OpenWrt
PKG_LICENSE:=BSD-3-Clause

include $(INCLUDE_DIR)/package.mk

define Package/shadow-utils
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Shadow password utilities
endef

define Package/shadow-utils/description
  Dummy package for shadow-utils dependency
endef

define Build/Compile
  true
endef

define Package/shadow-utils/install
  true
endef

$(eval $(call BuildPackage,shadow-utils))
EOF

# 7. 修复 luci-lua-runtime 依赖
mkdir -p package/network/services/luci-lua-runtime
cat > package/network/services/luci-lua-runtime/Makefile << 'EOF'
include $(TOPDIR)/rules.mk

PKG_NAME:=luci-lua-runtime
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=OpenWrt
PKG_LICENSE:=Apache-2.0

include $(INCLUDE_DIR)/package.mk

define Package/luci-lua-runtime
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Lua
  TITLE:=Lua runtime for LuCI
  DEPENDS:=+lua
endef

define Package/luci-lua-runtime/description
  Dummy package for luci-lua-runtime dependency
endef

define Build/Compile
  true
endef

define Package/luci-lua-runtime/install
  true
endef

$(eval $(call BuildPackage,luci-lua-runtime))
EOF

echo "✅ 依赖修复完成 - 创建了所有必要的虚拟包"
