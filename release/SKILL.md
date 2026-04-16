---
name: release
description: 创建 Git tag 并发布 GitHub Release
disable-model-invocation: true
argument-hint: [版本号，如 v1.0.0]
allowed-tools: Bash(git *) Bash(gh *)
---

创建语义化版本 tag 并发布 GitHub Release。

## 流程

1. 运行 `git status` 确认工作区干净，没有未提交的更改
2. 运行 `git tag --sort=-v:refname | head -10` 查看最近的版本标签
3. 确定版本号：
   - 如果用户提供了 `$ARGUMENTS`，使用该版本号
   - 否则根据最近的 tag 提示用户选择（patch/minor/major 递增）
   - 版本号必须符合语义化版本格式：`vMAJOR.MINOR.PATCH`（如 `v1.2.3`）
   - 如果用户输入的版本号没有 `v` 前缀，自动补上
4. 运行 `git log $(git tag --sort=-v:refname | head -1)..HEAD --oneline 2>/dev/null || git log --oneline -20` 获取自上次 release 以来的提交记录
5. 基于提交记录生成中文 release notes，按类型分类：
   - 新功能（feat）
   - 修复（fix）
   - 其他改进
6. 向用户确认：版本号、release notes 内容
7. 创建 tag 并推送：
   ```
   git tag -a <版本号> -m "Release <版本号>"
   git push origin <版本号>
   ```
8. 使用 `gh release create` 发布 GitHub Release：
   ```
   gh release create <版本号> --title "Release <版本号>" --notes "$(cat <<'EOF'
   <release notes>
   EOF
   )"
   ```
9. 运行 `gh release view <版本号>` 确认发布成功，返回 release 链接

## 注意事项

- 发布前务必向用户展示版本号和 release notes 并确认
- 如果该版本号的 tag 已存在，告知用户并停止操作
- 不要使用 `--force` 覆盖已有 tag
- 默认不标记为 prerelease，如用户要求则加 `--prerelease`
- 默认不标记为 latest，由 GitHub 自动判断；如用户要求可加 `--latest`
