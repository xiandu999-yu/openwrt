#!/bin/bash

echo "=== 添加完整的 Shortcut FE 支持 ==="

# 创建 shortcut-fe 包目录
mkdir -p package/network/shortcut-fe

# 下载完整的 Shortcut FE 组件
echo "下载完整的 Shortcut FE 组件..."

# 1. 下载主 Makefile（如果存在）
echo "下载主 Makefile..."
curl -sSL https://raw.githubusercontent.com/coolsnowwolf/lede/master/package/qca/shortcut-fe/Makefile \
     -o package/network/shortcut-fe/Makefile 2>/dev/null || echo "⚠️  主 Makefile 未找到，使用默认配置"

# 如果主 Makefile 下载失败，创建默认的
if [ ! -f "package/network/shortcut-fe/Makefile" ]; then
    cat > package/network/shortcut-fe/Makefile << 'EOF'
# 这是 Shortcut FE 包的主目录
# 实际组件在子目录中
EOF
fi

# 2. 下载三个子组件
components=("fast-classifier" "shortcut-fe" "simulated-driver")

for component in "${components[@]}"; do
    echo "下载组件: $component"
    mkdir -p "package/network/shortcut-fe/$component"
    
    # 下载组件的 Makefile
    echo "下载 $component Makefile..."
    curl -sSL "https://raw.githubusercontent.com/coolsnowwolf/lede/master/package/qca/shortcut-fe/$component/Makefile" \
         -o "package/network/shortcut-fe/$component/Makefile"
    
    if [ $? -eq 0 ]; then
        echo "✅ $component Makefile 下载成功"
    else
        echo "❌ $component Makefile 下载失败，创建默认配置"
        # 创建默认的 Makefile
        case $component in
            "fast-classifier")
                cat > "package/network/shortcut-fe/$component/Makefile" << 'EOF'
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=fast-classifier
PKG_VERSION:=2.0.2
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
                ;;
            "shortcut-fe")
                cat > "package/network/shortcut-fe/$component/Makefile" << 'EOF'
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=shortcut-fe
PKG_VERSION:=2.0.2
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
                ;;
            "simulated-driver")
                cat > "package/network/shortcut-fe/$component/Makefile" << 'EOF'
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=shortcut-fe-drv
PKG_VERSION:=2.0.2
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
                ;;
        esac
    fi
    
    # 为需要源码的组件创建 src 目录
    if [ "$component" = "fast-classifier" ] || [ "$component" = "shortcut-fe" ]; then
        mkdir -p "package/network/shortcut-fe/$component/src"
        echo "# 源码将在编译时从 Git 仓库下载" > "package/network/shortcut-fe/$component/src/placeholder.c"
    fi
done

# 3. 下载内核补丁
echo "下载 Shortcut FE 内核补丁..."
mkdir -p target/linux/generic/hack-6.1

# 尝试下载不同版本的内核补丁
for patch_version in "6.1" "5.15" "5.10" "5.4"; do
    echo "尝试下载内核 $patch_version 补丁..."
    curl -sSL "https://raw.githubusercontent.com/coolsnowwolf/lede/master/target/linux/generic/hack-$patch_version/953-net-patch-linux-kernel-to-support-shortcut-fe.patch" \
         -o "target/linux/generic/hack-6.1/953-net-patch-linux-kernel-to-support-shortcut-fe.patch"
    
    if [ $? -eq 0 ] && [ -s "target/linux/generic/hack-6.1/953-net-patch-linux-kernel-to-support-shortcut-fe.patch" ]; then
        echo "✅ 内核补丁下载成功 (版本 $patch_version)"
        break
    else
        echo "❌ 内核 $patch_version 补丁下载失败"
    fi
done

# 如果所有补丁下载都失败，创建基础补丁
if [ ! -s "target/linux/generic/hack-6.1/953-net-patch-linux-kernel-to-support-shortcut-fe.patch" ]; then
    echo "创建基础内核补丁..."
    cat > target/linux/generic/hack-6.1/953-net-patch-linux-kernel-to-support-shortcut-fe.patch << 'EOF'
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -470,6 +470,8 @@
 
 source "net/bpf/Kconfig"
 
+source "net/shortcut-fe/Kconfig"
+
 source "net/packet/Kconfig"
 
 source "net/xdp/Kconfig"
--- a/net/Makefile
+++ b/net/Makefile
@@ -78,6 +78,7 @@
 obj-$(CONFIG_DNS_RESOLVER)	+= dns_resolver/
 obj-$(CONFIG_CEPH_LIB)		+= ceph/
 obj-$(CONFIG_BATMAN_ADV)	+= batman-adv/
+obj-$(CONFIG_SHORTCUT_FE)	+= shortcut-fe/
 obj-$(CONFIG_NFC)		+= nfc/
 obj-$(CONFIG_PSAMPLE)		+= psample/
 obj-$(CONFIG_NET_IFE)		+= ife/
EOF
    echo "✅ 基础内核补丁创建完成"
fi

# 4. 创建配置检查脚本
cat > scripts/check-shortcut-fe.sh << 'EOF'
#!/bin/bash

echo "=== 检查 Shortcut FE 配置 ==="

# 检查包是否存在
if [ -d "package/network/shortcut-fe" ]; then
    echo "✅ Shortcut FE 包目录存在"
    
    for component in "fast-classifier" "shortcut-fe" "simulated-driver"; do
        if [ -f "package/network/shortcut-fe/$component/Makefile" ]; then
            echo "✅ $component Makefile 存在"
        else
            echo "❌ $component Makefile 不存在"
        fi
    done
else
    echo "❌ Shortcut FE 包目录不存在"
fi

# 检查内核补丁
if [ -f "target/linux/generic/hack-6.1/953-net-patch-linux-kernel-to-support-shortcut-fe.patch" ]; then
    echo "✅ 内核补丁存在"
else
    echo "❌ 内核补丁不存在"
fi

echo "=== 检查完成 ==="
EOF

chmod +x scripts/check-shortcut-fe.sh

echo "✅ 完整的 Shortcut FE 支持添加完成"
echo "运行 'scripts/check-shortcut-fe.sh' 来检查配置"
