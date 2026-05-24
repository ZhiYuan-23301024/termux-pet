#!/data/data/com.termux/files/usr/bin/bash

TARGET_DIR="$HOME/.termux-pet"

echo "开始卸载 Termux Pet (Starship版)..."

rm -rf "$TARGET_DIR"

sed -i '/PET_DIR=/d' "$HOME/.bashrc"
sed -i '/source.*termux-pet.*pet_state.sh/d' "$HOME/.bashrc"

if [ -f "$HOME/.zshrc" ]; then
    sed -i '/PET_DIR=/d' "$HOME/.zshrc"
    sed -i '/source.*termux-pet.*pet_state.sh/d' "$HOME/.zshrc"
fi

if [ -f "$HOME/.config/starship.toml" ]; then
    sed -i '/\[custom.petshow\]/d' "$HOME/.config/starship.toml"
    sed -i '/command = "~\/.termux-pet\/pet_prompt.sh"/d' "$HOME/.config/starship.toml"
    sed -i '/when = "test -f ~\/.termux-pet\/pet_state.sh"/d' "$HOME/.config/starship.toml"
    sed -i '/format = "\[ \$output \]"/d' "$HOME/.config/starship.toml"
    sed -i '/style = "bold green"/d' "$HOME/.config/starship.toml"
fi

rm -rf "$TARGET_DIR"

echo ""
echo "卸载完成！"
echo "请重启终端使更改生效。"