---
name: commit
description: 暂存并提交当前更改
disable-model-invocation: true
argument-hint: [提交信息(可选)]
allowed-tools: Bash(git *) Read Grep Glob
---

提交当前工作区的更改。

## 流程

1. 运行 `git status` 查看当前变更状态
2. 运行 `git diff` 和 `git diff --staged` 查看具体更改内容
3. 运行 `git log --oneline -5` 查看最近的提交风格
4. 分析所有变更，草拟一条简洁的中文提交信息（1-2 句话，聚焦于"为什么"而非"改了什么"）
5. 如果用户提供了参数 `$ARGUMENTS`，则使用用户提供的信息作为提交信息
6. 将相关文件添加到暂存区（优先按文件名添加，避免 `git add -A`）
7. 不要提交可能包含密钥的文件（.env、credentials.json 等）
8. 使用 HEREDOC 格式创建提交，提交信息末尾按当前模型附加对应的 `Co-Authored-By` trailer：
   - 如果当前模型是 Claude，则附加：`Co-Authored-By: Claude <noreply@anthropic.com>`
   - 如果当前模型是 Codex，则附加：`Co-Authored-By: Codex <noreply@openai.com>`
   - 其他模型不附加额外 trailer
9. 提交后运行 `git status` 确认成功

## 注意事项

- 提交信息使用中文
- 如果没有任何更改，不要创建空提交
- 如果 pre-commit hook 失败，修复问题后创建新提交（不要 amend）
- 不要推送到远程仓库，除非用户明确要求
