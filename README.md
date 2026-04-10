# Git Workflows - Claude Code Skills

Claude Code 自定义斜杠命令，用于快速执行 Git 工作流。

## 包含的命令

| 命令 | 用途 | 示例 |
|------|------|------|
| `/commit` | 暂存并提交更改 | `/commit 修复登录验证逻辑` 或 `/commit`（自动生成提交信息） |
| `/push` | 推送当前分支到远程 | `/push` 或 `/push upstream` |
| `/merge` | 合并分支到当前分支 | `/merge develop` 或 `/merge origin/feature-xxx` |
| `/pr` | 创建 GitHub PR | `/pr` 或 `/pr main`（指定目标分支） |

## 安装

### 1. 克隆仓库

将本仓库克隆到 `~/.claude/skills/` 目录下：

```bash
git clone https://github.com/LJW0401/claude-code-git-workflows.git ~/.claude/skills/git-workflows
```

### 2. 创建符号链接

Claude Code 只扫描 `~/.claude/skills/<name>/SKILL.md` 一层目录，嵌套在子仓库中的 skill 无法被直接识别。需要在 `~/.claude/skills/` 下创建符号链接：

```bash
cd ~/.claude/skills && ln -s git-workflows/commit commit && ln -s git-workflows/push push && ln -s git-workflows/merge merge && ln -s git-workflows/pr pr
```

完成后目录结构如下：

```
~/.claude/skills/
├── commit -> git-workflows/commit
├── push   -> git-workflows/push
├── merge  -> git-workflows/merge
├── pr     -> git-workflows/pr
└── git-workflows/          # 仓库本体
    ├── commit/SKILL.md
    ├── push/SKILL.md
    ├── merge/SKILL.md
    └── pr/SKILL.md
```

### 3. 重新加载

在 Claude Code 中执行 `/reload-plugins` 或重启会话即可识别新命令。

## 特性

- 提交信息默认使用中文
- 自动附加 `Co-Authored-By` 签名
- 安全检查：不会误提交密钥文件、不会强制推送
- 仅手动调用触发，不会被 Claude 自动执行
