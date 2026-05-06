---
name: push
description: 推送当前分支到远程仓库（后台 agent 执行）
disable-model-invocation: true
argument-hint: "[远程名称(默认origin)]"
allowed-tools: Agent Bash(git status:*) Bash(git branch:*) Bash(git log:*)
---

将推送工作交给后台 agent 执行，避免阻塞当前会话。

## 流程

1. 主会话只做最小检查：
   - `git status` 确认工作区干净；如有未提交变更，提示用户先 `/commit`，结束，不启动 agent
   - `git branch --show-current` 拿到当前分支
   - `git log --oneline @{u}..HEAD 2>/dev/null || git log --oneline -5` 看是否有待推送的提交；若与远程一致且无新增提交，告知用户无需 push 并结束
2. 使用 `Agent` 工具在后台（`run_in_background: true`）启动一个 `general-purpose` 子 agent 完成推送。prompt 必须自包含，包含：
   - 当前工作目录（绝对路径）
   - 当前分支名
   - 远程名（用户参数 `$ARGUMENTS`，默认 `origin`）
   - 必须执行的步骤（见下方"交给 agent 的指令"）
3. 启动后立即把 agent 的 ID/名称告知用户，并说明会在 agent 完成时收到通知；不要轮询、不要 sleep 等待

## 交给 agent 的指令（写进 prompt）

让后台 agent 严格按下列步骤执行，并在结果中报告推送结果（远程分支名、commit 范围、是否新建上游）：

1. `git status` 再次确认工作区干净
2. `git branch --show-current` 确认分支
3. `git log --oneline @{u}..HEAD 2>/dev/null || git log --oneline -5` 查看待推送的提交
4. 执行 `git push -u <remote> <branch>`：
   - 绝不使用 `--force` / `--force-with-lease`，除非主会话在 prompt 中显式声明用户已授权
   - 不要跳过 hook（`--no-verify`）
5. 推送后用 `git status` 与 `git log --oneline -1` 确认成功

## 注意事项

- 工作区不干净时主会话直接结束，不启动 agent
- 强推必须由用户在主会话明确授权后再传递给 agent；默认行为永远是普通 push
- main/master 分支推送前若发现是强推请求，先在主会话警告并等待确认，不要直接派发
