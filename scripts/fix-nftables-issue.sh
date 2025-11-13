#!/bin/bash
# 修复 nftables 编译问题脚本
# 作者: AI Assistant
# 功能: 解决 nftables 补丁兼容性问题，应用 ImmortalWrt 方案

set -e

echo "=== 开始修复 nftables 编译问题 ==="

# 参数处理
TURBOACC_METHOD=${1:-"immortalwrt"}  # 默认值

echo "参数: TURBOACC_METHOD=$TURBOACC_METHOD"

# 移除有问题的补丁文件
echo "步骤1: 清理有问题的补丁..."
if [ -f "package/network/utils/nftables/patches/001-fix-pppox-includes.patch" ]; then
    echo "移除不兼容的补丁: 001-fix-pppox-includes.patch"
    rm -f package/network/utils/nftables/patches/001-fix-pppox-includes.patch
fi

# 清理补丁残留
find package/network/utils/nftables/patches -name "*.rej" -delete 2>/dev/null || true
find package/network/utils/nftables/patches -name "*.orig" -delete 2>/dev/null || true

echo "✅ 补丁清理完成"

# 下载 ImmortalWrt 补丁函数
download_immortalwrt_patches() {
    echo "步骤2: 下载 ImmortalWrt Fullcone NAT 补丁..."
    
    local retries=3
    local timeout=30
    
    # 创建目录
    mkdir -p package/network/utils/fullconenat-nft
    mkdir -p package/network/utils/fullconenat/src
    mkdir -p package/libs/libnftnl/patches
    mkdir -p package/network/utils/nftables/patches
    mkdir -p package/network/config/firewall4/patches
    mkdir -p package/network/config/firewall/patches
    
    # 下载函数
    download_with_retry() {
        local url=$1
        local output=$2
        local retries=$3
        local timeout=$4
        
        for i in $(seq 1 $retries); do
            echo "下载尝试 $i: $(basename $output)"
            if curl -f --connect-timeout $timeout -sSL "$url" -o "$output"; then
                echo "✅ 下载成功: $(basename $output)"
                return 0
            else
                echo "❌ 下载失败 $i: $(basename $output)"
                sleep 2
            fi
        done
        echo "⚠️ 跳过: $(basename $output)"
        return 1
    }
    
    # 下载 ImmortalWrt 补丁
    download_with_retry \
        "https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/package/libs/libnftnl/patches/001-libnftnl-add-fullcone-expression-support.patch" \
        "package/libs/libnftnl/patches/001-libnftnl-add-fullcone-expression-support.patch" \
        $retries $timeout
        
    download_with_retry \
        "https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/package/network/utils/nftables/patches/002-nftables-add-fullcone-expression-support.patch" \
        "package/network/utils/nftables/patches/002-nftables-add-fullcone-expression-support.patch" \
        $retries $timeout
        
    download_with_retry \
        "https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/package/network/config/firewall4/patches/001-firewall4-add-support-for-fullcone-nat.patch" \
        "package/network/config/firewall4/patches/001-firewall4-add-support-for-fullcone-nat.patch" \
        $retries $timeout
        
    download_with_retry \
        "https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/package/network/utils/fullconenat-nft/Makefile" \
        "package/network/utils/fullconenat-nft/Makefile" \
        $retries $timeout
        
    download_with_retry \
        "https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/package/network/utils/fullconenat/Makefile" \
        "package/network/utils/fullconenat/Makefile" \
        $retries $timeout
        
    download_with_retry \
        "https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/package/network/utils/fullconenat/src/Makefile" \
        "package/network/utils/fullconenat/src/Makefile" \
        $retries $timeout
        
    download_with_retry \
        "https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/package/network/config/firewall/patches/fullconenat.patch" \
        "package/network/config/firewall/patches/100-fullconenat.patch" \
        $retries $timeout
    
    echo "✅ ImmortalWrt 补丁下载完成"
}

# 更新 nftables 配置
update_nftables_config() {
    echo "步骤3: 更新 nftables 配置为 ImmortalWrt 1.1.5 版本..."
    
    cat > package/network/utils/nftables/Makefile << 'EOF'
# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2015 OpenWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=nftables
PKG_VERSION:=1.1.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://netfilter.org/projects/$(PKG_NAME)/files
PKG_HASH:=1daf10f322e14fd90a017538aaf2c034d7cc1eb1cc418ded47445d714ea168d4

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

PKG_BUILD_FLAGS:=lto

include $(INCLUDE_DIR)/package.mk

DISABLE_NLS:=

CONFIGURE_ARGS += \
        --disable-debug \
        --disable-man-doc \
        --with-mini-gmp \
        --without-cli \
        --disable-python

define Package/nftables/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Firewall
  TITLE:=nftables userspace utility
  DEPENDS:=+kmod-nft-core +libnftnl
  URL:=http://netfilter.org/projects/nftables/
  PROVIDES:=nftables
endef

define Package/nftables-nojson
  $(Package/nftables/Default)
  TITLE+= no JSON support
  VARIANT:=nojson
  DEFAULT_VARIANT:=1
  CONFLICTS:=nftables-json
endef

define Package/nftables-json
  $(Package/nftables/Default)
  TITLE+= with JSON support
  VARIANT:=json
  DEPENDS+=+jansson
endef

ifeq ($(BUILD_VARIANT),json)
  CONFIGURE_ARGS += --with-json
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/nftables $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libnftables.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/nftables/install/Default
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/nft $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef

Package/nftables-nojson/install = $(Package/nftables/install/Default)
Package/nftables-json/install = $(Package/nftables/install/Default)

$(eval $(call BuildPackage,nftables-nojson))
$(eval $(call BuildPackage,nftables-json))
EOF
    
    echo "✅ nftables 配置更新完成"
}

# 清理构建缓存
clean_build_cache() {
    echo "步骤4: 清理构建缓存..."
    
    rm -rf build_dir/target-aarch64_generic_musl/nftables-*
    rm -rf staging_dir/target-aarch64_generic_musl/packages/nftables*
    
    echo "✅ 构建缓存清理完成"
}

# 主执行函数
main() {
    # 基础清理（所有方案都需要）
    clean_build_cache
    
    # 根据方案选择操作
    case "$TURBOACC_METHOD" in
        "immortalwrt"|"")
            echo "应用 ImmortalWrt Fullcone NAT 方案..."
            download_immortalwrt_patches
            update_nftables_config
            ;;
        "script")
            echo "使用脚本方案，跳过 ImmortalWrt 补丁应用"
            ;;
        *)
            echo "❌ 未知的 TurboACC 方案: $TURBOACC_METHOD"
            echo "可用方案: script, immortalwrt"
            exit 1
            ;;
    esac
    
    echo "=== nftables 问题修复完成 ==="
}

# 执行主函数
main "$@"
