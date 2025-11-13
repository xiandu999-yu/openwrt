#!/bin/bash
# 系统依赖安装脚本
# 作者: AI Assistant
# 功能: 跨版本兼容的系统依赖安装

set -e

echo "=== 安装系统依赖（兼容版）==="

# 检测 Ubuntu 版本
detect_ubuntu_version() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "检测到系统: $NAME $VERSION"
        UBUNTU_VERSION=${VERSION_ID%.*}
    else
        echo "无法检测系统版本，使用默认配置"
        UBUNTU_VERSION="20"
    fi
}

# 安装核心编译依赖
install_core_dependencies() {
    echo "安装核心编译依赖..."
    
    sudo apt update -y
    
    # 基础编译工具
    sudo apt install -y \
        build-essential \
        ccache \
        curl \
        file \
        g++ \
        gawk \
        gettext \
        git \
        libncurses5-dev \
        libssl-dev \
        rsync \
        unzip \
        zlib1g-dev \
        make \
        cmake \
        ninja-build \
        pkg-config
    
    # Python 相关（兼容不同版本）
    if apt-cache show python3-distutils &> /dev/null; then
        sudo apt install -y python3 python3-distutils
    else
        sudo apt install -y python3 python3-pip
        echo "python3-distutils 不可用，使用 python3-pip 替代"
    fi
    
    # 清理缓存
    sudo apt clean
    sudo rm -rf /var/lib/apt/lists/*
}

# 安装完整依赖（可选）
install_full_dependencies() {
    echo "安装完整依赖..."
    
    sudo apt update -y
    
    # OpenWrt 编译推荐依赖
    sudo apt install -y \
        ack \
        antlr3 \
        asciidoc \
        autoconf \
        automake \
        autopoint \
        binutils \
        bison \
        bzip2 \
        clang \
        cpio \
        device-tree-compiler \
        flex \
        gcc-multilib \
        g++-multilib \
        genisoimage \
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
        libncursesw5-dev \
        libpython3-dev \
        libreadline-dev \
        libtool \
        llvm \
        lrzsz \
        libnsl-dev \
        p7zip \
        p7zip-full \
        patch \
        python3-pyelftools \
        python3-setuptools \
        qemu-utils \
        scons \
        squashfs-tools \
        subversion \
        swig \
        texinfo \
        uglifyjs \
        upx-ucl \
        vim \
        wget \
        xmlto \
        xxd
    
    sudo apt clean
}

# 显示系统信息
show_system_info() {
    echo "=== 系统信息 ==="
    echo "CPU: $(nproc) 核心"
    echo "内存: $(free -h | grep Mem | awk '{print $2}')"
    echo "磁盘:"
    df -h
    echo "系统版本:"
    lsb_release -a 2>/dev/null || cat /etc/os-release
}

# 主执行函数
main() {
    local install_mode=${1:-"core"}  # core 或 full
    
    show_system_info
    detect_ubuntu_version
    
    case "$install_mode" in
        "core")
            install_core_dependencies
            ;;
        "full")
            install_full_dependencies
            ;;
        *)
            echo "❌ 未知的安装模式: $install_mode"
            echo "可用模式: core, full"
            exit 1
            ;;
    esac
    
    echo "✅ 依赖安装完成"
}

# 执行主函数
main "$@"
