#!/bin/bash
# 完整编译环境设置脚本
# 基于用户提供的完整依赖列表

set -e

echo "=== 设置完整 OpenWrt 编译环境 ==="

show_system_info() {
    echo "=== 系统信息 ==="
    echo "系统: $(lsb_release -d | cut -f2)"
    echo "CPU: $(nproc) 核心"
    echo "内存: $(free -h | grep Mem | awk '{print $2}')"
    echo "磁盘空间:"
    df -h
}

install_complete_dependencies() {
    echo "=== 安装完整编译依赖 ==="
    
    # 更新系统
    sudo apt update -y
    sudo apt full-upgrade -y
    
    # 安装完整依赖列表（用户提供的）
    sudo apt install -y \
        ack \
        antlr3 \
        asciidoc \
        autoconf \
        automake \
        autopoint \
        binutils \
        bison \
        build-essential \
        bzip2 \
        ccache \
        clang \
        cmake \
        cpio \
        curl \
        device-tree-compiler \
        flex \
        gawk \
        gcc-multilib \
        g++-multilib \
        gettext \
        genisoimage \
        git \
        gperf \
        haveged \
        help2man \
        intltool \
        libc6-dev-i386 \
        libelf-dev \
        libfuse-dev \
        libglib2.0-dev \
        libgmp3-dev \
        libltdl-dev \
        libmpc-dev \
        libmpfr-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libpython3-dev \
        libreadline-dev \
        libssl-dev \
        libtool \
        llvm \
        lrzsz \
        libnsl-dev \
        ninja-build \
        p7zip \
        p7zip-full \
        patch \
        pkgconf \
        python3 \
        python3-pyelftools \
        python3-setuptools \
        qemu-utils \
        rsync \
        scons \
        squashfs-tools \
        subversion \
        swig \
        texinfo \
        uglifyjs \
        upx-ucl \
        unzip \
        vim \
        wget \
        xmlto \
        xxd \
        zlib1g-dev
    
    echo "✅ 完整依赖安装完成"
}

setup_ccache() {
    echo "=== 设置 CCache 加速 ==="
    
    # 设置 ccache 缓存大小
    ccache -M 5G
    
    # 在编译环境中启用 ccache
    export CCACHE_DIR="/tmp/ccache"
    mkdir -p $CCACHE_DIR
    
    echo "CCache 状态:"
    ccache -s
}

clean_system_cache() {
    echo "=== 清理系统缓存 ==="
    
    # 清理包缓存
    sudo apt clean
    sudo rm -rf /var/lib/apt/lists/*
    
    # 清理临时文件
    sudo rm -rf /tmp/*
    sudo rm -rf /var/tmp/*
    
    echo "✅ 系统缓存清理完成"
}

# 主执行函数
main() {
    show_system_info
    install_complete_dependencies
    setup_ccache
    clean_system_cache
    
    echo "=== 编译环境设置完成 ==="
    echo "所有必要的编译依赖已安装"
    echo "CCache 已配置用于加速编译"
}

# 执行主函数
main "$@"
