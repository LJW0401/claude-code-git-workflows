---
name: pr
description: 创建 GitHub Pull Request（后台 agent 执行）
disable-model-invocation: true
argument-hint: [目标分支(默认自动检测)]
allowed-tools: Agent Bash(git status:*) Bash(git branch:*) Bash(git log:*) Bash(git diff:*) Read
---

将创建 PR 的工作交给后台 agent 执行，避免阻塞当前会话。

## 流程

1. 主会话只做最小检查：
   - `git status` 确认工作区干净（有未提交变更则提示用户先 `/commit`，并结束，不启动 agent）
   - `git branch --show-current` 拿到当前分支；若当前在默认分支（main/master），提示用户先切到功能分支并结束
2. 使用 `Agent` 工具在后台（`run_in_background: true`）启动一个 `general-purpose` 子 agent 来完成 PR 创建。prompt 必须自包含，包含：
   - 当前工作目录（绝对路径）
   - 当前分支名
   - 用户提供的目标分支参数 `$ARGUMENTS`（为空则让 agent 自行检测仓库默认分支）
   - PR 描述模板路径：`assets/TEMPLATE.md`（相对当前 skill 目录）
   - 必须执行的步骤（见下方"交给 agent 的指令"）
3. 启动后立即把 agent 的 ID/名称告知用户，并说明会在 agent 完成时收到通知；不要轮询、不要 sleep 等待

## 交给 agent 的指令（写进 prompt）

让后台 agent 严格按下列步骤执行，并在结果中报告 PR URL：

1. 确定基准分支：用户参数优先；否则用 `gh repo view --json defaultBranchRef -q .defaultBranchRef.name` 获取仓库默认分支
2. `git log <base>..HEAD --oneline` 与 `git diff <base>...HEAD` 通读所有待合并提交
3. 检查远程跟踪状态；若本地分支未推送或落后远程，先 `git push -u origin <branch>`
4. 参考 `assets/TEMPLATE.md` 草拟：
   - PR 标题：必须**简短**（≤ 50 字符为佳，单句、不堆从句、≤ 70 字符为硬上限）
   - PR 描述：包含 Summary（1-3 要点）与 Test plan（清单）
5. 使用 `gh pr create` + HEREDOC 创建 PR，body 末尾保留：
   `🤖 Generated with [Claude Code](https://claude.com/claude-code)`
6. 返回 PR URL

## 注意事项

- PR 标题保持简短，详细内容放 body
- 工作区不干净或仍在默认分支时，主会话直接结束，不启动 agent
- 不要强推、不要修改远程已有的 PR，除非用户明确要求
