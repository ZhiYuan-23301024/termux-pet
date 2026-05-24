#!/data/data/com.termux/files/usr/bin/bash

# Termux Pet - 终端宠物交互系统

# 定义颜色常量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 获取脚本所在目录
PET_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# 加载配置文件
if [ -f "$PET_DIR/pet.conf" ]; then
    source "$PET_DIR/pet.conf"
else
    # 默认配置
    SHOW_COMMAND="pet show"
    HIDE_COMMAND="pet hide"
    FAVORITE_MIN=0
    FAVORITE_MAX=100
    FAVORITE_INCREMENT=1
    PET_NAME="小宠物"
    DIALOGUE_FILE="$PET_DIR/dialogues.txt"
    FAVORITE_FILE="$PET_DIR/.favorite"
    STATE_FILE="$PET_DIR/.state"
    PET_WIDTH=20
    DIALOGUE_MAX_LENGTH=50
fi

# 宠物状态
PET_VISIBLE=false

# 宠物形象 (cowsay风格)
PET_ART='        (__)
        (oo)
   /------\\/
  /        \\
 |          |
  \\        /
   \\------/'

# 读取好感度
read_favorite() {
    if [ -f "$FAVORITE_FILE" ]; then
        cat "$FAVORITE_FILE"
    else
        echo "$FAVORITE_MIN"
    fi
}

# 保存好感度
save_favorite() {
    echo "$1" > "$FAVORITE_FILE"
}

# 增加好感度
increase_favorite() {
    current=$(read_favorite)
    new=$((current + FAVORITE_INCREMENT))
    if [ $new -gt $FAVORITE_MAX ]; then
        new=$FAVORITE_MAX
    fi
    save_favorite $new
    echo $new
}

# 获取随机对话
get_random_dialogue() {
    if [ -f "$DIALOGUE_FILE" ]; then
        total=$(wc -l < "$DIALOGUE_FILE")
        if [ $total -gt 0 ]; then
            line=$(( (RANDOM % total) + 1 ))
            sed -n "${line}p" "$DIALOGUE_FILE"
        else
            echo "今天心情不错！"
        fi
    else
        echo "你好呀！"
    fi
}

# 绘制好感度进度条
draw_favorite_bar() {
    current=$1
    max=$2
    percentage=$(( (current * 100) / max ))
    bar_length=20
    
    # 计算填充数量
    filled=$(( (percentage * bar_length) / 100 ))
    
    # 构建进度条
    bar=""
    for ((i=0; i<filled; i++)); do
        bar+="█"
    done
    for ((i=filled; i<bar_length; i++)); do
        bar+="░"
    done
    
    echo -e "${YELLOW}好感度: [${GREEN}${bar}${YELLOW}] ${percentage}% (${current}/${max})${NC}"
}

