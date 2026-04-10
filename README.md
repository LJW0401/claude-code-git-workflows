# Git Workflows - Claude Code Skills

Claude Code 自定义斜杠命令，用于快速执行 Git 工作流。

## 包含的命令

| 命令 | 用途 | 示例 |
|------|------|------|
| `/commit` | 暂存并提交更改 | `/commit 修复登录验证逻辑` 或 `/commit`（自动生成提交信息） |
| `/push` | 推送当前分支到远程 | `/push` 或 `/push upstream` |
| `/pr` | 创建 GitHub PR | `/pr` 或 `/pr main`（指定目标分支） |

## 安装

将本仓库克隆到 `~/.claude/skills/` 目录下：

```bash
git clone https://github.com/<your-username>/claude-code-git-workflows.git ~/.claude/skills/git-workflows
```

## 特性

- 提交信息默认使用中文
- 自动附加 `Co-Authored-By` 签名
- 安全检查：不会误提交密钥文件、不会强制推送
- 仅手动调用触发，不会被 Claude 自动执行
