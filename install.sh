#!/bin/bash
# Claude Code Git Workflows - 安装脚本
# 自动在 ~/.claude/skills/ 下创建符号链接

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$(dirname "$SCRIPT_DIR")"
REPO_NAME="$(basename "$SCRIPT_DIR")"

# 查找所有包含 SKILL.md 的子目录
found=0
for skill_dir in "$SCRIPT_DIR"/*/; do
    [ -f "$skill_dir/SKILL.md" ] || continue
    skill_name="$(basename "$skill_dir")"
    link_path="$SKILLS_DIR/$skill_name"

    if [ -L "$link_path" ]; then
        echo "已存在: $skill_name -> $(readlink "$link_path")"
    elif [ -e "$link_path" ]; then
        echo "跳过: $skill_name (目录已存在且非符号链接)"
    else
        ln -s "$REPO_NAME/$skill_name" "$link_path"
        echo "已创建: $skill_name -> $REPO_NAME/$skill_name"
        found=$((found + 1))
    fi
done

if [ $found -eq 0 ]; then
    echo "没有新的符号链接需要创建。"
else
    echo "完成，共创建 $found 个符号链接。请执行 /reload-plugins 或重启 Claude Code。"
fi
