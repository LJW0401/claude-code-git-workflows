---
name: push
description: 推送当前分支到远程仓库
disable-model-invocation: true
argument-hint: [远程名称(默认origin)]
allowed-tools: Bash(git *)
---

将当前分支推送到远程仓库。

## 流程

1. 运行 `git status` 确认没有未提交的更改
2. 运行 `git branch --show-current` 获取当前分支名
3. 运行 `git log --oneline @{u}..HEAD 2>/dev/null || git log --oneline -5` 查看待推送的提交
4. 推送到远程：`git push -u ${ARGUMENTS:-origin} $(git branch --show-current)`
5. 确认推送成功

## 注意事项

- 绝不使用 `--force` 推送，除非用户明确要求
- 如果是 main/master 分支且用户要求强推，发出警告
- 如果有未提交的更改，提醒用户先提交
