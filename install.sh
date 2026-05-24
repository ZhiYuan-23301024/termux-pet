#!/data/data/com.termux/files/usr/bin/bash

# Termux Pet 安装脚本

# 获取脚本所在目录
PET_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# 目标安装目录
TARGET_DIR="$HOME/.termux-pet"

# 安装函数
install_pet() {
    echo "开始安装 Termux Pet..."
    
    # 创建目标目录
    mkdir -p "$TARGET_DIR"
    
    # 复制文件
    cp "$PET_DIR/pet.sh" "$TARGET_DIR/"
    cp "$PET_DIR/pet.conf" "$TARGET_DIR/"
    cp "$PET_DIR/dialogues.txt" "$TARGET_DIR/"
    
    # 设置执行权限
    chmod +x "$TARGET_DIR/pet.sh"
    
    # 更新配置文件中的路径
    sed -i "s|PET_DIR=.*|PET_DIR=\"$TARGET_DIR\"|" "$TARGET_DIR/pet.conf"
    
    # 设置环境变量
    echo "export PET_DIR=\"$TARGET_DIR\"" >> "$HOME/.bashrc"
    echo "source \"$TARGET_DIR/pet.sh\" init" >> "$HOME/.bashrc"
    
    # 为 zsh 用户设置
    if [ -f "$HOME/.zshrc" ]; then
        echo "export PET_DIR=\"$TARGET_DIR\"" >> "$HOME/.zshrc"
        echo "source \"$TARGET_DIR/pet.sh\" init" >> "$HOME/.zshrc"
    fi
    
    echo ""
    echo "安装完成！"
    echo ""
    echo "使用方法:"
    echo "  重启终端或执行: source ~/.bashrc"
    echo "  使用 'petshow' 显示宠物"
    echo "  使用 'pethide' 隐藏宠物"
    echo ""
    echo "配置文件位置: $TARGET_DIR/pet.conf"
    echo "对话文件位置: $TARGET_DIR/dialogues.txt"
}

# 卸载函数 (供参考)
uninstall_pet() {
    echo "开始卸载 Termux Pet..."
    
    # 移除目标目录
    rm -rf "$TARGET_DIR"
    
    # 从 .bashrc 移除配置
    sed -i '/PET_DIR=/d' "$HOME/.bashrc"
    sed -i '/source.*termux-pet.*pet.sh/d' "$HOME/.bashrc"
    
    # 从 .zshrc 移除配置
    if [ -f "$HOME/.zshrc" ]; then
        sed -i '/PET_DIR=/d' "$HOME/.zshrc"
        sed -i '/source.*termux-pet.*pet.sh/d' "$HOME/.zshrc"
    fi
    
    echo "卸载完成！"
}

# 显示帮助
show_help() {
    echo "Termux Pet 安装脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 install   - 安装宠物系统"
    echo "  $0 uninstall - 卸载宠物系统"
    echo "  $0 help      - 显示此帮助"
}

# 解析参数
case "$1" in
    "install")
        install_pet
        ;;
    "uninstall")
        uninstall_pet
        ;;
    "help")
        show_help
        ;;
    *)
        show_help
        ;;
esac
