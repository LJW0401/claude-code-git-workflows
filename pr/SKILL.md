---
name: pr
description: 创建 GitHub Pull Request
disable-model-invocation: true
argument-hint: [目标分支(默认自动检测)]
allowed-tools: Bash(git *) Bash(gh *) Read Grep Glob
---

创建一个 GitHub Pull Request。

## 流程

1. 并行执行以下检查：
   - `git status` 查看工作区状态
   - `git diff` 和 `git diff --staged` 查看未提交的更改
   - `git branch --show-current` 获取当前分支
   - 检查远程跟踪状态，判断是否需要推送

2. 获取基准分支（$ARGUMENTS 或仓库默认分支）：
   - `git log $(git_base)..HEAD --oneline` 查看所有待合并提交
   - `git diff $(git_base)...HEAD` 查看完整差异

3. 分析所有提交和变更，草拟：
   - PR 标题：简短（70 字符以内）
   - PR 描述：包含变更摘要和测试计划

4. 如果需要，先推送到远程：`git push -u origin $(git branch --show-current)`

5. 使用 `gh pr create` 创建 PR，格式如下：

```
gh pr create --title "标题" --body "$(cat <<'EOF'
## Summary
<1-3 个要点>

## Test plan
<测试清单>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

6. 返回 PR 链接

## 注意事项

- 确保所有更改已提交再创建 PR
- PR 标题保持简短
- 详细内容放在描述中
