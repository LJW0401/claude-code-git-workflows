# 提交信息模板

## 基本结构

```
<动词短语>：<目的/原因>，<额外说明（可选）>

Co-Authored-By: <Model> <email>
```

- 标题行使用中文，单行 ≤ 72 字符，结尾不加句号
- 聚焦于"为什么这么改"，而不是逐字罗列"改了哪些文件"
- 多动作时用一句话概括主旨；细节放正文段落，与标题之间空一行
- 末尾根据当前模型附加 `Co-Authored-By` trailer（详见 SKILL.md）

## 常用动词参考

| 类型     | 推荐写法                          |
| -------- | --------------------------------- |
| 新功能   | `新增 …`、`支持 …`、`添加 …`      |
| 改进现有 | `完善 …`、`优化 …`、`让 … 能 …`   |
| 修复     | `修复 …`、`避免 …`、`防止 …`      |
| 重构     | `重构 …`、`将 … 改为 …`           |
| 移除     | `移除 …`、`废弃 …`、`禁用 …`      |
| 文档     | `补充 … 文档`、`说明 …`           |

## 示例（取自本仓库历史）

仅标题：

```
让 /commit 按当前模型写入正确的协作者签名

Co-Authored-By: Claude <noreply@anthropic.com>
```

带原因说明：

```
merge 完成后自动同步本地仓库并切到合入分支，避免后续操作仍停留在过期 head

Co-Authored-By: Claude <noreply@anthropic.com>
```

带强制约束的原因：

```
merge skill 强制使用 merge commit，禁用 squash/rebase 以保留分支拓扑便于回溯

Co-Authored-By: Claude <noreply@anthropic.com>
```

带正文段落（多点说明时使用）：

```
完善 /release 命令：支持构建附件上传，先推 tag 再构建确保版本号正确

- tag 推送前置，避免构建产物里写入旧版本号
- 上传步骤改为读取 dist/ 下的产物列表
- 失败时回滚已推送的 tag

Co-Authored-By: Claude <noreply@anthropic.com>
```

## 反例（避免）

- ❌ `update files`（无信息量、非中文）
- ❌ `修改了 a.py 和 b.py`（只描述"改了什么"，没说"为什么"）
- ❌ `fix bug`（过于笼统，未指明哪个 bug、为何出现）
- ❌ 一次提交里塞入多个无关变更——拆成多个提交
