---
name: commit
description: 暂存并提交当前更改（后台 agent 执行）
disable-model-invocation: true
argument-hint: [提交信息(可选)]
allowed-tools: Agent Bash(git status:*) Bash(git diff:*) Bash(git log:*) Read
---

将提交工作交给后台 agent 执行，避免阻塞当前会话。

## 流程

1. 运行 `git status` 确认当前确实有变更；若工作区干净，直接告知用户并结束，不要启动 agent
2. 使用 `Agent` 工具在后台（`run_in_background: true`）启动一个 `general-purpose` 子 agent 来完成提交，prompt 必须自包含，包含以下要点：
   - 当前工作目录（绝对路径）
   - 用户提供的提交信息参数 `$ARGUMENTS`（若为空则说明由 agent 自行根据 diff 草拟）
   - 必须执行的步骤（见下方"交给 agent 的指令"）
   - 提交信息模板路径：`assets/TEMPLATE.md`（相对当前 skill 目录）
3. 启动后立即把 agent 的 ID/名称告知用户，并说明会在 agent 完成时收到通知；不要轮询、不要 sleep 等待

## 交给 agent 的指令（写进 prompt）

让后台 agent 严格按下列步骤执行，并在结果中报告最终的 commit hash 与 `git status` 输出：

1. `git status` 查看变更
2. `git diff` 与 `git diff --staged` 查看具体内容
3. `git log --oneline -5` 参考最近提交风格
4. 分析变更，参考 `assets/TEMPLATE.md` 草拟中文提交信息：标题必须简短（建议 ≤ 50 字，单句、不堆砌从句），需要展开的细节放到 body；聚焦"为什么"。若用户已提供参数，则直接采用用户的信息
5. 按文件名暂存相关变更，禁止 `git add -A` / `git add .`，禁止提交 `.env`、`credentials.json` 等可能含密钥的文件
6. 使用 HEREDOC 创建提交，根据当前模型附加 trailer：
   - Claude：`Co-Authored-By: Claude <noreply@anthropic.com>`
   - Codex：`Co-Authored-By: Codex <noreply@openai.com>`
   - 其它模型不附加
7. 提交后运行 `git status` 确认；若 pre-commit hook 失败，修复问题后创建新提交（不要 amend）
8. 不要推送远程，除非用户明确要求

## 注意事项

- 提交信息使用中文
- 没有任何变更时不要启动 agent，也不要创建空提交
- 主会话只负责检查与派发，真正的暂存与提交都在后台 agent 中完成
