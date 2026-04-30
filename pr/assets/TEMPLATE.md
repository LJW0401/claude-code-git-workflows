# Pull Request 描述模板

## 基本结构

```
标题：<动词短语>：<目的/原因>

Body：

## Summary
- <要点 1：为什么这么改 / 解决什么问题>
- <要点 2：关键改动或权衡>
- <要点 3（可选）：影响范围 / 后续计划>

## Test plan
- [ ] <验证步骤 1>
- [ ] <验证步骤 2>
- [ ] <边界 / 回归场景>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

- 标题与 body 之间通过 `gh pr create --title ... --body ...` 分别传入
- body 末尾的 `🤖 Generated with [Claude Code](https://claude.com/claude-code)` 必须保留，且单独成行
- 该模板严格对应 `SKILL.md` 第 5 步的 body 结构，请勿增删一级标题

## 标题书写规则

- 使用中文，单行 ≤ 70 字符，结尾不加句号
- 聚焦"为什么这么改"或"带来了什么能力"，而不是罗列文件
- 多个提交合并到一个 PR 时，用一句话概括主旨；细节放 Summary
- 风格与 commit 标题一致，可参考 commit 模板中的动词表

| 类型     | 推荐写法                          |
| -------- | --------------------------------- |
| 新功能   | `新增 …`、`支持 …`、`添加 …`      |
| 改进现有 | `完善 …`、`优化 …`、`让 … 能 …`   |
| 修复     | `修复 …`、`避免 …`、`防止 …`      |
| 重构     | `重构 …`、`将 … 改为 …`           |
| 移除     | `移除 …`、`废弃 …`、`禁用 …`      |

## Summary 写法指引

- 用 1–3 个要点说明这次 PR 的"为什么"和"关键改动"
- 每条要点一行，避免逐文件 diff 复述
- 如果涉及破坏性变更、迁移成本或行为差异，必须显式列出
- 如果 PR 包含多个独立提交，要点的粒度应略高于单个 commit 标题

## Test plan 写法指引

- 用 markdown checkbox 列出验证步骤，便于审查者勾选
- 优先列"端到端可观察"的步骤，例如执行某命令、查看某输出
- 包含正常路径 + 至少一个边界 / 回归场景
- 纯文档或注释类改动可写"无需运行时验证，已人工通读"

## 完整正例

### 正例 1：基于 `bcda121` 改写（行为修复类）

标题：

```
merge 完成后自动同步本地仓库并切到合入分支，避免后续操作停留在过期 head
```

Body：

```
## Summary
- /merge 流程在 PR 合并后会停留在原本地分支，导致后续 git 操作基于过期 HEAD
- 合并成功后追加 `git fetch` 与 `git checkout <base>`，确保本地状态与远程一致
- 顺带在文档里说明该副作用，方便用户预期

## Test plan
- [ ] 在 feature 分支执行 /merge，确认 PR 合并后当前分支自动切到 base
- [ ] 合并失败时不应切换分支，保持原工作区
- [ ] 远程 base 落后于本地时，验证 fetch 能正确更新

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### 正例 2：基于 `bb5f37f` + `fefba38` 改写（功能增强类）

标题：

```
完善 /release：支持 .release.md 模板与构建附件上传
```

Body：

```
## Summary
- 新增 `.release.md` 模板能力，release notes 由模板渲染而来，统一团队风格
- 调整流程为"先推 tag 再构建"，避免构建产物里写入旧版本号
- 失败时回滚已推送的 tag，避免远端残留半成品 release

## Test plan
- [ ] 仓库存在 `.release.md` 时，生成的 notes 与模板一致
- [ ] 缺少模板时回退到旧的自动汇总逻辑
- [ ] 故意让构建失败，确认对应 tag 被远程删除
- [ ] 上传 dist/ 下多个附件，gh release 页面均可见

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## 反例（避免）

- ❌ 标题写成 `update pr skill` 或 `fix bug`：无信息量，且非中文
- ❌ 标题罗列文件名，如 `修改 SKILL.md 和 TEMPLATE.md`：只说改了什么、没说为什么
- ❌ Summary 写成 `见 commits`、`如标题`：没有为审查者提供任何额外上下文
- ❌ Test plan 写 `已自测通过`：没有可复现的步骤，等于没写
- ❌ 删除或改写末尾的 `🤖 Generated with [Claude Code]` 行
- ❌ 一个 PR 塞入多个无关主题（例如同时改 /merge 与 /release 的不相关逻辑）——拆分成独立 PR
