#!/data/data/com.termux/files/usr/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

PET_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if [ -f "$PET_DIR/pet.conf" ]; then
    source "$PET_DIR/pet.conf"
else
    PET_NAME="小宠物"
    STATE_FILE="$PET_DIR/.state"
    MOOD_FILE="$PET_DIR/.mood"
    DIALOGUE_FILE="$PET_DIR/dialogues.txt"
    PET_ARTS_FILE="$PET_DIR/pet_arts.txt"
fi

[ -z "$STATE_FILE" ] && STATE_FILE="$PET_DIR/.state"
[ -z "$MOOD_FILE" ] && MOOD_FILE="$PET_DIR/.mood"
[ -z "$DIALOGUE_FILE" ] && DIALOGUE_FILE="$PET_DIR/dialogues.txt"
[ -z "$PET_ARTS_FILE" ] && PET_ARTS_FILE="$PET_DIR/pet_arts.txt"

read_state() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "hidden"
    fi
}

save_state() {
    echo "$1" > "$STATE_FILE"
}

save_mood() {
    echo "$1" > "$MOOD_FILE"
}

read_mood() {
    if [ -f "$MOOD_FILE" ]; then
        cat "$MOOD_FILE"
    else
        echo "normal"
    fi
}

get_pet_art() {
    local mood=$1
    local arts=()

    if [ ! -f "$PET_ARTS_FILE" ]; then
        echo "(^･ω･^)"
        return
    fi

    while IFS= read -r line; do
        if [[ "$line" =~ ^\[.*\]$ ]] && [[ "$line" =~ mood= ]]; then
            local art_mood=$(echo "$line" | sed -n 's/.*\[mood=\([^]]*\)\].*/\1/p')
            if [ "$art_mood" = "$mood" ]; then
                local art=$(echo "$line" | sed 's/^\[mood=[^]]*\]//')
                arts+=("$art")
            fi
        fi
    done < "$PET_ARTS_FILE"

    if [ ${#arts[@]} -eq 0 ]; then
        case "$mood" in
            happy) echo "(^▽^)" ;;
            sad) echo "(´・ω・\`)" ;;
            sleeping) echo "(-ω-)zzz" ;;
            eating) echo "(๑´ڡ\`๑)" ;;
            working) echo "(*´・ω・)-c" ;;
            *) echo "(^･ω･^)" ;;
        esac
    else
        local index=$(($RANDOM % ${#arts[@]}))
        echo "${arts[$index]}"
    fi
}

get_mood() {
    local last_exit_code="${LAST_EXIT_CODE:-0}"
    
    if [ $last_exit_code -eq 0 ]; then
        local rand=$((RANDOM % 10))
        if [ $rand -lt 7 ]; then
            echo "happy"
        elif [ $rand -lt 9 ]; then
            echo "normal"
        else
            echo "working"
        fi
    else
        local rand=$((RANDOM % 10))
        if [ $rand -lt 6 ]; then
            echo "sad"
        elif [ $rand -lt 8 ]; then
            echo "normal"
        else
            echo "sleeping"
        fi
    fi
}

get_mood_dialogue() {
    local mood=$1
    local dialogues=()

    if [ ! -f "$DIALOGUE_FILE" ]; then
        case "$mood" in
            happy) echo "Nice work!" ;;
            normal) echo "OK, got it" ;;
            sad) echo "Don't give up..." ;;
            sleeping) echo "zzZ..." ;;
            eating) echo "Yummy~" ;;
            working) echo "Keep going!" ;;
            *) echo "Hello!" ;;
        esac
        return
    fi

    while IFS= read -r line; do
        if [[ "$line" =~ ^\[.*\]$ ]] && [[ "$line" =~ mood= ]]; then
            local dialogue_mood=$(echo "$line" | sed -n 's/.*\[mood=\([^]]*\)\].*/\1/p')
            if [ "$dialogue_mood" = "$mood" ]; then
                local dialogue=$(echo "$line" | sed 's/^\[mood=[^]]*\]//')
                dialogues+=("$dialogue")
            fi
        fi
    done < "$DIALOGUE_FILE"

    if [ ${#dialogues[@]} -eq 0 ]; then
        case "$mood" in
            happy) echo "Nice work!" ;;
            normal) echo "OK, got it" ;;
            sad) echo "Don't give up..." ;;
            sleeping) echo "zzZ..." ;;
            eating) echo "Yummy~" ;;
            working) echo "Keep going!" ;;
            *) echo "Hello!" ;;
        esac
    else
        local index=$(($RANDOM % ${#dialogues[@]}))
        echo "${dialogues[$index]}"
    fi
}

get_random_dialogue() {
    local mood=$(get_mood)
    get_mood_dialogue "$mood"
}

pet_show() {
    save_state "visible"
    echo -e "${GREEN}宠物已显示${NC}"
}

pet_hide() {
    save_state "hidden"
    echo -e "${YELLOW}宠物已隐藏${NC}"
}

pet_toggle() {
    current=$(read_state)
    if [ "$current" = "visible" ]; then
        pet_hide
    else
        pet_show
    fi
}

pet_status() {
    local state=$(read_state)
    local mood=$(get_mood)
    local art=$(get_pet_art $mood)

    echo -e "${YELLOW}宠物名称: ${GREEN}${PET_NAME}${NC}"
    echo -e "${YELLOW}当前表情: ${GREEN}${art}${NC}"
    echo -e "${YELLOW}心情状态: ${GREEN}${mood}${NC}"
    echo -e "${YELLOW}显示状态: ${GREEN}${state}${NC}"
}

pet_mood() {
    local mood=$1
    if [ -z "$mood" ]; then
        mood=$(get_mood)
    fi
    save_mood "$mood"
    local art=$(get_pet_art "$mood")
    echo -e "${GREEN}心情已设置为: ${CYAN}${mood}${NC}"
    echo -e "表情: ${art}"
}

pet_dialogue() {
    local dialogue=$(get_random_dialogue)
    echo -e "${CYAN}${dialogue}${NC}"
}

case "$1" in
    show) pet_show ;;
    hide) pet_hide ;;
    toggle) pet_toggle ;;
    status) pet_status ;;
    mood) pet_mood "$2" ;;
    dialogue) pet_dialogue ;;
    state) read_state ;;
    art) get_pet_art "$(get_mood)" ;;
    *)
        echo "Pets命令用法:"
        echo "  pets show     - 显示宠物"
        echo "  pets hide     - 隐藏宠物"
        echo "  pets toggle   - 切换显示状态"
        echo "  pets status   - 查看状态"
        echo "  pets mood     - 设置心情 (happy/normal/sad/sleeping/eating/working)"
        echo "  pets dialogue - 随机对话"
        ;;
esac