# 显示宠物
show_pet() {
    local dialogue=$(get_random_dialogue)
    local current_favorite=$(read_favorite)
    
    # 清空当前行并向上移动
    echo -ne "\033[2K"
    echo -ne "\033[1A"
    
    # 计算对话气泡宽度
    local dialog_len=${#dialogue}
    local bubble_width=$((dialog_len + 4))
    if [ $bubble_width -lt 10 ]; then
        bubble_width=10
    fi
    
    # 打印对话气泡顶部边框
    echo -ne "${CYAN}"
    echo -n " "
    printf "%${bubble_width}s" | tr ' ' '_'
    echo ""
    
    # 打印对话内容
    echo -n " < "
    echo -e "${PURPLE}${dialogue}${CYAN}"
    for ((i=${#dialogue}+4; i<bubble_width; i++)); do
        echo -n " "
    done
    echo " >"
    
    # 打印对话气泡底部边框
    echo -n " "
    printf "%${bubble_width}s" | tr ' ' '-'
    echo -e "${NC}"
    
    # 打印宠物形象
    echo -e "${GREEN}${PET_ART}${NC}"
    
    # 打印好感度进度条
    draw_favorite_bar $current_favorite $FAVORITE_MAX
    
    # 打印分隔线
    echo ""
    
    PET_VISIBLE=true
    echo "true" > "$STATE_FILE"
}

# 隐藏宠物
hide_pet() {
    # 清除宠物显示区域
    # 宠物形象占6行 + 气泡3行 + 进度条1行 + 分隔线1行 = 约11行
    for ((i=0; i<12; i++)); do
        echo -ne "\033[2K"
        echo -ne "\033[1A"
    done
    echo -ne "\033[2K"
    
    PET_VISIBLE=false
    echo "false" > "$STATE_FILE"
}

# 切换宠物显示状态
toggle_pet() {
    if $PET_VISIBLE; then
        hide_pet
    else
        show_pet
    fi
}

# 命令处理函数
pet_command() {
    case "$1" in
        "show")
            show_pet
            ;;
        "hide")
            hide_pet
            ;;
        "toggle")
            toggle_pet
            ;;
        "status")
            current=$(read_favorite)
            percentage=$(( (current * 100) / FAVORITE_MAX ))
            echo -e "${YELLOW}宠物状态: ${GREEN}${PET_NAME}${NC}"
            echo -e "${YELLOW}好感度: ${GREEN}${current}/${FAVORITE_MAX} (${percentage}%)${NC}"
            if $PET_VISIBLE; then
                echo -e "${YELLOW}显示状态: ${GREEN}已显示${NC}"
            else
                echo -e "${YELLOW}显示状态: ${RED}已隐藏${NC}"
            fi
            ;;
        "love")
            new=$(increase_favorite)
            echo -e "${GREEN}❤ 好感度 +${FAVORITE_INCREMENT}！当前: ${new}/${FAVORITE_MAX}${NC}"
            ;;
        "reset")
            save_favorite $FAVORITE_MIN
            echo -e "${YELLOW}好感度已重置为 ${FAVORITE_MIN}${NC}"
            ;;
        *)
            echo -e "${RED}未知命令: $1${NC}"
            echo "可用命令: show | hide | toggle | status | love | reset"
            ;;
    esac
}

# 命令执行后钩子
post_command_hook() {
    if $PET_VISIBLE && [ "$PET_POST_COMMAND" != "false" ]; then
        # 增加好感度
        increase_favorite
        # 更新宠物显示
        show_pet
    fi
}

# 主入口
if [ "$1" = "init" ]; then
    # 初始化 - 设置环境变量用于追踪状态
    export PET_DIR="$PET_DIR"
    export PET_VISIBLE=false
    export PET_POST_COMMAND=true
    
    # 读取保存的状态
    if [ -f "$STATE_FILE" ]; then
        state=$(cat "$STATE_FILE")
        if [ "$state" = "true" ]; then
            export PET_VISIBLE=true
        fi
    fi
    
    # 设置命令别名
    alias "$SHOW_COMMAND"='pet_command show'
    alias "$HIDE_COMMAND"='pet_command hide'
    
    # 设置PROMPT_COMMAND钩子
    if [ -n "$PROMPT_COMMAND" ]; then
        export PET_OLD_PROMPT_COMMAND="$PROMPT_COMMAND"
    fi
    PROMPT_COMMAND="\"$PET_DIR/pet.sh\" hook; $PET_OLD_PROMPT_COMMAND"
    
    echo -e "${GREEN}Termux Pet 已加载！${NC}"
    echo -e "${YELLOW}使用 '${SHOW_COMMAND}' 显示宠物，'${HIDE_COMMAND}' 隐藏宠物${NC}"
    
elif [ "$1" = "hook" ]; then
    # 钩子调用
    post_command_hook
    
elif [ $# -gt 0 ]; then
    # 命令模式
    pet_command "$1"
    
else
    # 显示帮助
    echo "Termux Pet - 终端宠物交互系统"
    echo ""
    echo "使用方法:"
    echo "  pet.sh init          - 初始化宠物系统"
    echo "  pet.sh show          - 显示宠物"
    echo "  pet.sh hide          - 隐藏宠物"
    echo "  pet.sh toggle        - 切换显示状态"
    echo "  pet.sh status        - 查看状态"
    echo "  pet.sh love          - 手动增加好感度"
    echo "  pet.sh reset         - 重置好感度"
    echo ""
    echo "配置文件: $PET_DIR/pet.conf"
    echo "对话文件: $PET_DIR/dialogues.txt"
fi
