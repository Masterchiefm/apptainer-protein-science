#!/bin/bash

# Singularity容器构建监控脚本

set -e

# 设置颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BASE_DIR="/home/chief/apptainer-protein-science"
LOG_DIR="${BASE_DIR}/build_logs"

# 容器列表
declare -A CONTAINERS=(
    ["LigandMPNN"]="ligandmpnn.sif"
    ["RFdiffusion"]="rfdiffusion.sif"
    ["BindCraft"]="bindcraft.sif"
    ["BoltzGen"]="boltzgen.sif"
    ["Foundry"]="foundry.sif"
    ["ColabFold"]="colabfold.sif"
)

# 检查构建进程
check_processes() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}构建进程状态${NC}"
    echo -e "${BLUE}========================================${NC}"

    if pgrep -f "singularity build" > /dev/null; then
        echo -e "${GREEN}✓ 正在运行中的构建进程:${NC}"
        ps aux | grep "singularity build" | grep -v grep | awk '{print "  PID:", $2, "  CPU:", $3"%", "  MEM:", $4"%", "  CMD:", $11, $12, $13}'
    else
        echo -e "${YELLOW}没有正在运行的构建进程${NC}"
    fi
    echo ""
}

# 检查容器文件状态
check_sif_files() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}容器文件状态${NC}"
    echo -e "${BLUE}========================================${NC}"

    for name in "${!CONTAINERS[@]}"; do
        local sif_file="${BASE_DIR}/${CONTAINERS[$name]}"

        if [ -f "${sif_file}" ]; then
            local size=$(du -h "${sif_file}" | cut -f1)
            local mod_time=$(stat -c %y "${sif_file}" | cut -d'.' -f1)
            echo -e "${GREEN}✓ ${name}${NC}: ${size} (${mod_time})"
        else
            echo -e "${YELLOW}○ ${name}${NC}: 尚未完成"
        fi
    done
    echo ""
}

# 显示构建日志摘要
show_log_summary() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}构建日志摘要${NC}"
    echo -e "${BLUE}========================================${NC}"

    for name in "${!CONTAINERS[@]}"; do
        local log_file="${LOG_DIR}/${name}.log"

        if [ -f "${log_file}" ]; then
            local lines=$(wc -l < "${log_file}")
            local last_line=$(tail -1 "${log_file}")

            echo -e "${name}:"
            echo "  日志行数: ${lines}"
            echo "  最后一行: ${last_line}"

            # 检查是否有错误
            if grep -q "ERROR\|error\|Error\|Failed\|failed" "${log_file}"; then
                echo -e "  ${RED}✗ 检测到错误${NC}"
            fi
        else
            echo -e "${name}: 日志文件不存在"
        fi
        echo ""
    done
}

# 显示磁盘使用情况
show_disk_usage() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}磁盘使用情况${NC}"
    echo -e "${BLUE}========================================${NC}"

    df -h / | tail -1 | awk '{print "根目录: 已用 " $3 " / " $2 " (" $5 ")"}'
    echo ""
}

# 显示主构建日志
show_main_log() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}主构建日志 (最后50行)${NC}"
    echo -e "${BLUE}========================================${NC}"

    local main_log="${BASE_DIR}/build_all.log"
    if [ -f "${main_log}" ]; then
        tail -50 "${main_log}"
    else
        echo "主构建日志文件不存在"
    fi
    echo ""
}

# 显示特定容器的完整日志
show_container_log() {
    local name=$1

    if [ -z "${CONTAINERS[$name]}" ]; then
        echo -e "${RED}错误: 未知的容器名称 '${name}'${NC}"
        return 1
    fi

    local log_file="${LOG_DIR}/${name}.log"

    if [ ! -f "${log_file}" ]; then
        echo -e "${YELLOW}日志文件不存在: ${log_file}${NC}"
        return 1
    fi

    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}${name} 完整构建日志${NC}"
    echo -e "${BLUE}========================================${NC}"
    cat "${log_file}"
}

# 清理失败的构建
cleanup_failed() {
    echo -e "${YELLOW}清理失败的构建...${NC}"

    for name in "${!CONTAINERS[@]}"; do
        local sif_file="${BASE_DIR}/${CONTAINERS[$name]}"

        if [ -f "${sif_file}" ]; then
            # 检查sif文件是否为空或损坏
            local size=$(stat -c %s "${sif_file}")
            if [ "${size}" -lt 10000 ]; then
                echo -e "${RED}删除损坏的文件: ${sif_file} (大小: ${size} 字节)${NC}"
                rm "${sif_file}"
            fi
        fi
    done
}

# 重试失败的构建
retry_failed() {
    echo -e "${GREEN}重试失败的构建...${NC}"
    "${BASE_DIR}/build_all.sh" -a
}

# 主菜单
main_menu() {
    while true; do
        clear
        check_processes
        check_sif_files
        show_disk_usage
        show_log_summary

        echo -e "${BLUE}========================================${NC}"
        echo -e "${BLUE}选项:${NC}"
        echo -e "${BLUE}========================================${NC}"
        echo "1. 实时监控 (自动刷新)"
        echo "2. 查看主构建日志"
        echo "3. 查看特定容器日志"
        echo "4. 清理失败的构建"
        echo "5. 重试失败的构建"
        echo "6. 退出"
        echo ""
        read -p "请选择 (1-6): " choice

        case $choice in
            1)
                echo -e "${GREEN}按 Ctrl+C 停止监控${NC}"
                sleep 2
                while true; do
                    clear
                    check_processes
                    check_sif_files
                    echo -e "${GREEN}刷新中... (5秒后)${NC}"
                    sleep 5
                done
                ;;
            2)
                show_main_log
                echo -e "${YELLOW}按 Enter 继续${NC}"
                read
                ;;
            3)
                echo "可用的容器:"
                for name in "${!CONTAINERS[@]}"; do
                    echo "  - ${name}"
                done
                read -p "输入容器名称: " name
                show_container_log "${name}"
                echo -e "${YELLOW}按 Enter 继续${NC}"
                read
                ;;
            4)
                cleanup_failed
                echo -e "${YELLOW}按 Enter 继续${NC}"
                read
                ;;
            5)
                retry_failed
                echo -e "${YELLOW}按 Enter 继续${NC}"
                read
                ;;
            6)
                echo -e "${GREEN}退出监控${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效选择${NC}"
                sleep 2
                ;;
        esac
    done
}

# 检查命令行参数
case "${1:-}" in
    --watch)
        echo -e "${GREEN}监控模式 (按 Ctrl+C 停止)${NC}"
        sleep 2
        while true; do
            clear
            check_processes
            check_sif_files
            echo -e "${GREEN}刷新中... (5秒后)${NC}"
            sleep 5
        done
        ;;
    --log)
        show_main_log
        ;;
    --log-*)
        name="${1#--log-}"
        show_container_log "${name}"
        ;;
    "")
        main_menu
        ;;
    *)
        echo "用法: $0 [选项]"
        echo ""
        echo "选项:"
        echo "  --watch          实时监控模式"
        echo "  --log            显示主构建日志"
        echo "  --log-<容器名>   显示特定容器的完整日志"
        echo ""
        echo "示例:"
        echo "  $0 --watch"
        echo "  $0 --log"
        echo "  $0 --log-LigandMPNN"
        ;;
esac
