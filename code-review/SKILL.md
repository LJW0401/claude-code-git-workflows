---
name: code-review
description: 审查当前分支与主分支之间的差异（后台 agent 执行）
disable-model-invocation: true
argument-hint: "[基准分支(默认: 仓库默认分支)]"
allowed-tools: Agent Bash(git status:*) Bash(git branch:*) Bash(git log:*) Bash(git diff:*) Bash(gh repo view:*) Read
---

将代码审查工作交给后台 agent 执行，审查范围为「当前分支 vs 主分支」的差异，避免阻塞当前会话。

## 流程

1. 主会话只做最小检查与范围确定：
   - `git branch --show-current` 拿到当前分支；若已在主分支（main/master 或仓库默认分支），告知用户没有可审查差异并结束，不启动 agent
   - 确定基准分支：
     - 用户传入 `$ARGUMENTS` 时直接作为基准分支
     - 否则用 `gh repo view --json defaultBranchRef -q .defaultBranchRef.name` 拿到仓库默认分支
   - `git diff <base>...HEAD --stat` 简单确认是否存在差异；若 diff 为空（当前分支与基准完全一致），告知用户并结束
2. 使用 `Agent` 工具在后台（`run_in_background: true`）启动一个 `general-purpose` 子 agent 完成审查。prompt 必须自包含，包含：
   - 当前工作目录（绝对路径）
   - 当前分支名与基准分支名
   - 必须执行的步骤（见下方"交给 agent 的指令"）
3. 启动后立即把 agent 的 ID/名称告知用户，并说明会在 agent 完成时收到通知；不要轮询、不要 sleep 等待

## 交给 agent 的指令（写进 prompt）

让后台 agent 严格按下列步骤执行，并在结果中输出结构化审查报告：

1. 用 `git log <base>..HEAD --oneline` 看提交脉络，再用 `git diff <base>...HEAD` 通读所有变更
2. 对照下列维度逐项审查，**只报告确有问题的地方，不要堆砌"看起来不错"**：
   - **正确性**：逻辑 bug、边界条件、并发/异步隐患、错误处理缺失
   - **安全性**：注入、越权、密钥/敏感信息泄漏、依赖风险
   - **可维护性**：命名、职责单一、重复代码、过度抽象、死代码
   - **风格一致性**：是否符合周围代码与项目既有约定（必要时读相邻文件确认）
   - **测试覆盖**：关键路径是否有对应测试，是否缺失回归用例
3. 每条发现按以下结构给出：
   - **严重程度**：`blocker` / `major` / `minor` / `nit`
   - **位置**：`file:line` 或 `file:line-range`
   - **问题**：一句话说清楚错在哪
   - **建议**：可落地的修改方向（不必给完整 patch）
4. 报告结尾给出**总体结论**：可合并 / 需修改后再审 / 需重做；并附一句话理由
5. 不要修改代码、不要创建文件、不要发起 commit/push；只做只读审查

## 注意事项

- 主会话不输出审查意见，只负责派发；意见全部由后台 agent 产出
- 不要把整个 diff 复述出来，聚焦"问题与建议"
- 当前分支即为主分支或与基准无差异时，直接结束，不启动 agent
