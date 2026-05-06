# Git Workflows - Claude Code Skills

Claude Code 自定义斜杠命令，用于快速执行 Git 工作流。

## 包含的命令

| 命令 | 用途 | 示例 |
|------|------|------|
| `/commit` | 暂存并提交更改 | `/commit 修复登录验证逻辑` 或 `/commit`（自动生成提交信息） |
| `/push` | 推送当前分支到远程 | `/push` 或 `/push upstream` |
| `/merge` | 合并分支到当前分支 | `/merge develop` 或 `/merge origin/feature-xxx` |
| `/pr` | 创建 GitHub PR（后台 agent 执行） | `/pr` 或 `/pr main`（指定目标分支） |
| `/code-review` | 审查当前分支 vs 主分支差异（后台 agent 执行） | `/code-review` 或 `/code-review develop`（指定基准分支） |
| `/release` | 创建发布 tag 与 release notes | `/release v1.2.0` |

## 安装

### 1. 克隆仓库

将本仓库克隆到 `~/.claude/skills/` 目录下：

```bash
git clone https://github.com/LJW0401/claude-code-git-workflows.git ~/.claude/skills/git-workflows
```

### 2. 创建符号链接

Claude Code 只扫描 `~/.claude/skills/<name>/SKILL.md` 一层目录，嵌套在子仓库中的 skill 无法被直接识别。为每个子目录手动创建一条符号链接即可：

```bash
cd ~/.claude/skills
for skill in commit push merge pr code-review release; do
  ln -sfn "git-workflows/$skill" "$skill"
done
```

后续新增 skill 后，把名字加入循环再跑一次即可。

完成后目录结构如下：

```
~/.claude/skills/
├── commit       -> git-workflows/commit
├── push         -> git-workflows/push
├── merge        -> git-workflows/merge
├── pr           -> git-workflows/pr
├── code-review  -> git-workflows/code-review
├── release      -> git-workflows/release
└── git-workflows/          # 仓库本体
    ├── commit/SKILL.md
    ├── push/SKILL.md
    ├── merge/SKILL.md
    ├── pr/SKILL.md
    ├── code-review/SKILL.md
    └── release/SKILL.md
```

### 3. 重新加载

在 Claude Code 中执行 `/reload-plugins` 或重启会话即可识别新命令。

## 特性

- 提交信息默认使用中文，标题简短（≤ 50 字），细节进 body
- 自动附加 `Co-Authored-By` 签名（Claude / Codex / 其它模型自填厂商邮箱）
- 安全检查：不会误提交密钥文件、不会强制推送
- 仅手动调用触发，不会被 Claude 自动执行
- 耗时操作（`/pr`、`/code-review`）派发到后台 agent 执行，不阻塞主会话
