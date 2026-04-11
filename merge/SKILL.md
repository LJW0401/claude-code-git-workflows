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
5. 执行合并：`gh pr merge <PR编号> --merge`（默认使用 merge commit）
   - 如果用户要求 squash：`gh pr merge <PR编号> --squash`
   - 如果用户要求 rebase：`gh pr merge <PR编号> --rebase`
6. 合并完成后运行 `gh pr view <PR编号> --json state,mergedAt,mergedBy` 确认结果

## 注意事项

- 合并前务必向用户展示 PR 信息并确认
- 不要使用 `--admin` 绕过保护规则，除非用户明确要求
- 默认不删除源分支，如需删除加 `--delete-branch`，需用户确认
- 如果合并失败（如存在冲突），告知用户原因并建议解决方案
