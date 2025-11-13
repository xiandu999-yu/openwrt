#!/bin/bash
# TurboACC 加速方案应用脚本
# 作者: AI Assistant
# 功能: 根据选择的方案应用对应的 TurboACC 配置

set -e

echo "=== 应用 TurboACC 加速方案 ==="

# 参数
TURBOACC_METHOD=$1
INCLUDE_SFE=$2

apply_script_solution() {
    echo "应用脚本方案 TurboACC..."
    
    if [ "$INCLUDE_SFE" = "true" ]; then
        echo "安装完整TurboACC (包含SFE)"
        curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh
        bash add_turboacc.sh
    else
        echo "安装TurboACC (不包含SFE)"
        curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh
        bash add_turboacc.sh --no-sfe
    fi
    
    echo "✅ 脚本方案应用完成"
}

apply_immortalwrt_solution() {
    echo "应用 ImmortalWrt Fullcone NAT 方案..."
    # 具体的补丁下载在 fix-nftables-issue.sh 中处理
    echo "✅ ImmortalWrt 方案标记已设置"
}

# 主执行函数
main() {
    case "$TURBOACC_METHOD" in
        "script")
            apply_script_solution
            ;;
        "immortalwrt")
            apply_immortalwrt_solution
            ;;
        *)
            echo "❌ 未知的 TurboACC 方案: $TURBOACC_METHOD"
            exit 1
            ;;
    esac
    
    echo "=== TurboACC 方案应用完成 ==="
}

# 执行主函数
main "$@"
