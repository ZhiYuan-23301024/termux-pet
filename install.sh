#!/data/data/com.termux/files/usr/bin/bash

PET_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TARGET_DIR="$HOME/.termux-pet"

install_pet() {
    echo "开始安装 Termux Pet (Starship版)..."

    mkdir -p "$TARGET_DIR"

    cp "$PET_DIR/pet_state.sh" "$TARGET_DIR/"
    cp "$PET_DIR/pet_prompt.sh" "$TARGET_DIR/"
    cp "$PET_DIR/pet_arts.txt" "$TARGET_DIR/"
    cp "$PET_DIR/pet.conf" "$TARGET_DIR/"
    cp "$PET_DIR/dialogues.txt" "$TARGET_DIR/"

    chmod +x "$TARGET_DIR/pet_state.sh"
    chmod +x "$TARGET_DIR/pet_prompt.sh"

    sed -i "s|PET_DIR=.*|PET_DIR=\"$TARGET_DIR\"|" "$TARGET_DIR/pet.conf"

    PET_CONFIG_LINE="export PET_DIR=\"$TARGET_DIR\""
    ALIAS_LINE="source \"$TARGET_DIR/pet_state.sh\""

    if ! grep -q "$PET_CONFIG_LINE" "$HOME/.bashrc" 2>/dev/null; then
        echo "$PET_CONFIG_LINE" >> "$HOME/.bashrc"
    fi
    if ! grep -q "$ALIAS_LINE" "$HOME/.bashrc" 2>/dev/null; then
        echo "$ALIAS_LINE" >> "$HOME/.bashrc"
    fi

    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "$PET_CONFIG_LINE" "$HOME/.zshrc" 2>/dev/null; then
            echo "$PET_CONFIG_LINE" >> "$HOME/.zshrc"
        fi
        if ! grep -q "$ALIAS_LINE" "$HOME/.zshrc" 2>/dev/null; then
            echo "$ALIAS_LINE" >> "$HOME/.zshrc"
        fi
    fi

    mkdir -p "$HOME/.config"
    if [ -d "$HOME/.config/starship" ]; then
        if [ -f "$HOME/.config/starship.toml" ]; then
            if ! grep -q "\[custom.petshow\]" "$HOME/.config/starship.toml" 2>/dev/null; then
                echo "" >> "$HOME/.config/starship.toml"
                echo "[custom.petshow]" >> "$HOME/.config/starship.toml"
                echo 'command = "~/.termux-pet/pet_prompt.sh"' >> "$HOME/.config/starship.toml"
                echo 'when = "test -f ~/.termux-pet/pet_state.sh"' >> "$HOME/.config/starship.toml"
                echo 'format = "[ $output ]"' >> "$HOME/.config/starship.toml"
                echo 'style = "bold green"' >> "$HOME/.config/starship.toml"
            fi
        else
            cp "$PET_DIR/starship_pet.toml" "$HOME/.config/starship.toml"
        fi
    else
        mkdir -p "$HOME/.config/starship"
        cp "$PET_DIR/starship_pet.toml" "$HOME/.config/starship.toml"
    fi

    echo ""
    echo "安装完成！"
    echo ""
    echo "下一步操作:"
    echo "1. 安装 Starship (如果没有安装):"
    echo "   curl -sS https://starship.rs/install.sh | sh"
    echo ""
    echo "2. 确保 ~/.bashrc 或 ~/.zshrc 中有:"
    echo "   eval \"\$(starship init bash)\""
    echo ""
    echo "3. 重启终端或执行: source ~/.bashrc"
    echo ""
    echo "宠物命令:"
    echo "  pets show     - 显示宠物"
    echo "  pets hide     - 隐藏宠物"
    echo "  pets toggle   - 切换显示状态"
    echo "  pets status   - 查看状态"
    echo "  pets mood     - 设置心情"
    echo "  pets dialogue - 随机对话"
    echo ""
}

uninstall_pet() {
    echo "开始卸载 Termux Pet..."

    rm -rf "$TARGET_DIR"

    sed -i '/PET_DIR=/d' "$HOME/.bashrc"
    sed -i '/source.*termux-pet.*pet_state.sh/d' "$HOME/.bashrc"

    if [ -f "$HOME/.zshrc" ]; then
        sed -i '/PET_DIR=/d' "$HOME/.zshrc"
        sed -i '/source.*termux-pet.*pet_state.sh/d' "$HOME/.zshrc"
    fi

    if [ -f "$HOME/.config/starship.toml" ]; then
        sed -i '/\[\[ Petshow \]\]/d' "$HOME/.config/starship.toml"
        sed -i '/command = "~\/.termux-pet\/pet_prompt.sh"/d' "$HOME/.config/starship.toml"
        sed -i '/when = "test -f ~\/.termux-pet\/pet_state.sh"/d' "$HOME/.config/starship.toml"
        sed -i '/format = "\[ \$output \](\$style)"/d' "$HOME/.config/starship.toml"
        sed -i '/style = "bold green"/d' "$HOME/.config/starship.toml"
    fi

    echo "卸载完成！"
}

show_help() {
    echo "Termux Pet (Starship版) 安装脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 install   - 安装宠物系统"
    echo "  $0 uninstall - 卸载宠物系统"
    echo "  $0 help      - 显示此帮助"
}

case "$1" in
    install) install_pet ;;
    uninstall) uninstall_pet ;;
    help) show_help ;;
    *) show_help ;;
esac