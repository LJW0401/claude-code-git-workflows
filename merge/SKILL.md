---
name: merge
description: 合并分支到当前分支
disable-model-invocation: true
argument-hint: [要合并的分支名]
allowed-tools: Bash(git *)
---

将指定分支合并到当前分支。

## 流程

1. 运行 `git status` 确认工作区干净（无未提交的更改）
2. 运行 `git branch --show-current` 获取当前分支名
3. 运行 `git branch -a` 查看可用分支
4. 如果用户提供了参数 `$ARGUMENTS`，则合并该分支；否则提示用户指定分支
5. 运行 `git fetch origin` 确保远程分支是最新的
6. 执行合并：`git merge $ARGUMENTS`
7. 如果出现冲突：
   - 列出冲突文件：`git diff --name-only --diff-filter=U`
   - 逐个读取冲突文件，分析并解决冲突
   - 解决后暂存：`git add <文件>`
   - 创建合并提交
8. 合并完成后运行 `git log --oneline -5` 确认结果

## 注意事项

- 如果工作区有未提交的更改，提醒用户先提交或暂存（stash）
- 遇到冲突时，优先分析双方意图再解决，不要盲目选择一方
- 不要使用 `--force` 或 `--strategy-option theirs/ours` 除非用户明确要求
- 合并提交信息使用中文
