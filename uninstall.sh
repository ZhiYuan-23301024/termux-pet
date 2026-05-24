#!/data/data/com.termux/files/usr/bin/bash

# Termux Pet 卸载脚本

# 目标目录
TARGET_DIR="$HOME/.termux-pet"

echo "开始卸载 Termux Pet..."

# 移除目标目录
if [ -d "$TARGET_DIR" ]; then
    rm -rf "$TARGET_DIR"
    echo "已删除: $TARGET_DIR"
fi

# 从 .bashrc 移除配置
if [ -f "$HOME/.bashrc" ]; then
    sed -i '/PET_DIR=/d' "$HOME/.bashrc"
    sed -i '/source.*termux-pet.*pet.sh/d' "$HOME/.bashrc"
    echo "已清理 .bashrc"
fi

# 从 .zshrc 移除配置
if [ -f "$HOME/.zshrc" ]; then
    sed -i '/PET_DIR=/d' "$HOME/.zshrc"
    sed -i '/source.*termux-pet.*pet.sh/d' "$HOME/.zshrc"
    echo "已清理 .zshrc"
fi

# 移除残留文件（如果目录删除失败）
rm -rf "$TARGET_DIR"

echo ""
echo "卸载完成！"
echo "请重启终端使更改生效。"
