#!/bin/bash

echo "=== 模块化构建脚本 ==="

# 构建阶段1: 工具链
build_toolchain() {
    echo "阶段1: 构建工具链..."
    make toolchain/compile -j$(nproc)
    make toolchain/install -j$(nproc)
}

# 构建阶段2: 内核
build_kernel() {
    echo "阶段2: 构建内核..."
    make target/linux/compile -j$(nproc)
}

# 构建阶段3: 内核模块 (独立)
build_kmods() {
    echo "阶段3: 构建内核模块..."
    # 只编译选中的kmod，不全部编译
    for kmod in kmod-r8169 kmod-igb kmod-nft-offload kmod-ppp; do
        if grep -q "CONFIG_PACKAGE_${kmod}=y" .config; then
            echo "编译: $kmod"
            make package/${kod}/compile -j2
        fi
    done
}

# 构建阶段4: 基础包
build_base_packages() {
    echo "阶段4: 构建基础包..."
    make package/compile -j$(nproc)
}

# 构建阶段5: 生成镜像
build_image() {
    echo "阶段5: 生成固件镜像..."
    make -j1 V=s
}

# 主构建流程
main() {
    build_toolchain
    build_kernel
    build_kmods
    build_base_packages
    build_image
    
    echo "=== 构建完成 ==="
    echo "固件位置: bin/targets/"
    echo "IPK包位置: bin/packages/"
}

main "$@"
