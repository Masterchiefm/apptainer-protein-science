#!/bin/bash

# Singularity容器构建脚本
# 用于构建apptainer-protein-science仓库中的所有容器

set -e  # 遇到错误立即退出

# 设置颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 容器定义
declare -A CONTAINERS=(
    ["LigandMPNN"]="LigandMPNN/ligandmpnn.def:ligandmpnn.sif"
    ["RFdiffusion"]="RFdiffusion/RFdiffusion.def:rfdiffusion.sif"
    ["BindCraft"]="BindCraft/def_file/bindcraft-v1.5.2.def:bindcraft.sif"
    ["BoltzGen"]="boltzgen/boltzgen.def:boltzgen.sif"
    ["Foundry"]="foundry/foundry.def:foundry.sif"
    ["ColabFold"]="ColabFold/colabfold.def:colabfold.sif"
)

# 基础目录
BASE_DIR="/home/chief/apptainer-protein-science"
LOG_DIR="${BASE_DIR}/build_logs"

# 创建日志目录
mkdir -p "${LOG_DIR}"

# 构建单个容器的函数
build_container() {
    local name=$1
    local def_file=$2
    local sif_file=$3
    local log_file="${LOG_DIR}/${name}.log"

    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}开始构建: ${name}${NC}"
    echo -e "${GREEN}========================================${NC}"

    # 检查def文件是否存在
    if [ ! -f "${def_file}" ]; then
        echo -e "${RED}错误: 找不到定义文件 ${def_file}${NC}"
        return 1
    fi

    # 检查sif文件是否已存在
    if [ -f "${sif_file}" ]; then
        echo -e "${YELLOW}警告: ${sif_file} 已存在，将跳过构建${NC}"
        return 0
    fi

    # 构建容器
    cd "${BASE_DIR}"
    local def_dir=$(dirname "${def_file}")
    local def_name=$(basename "${def_file}")

    echo "构建命令: singularity build --fakeroot ${sif_file} ${def_file}"

    if singularity build --fakeroot "${sif_file}" "${def_file}" 2>&1 | tee "${log_file}"; then
        echo -e "${GREEN}✓ ${name} 构建成功!${NC}"
        echo "输出文件: ${sif_file}"
        return 0
    else
        echo -e "${RED}✗ ${name} 构建失败!${NC}"
        echo "查看日志: ${log_file}"
        return 1
    fi
}

# 并行构建所有容器
build_all_parallel() {
    echo -e "${GREEN}开始并行构建所有容器...${NC}"
    echo ""

    local pids=()
    local names=()

    for name in "${!CONTAINERS[@]}"; do
        IFS=':' read -r def_path sif_path <<< "${CONTAINERS[$name]}"
        local def_file="${BASE_DIR}/${def_path}"
        local sif_file="${BASE_DIR}/${sif_path}"

        # 后台构建
        build_container "${name}" "${def_file}" "${sif_file}" &
        pids+=($!)
        names+=("${name}")
    done

    # 等待所有构建完成
    local failed=0
    for i in "${!pids[@]}"; do
        if ! wait ${pids[$i]}; then
            echo -e "${RED}构建失败: ${names[$i]}${NC}"
            ((failed++))
        fi
    done

    echo ""
    echo -e "${GREEN}========================================${NC}"
    if [ ${failed} -eq 0 ]; then
        echo -e "${GREEN}所有容器构建成功!${NC}"
    else
        echo -e "${RED}有 ${failed} 个容器构建失败${NC}"
    fi
    echo -e "${GREEN}========================================${NC}"
}

# 顺序构建所有容器
build_all_sequential() {
    echo -e "${GREEN}开始顺序构建所有容器...${NC}"
    echo ""

    local failed=0

    for name in "${!CONTAINERS[@]}"; do
        IFS=':' read -r def_path sif_path <<< "${CONTAINERS[$name]}"
        local def_file="${BASE_DIR}/${def_path}"
        local sif_file="${BASE_DIR}/${sif_path}"

        if ! build_container "${name}" "${def_file}" "${sif_file}"; then
            ((failed++))
            echo -e "${YELLOW}是否继续构建剩余容器? (y/N)${NC}"
            read -r answer
            if [[ ! "$answer" =~ ^[Yy]$ ]]; then
                break
            fi
        fi
        echo ""
    done

    echo ""
    echo -e "${GREEN}========================================${NC}"
    if [ ${failed} -eq 0 ]; then
        echo -e "${GREEN}所有容器构建成功!${NC}"
    else
        echo -e "${RED}有 ${failed} 个容器构建失败${NC}"
    fi
    echo -e "${GREEN}========================================${NC}"
}

# 列出容器
list_containers() {
    echo "可用的容器:"
    for name in "${!CONTAINERS[@]}"; do
        IFS=':' read -r def_path sif_path <<< "${CONTAINERS[$name]}"
        echo "  - ${name}: ${def_path} -> ${sif_path}"
    done
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项] [容器名称]"
    echo ""
    echo "选项:"
    echo "  -a, --all-parallel   并行构建所有容器"
    echo "  -A, --all-seq        顺序构建所有容器"
    echo "  -l, --list           列出所有可构建的容器"
    echo "  -h, --help           显示帮助信息"
    echo ""
    echo "容器名称: (不指定则构建特定容器)"
    for name in "${!CONTAINERS[@]}"; do
        echo "  - ${name}"
    done
    echo ""
    echo "示例:"
    echo "  $0 LigandMPNN              # 构建单个容器"
    echo "  $0 -a                      # 并行构建所有容器"
    echo "  $0 -A                      # 顺序构建所有容器"
    echo "  $0 -l                      # 列出所有容器"
}

# 主函数
main() {
    case "${1:-}" in
        -a|--all-parallel)
            build_all_parallel
            ;;
        -A|--all-seq)
            build_all_sequential
            ;;
        -l|--list)
            list_containers
            ;;
        -h|--help|"")
            show_help
            ;;
        *)
            # 构建指定容器
            if [ -n "${CONTAINERS[$1]}" ]; then
                IFS=':' read -r def_path sif_path <<< "${CONTAINERS[$1]}"
                local def_file="${BASE_DIR}/${def_path}"
                local sif_file="${BASE_DIR}/${sif_path}"
                build_container "${1}" "${def_file}" "${sif_file}"
            else
                echo -e "${RED}错误: 未知的容器名称 '$1'${NC}"
                echo ""
                list_containers
                exit 1
            fi
            ;;
    esac
}

# 运行主函数
main "$@"
