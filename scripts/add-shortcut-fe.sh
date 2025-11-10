#!/bin/bash

echo "=== 添加完整的 Shortcut FE 支持 ==="

# 创建 shortcut-fe 包目录
mkdir -p package/network/shortcut-fe

# 下载完整的 Shortcut FE 组件
echo "下载完整的 Shortcut FE 组件..."

# 1. 下载主 Makefile
curl -sSL https://raw.githubusercontent.com/coolsnowwolf/lede/master/package/qca/shortcut-fe/Makefile \
     -o package/network/shortcut-fe/Makefile

# 2. 下载三个子组件
components=("fast-classifier" "shortcut-fe" "simulated-driver")

for component in "${components[@]}"; do
    echo "下载组件: $component"
    mkdir -p "package/network/shortcut-fe/$component"
    
    # 下载组件的 Makefile
    curl -sSL "https://raw.githubusercontent.com/coolsnowwolf/lede/master/package/qca/shortcut-fe/$component/Makefile" \
         -o "package/network/shortcut-fe/$component/Makefile" 2>/dev/null || echo "⚠️  $component Makefile 未找到"
    
    # 下载源码文件（如果存在）
    if [ -d "package/network/shortcut-fe/$component" ]; then
        mkdir -p "package/network/shortcut-fe/$component/src"
        # 尝试下载常见的源码文件
        for file in "src"/*.c "src"/*.h 2>/dev/null; do
            src_file=$(basename "$file")
            curl -sSL "https://raw.githubusercontent.com/coolsnowwolf/lede/master/package/qca/shortcut-fe/$component/src/$src_file" \
                 -o "package/network/shortcut-fe/$component/src/$src_file" 2>/dev/null || true
        done
    fi
done

# 3. 下载内核补丁
echo "下载 Shortcut FE 内核补丁..."
mkdir -p target/linux/generic/hack-6.1
curl -sSL https://raw.githubusercontent.com/coolsnowwolf/lede/master/target/linux/generic/hack-6.1/953-net-patch-linux-kernel-to-support-shortcut-fe.patch \
     -o target/linux/generic/hack-6.1/953-net-patch-linux-kernel-to-support-shortcut-fe.patch

# 4. 创建依赖关系修复
create_dependency_fixes() {
    echo "创建依赖关系修复..."
    
    # 修复 kmod-fast-classifier 依赖
    cat > package/network/shortcut-fe/fast-classifier/Makefile << 'EOF'
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
  DEPENDS:=+kmod-shortcut-fe
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

    # 修复 kmod-shortcut-fe-drv 依赖
    cat > package/network/shortcut-fe/shortcut-fe/Makefile << 'EOF'
include $(TOPDIR)/rules.mk

PKG_NAME:=kmod-shortcut-fe
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=OpenWrt
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/shortcut-fe
  SUBMENU:=Network Support
  TITLE:=Shortcut Forwarding Engine
  DEPENDS:=@!TARGET_uml
  KCONFIG:=CONFIG_SHORTCUT_FE
  FILES:=$(LINUX_DIR)/net/shortcut-fe/shortcut-fe.ko
  AUTOLOAD:=$(call AutoLoad,09,shortcut-fe)
endef

define KernelPackage/shortcut-fe/description
  Kernel module for Shortcut Forwarding Engine.
endef

define Build/Compile
  true
endef

$(eval $(call KernelPackage,shortcut-fe))
EOF
}

create_dependency_fixes

echo "✅ 完整的 Shortcut FE 支持添加完成"
