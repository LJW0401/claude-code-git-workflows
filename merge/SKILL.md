---
name: merge
description: 合并 GitHub PR
disable-model-invocation: true
argument-hint: [PR 编号或 URL]
allowed-tools: Bash(gh *), Bash(git *)
---

合并 GitHub 上的 Pull Request。

## 流程

1. 如果用户提供了参数 `$ARGUMENTS`，解析 PR 编号或 URL；否则运行 `gh pr list` 列出当前仓库的 PR，提示用户选择
2. 运行 `gh pr view <PR编号> --json title,body,state,mergeable,mergeStateStatus,reviewDecision,statusCheckRollup,headRefName,baseRefName,author,number` 查看 PR 详情
3. 检查 PR 状态：
   - 如果 PR 已关闭或已合并，告知用户
   - 如果有未通过的 CI 检查，列出失败项并提醒用户
   - 如果需要 review 但尚未通过，提醒用户
4. 向用户确认合并信息：PR 标题、源分支 → 目标分支、合并方式
5. 执行合并：`gh pr merge <PR编号> --merge`（**强制使用 merge commit**）
6. 合并完成后运行 `gh pr view <PR编号> --json state,mergedAt,mergedBy` 确认结果
7. 同步本地与远程，并切换到合入的目标分支更新至最新提交：
   - `git fetch --all --prune`
   - `git checkout <baseRefName>`（PR 详情里的 `baseRefName`，即被合入的分支）
   - `git pull --ff-only`
   - 如本地仍存在已合并的源分支（`headRefName`），告知用户可清理，但不要自动删除

## 合并方式规则

- **统一使用 merge commit**（`--merge`），不使用 squash 和 rebase
- 原因：保留 PR 的完整提交结构和分支拓扑，便于后续回溯每一次改动的上下文与作者
- 即使用户口头要求 squash / rebase，也先说明本规则并劝阻；如用户在了解后仍坚持，需要明确二次确认才可使用 `--squash` / `--rebase`

## 注意事项

- 合并前务必向用户展示 PR 信息并确认
- 不要使用 `--admin` 绕过保护规则，除非用户明确要求
- 默认不删除源分支，如需删除加 `--delete-branch`，需用户确认
- 如果合并失败（如存在冲突），告知用户原因并建议解决方案
