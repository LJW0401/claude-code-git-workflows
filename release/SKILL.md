---
name: release
description: 创建 Git tag 并发布 GitHub Release
disable-model-invocation: true
argument-hint: [版本号，如 v1.0.0]
allowed-tools: Bash(git *) Bash(gh *) Bash(ls *) Bash(make *) Bash(cargo *) Bash(go *) Bash(npm *) Bash(pnpm *) Bash(yarn *) Bash(npx *) Glob Read
---

创建语义化版本 tag 并发布 GitHub Release。

## 流程

1. 运行 `git status` 确认工作区干净，没有未提交的更改
2. 运行 `git tag --sort=-v:refname | head -10` 查看最近的版本标签
3. 确定版本号：
   - 如果用户提供了 `$ARGUMENTS`，使用该版本号
   - 否则根据最近的 tag 提示用户选择（patch/minor/major 递增）
   - 版本号必须符合语义化版本格式：`vMAJOR.MINOR.PATCH`（如 `v1.2.3`）
   - 如果用户输入的版本号没有 `v` 前缀，自动补上
4. 运行 `git log $(git tag --sort=-v:refname | head -1)..HEAD --oneline 2>/dev/null || git log --oneline -20` 获取自上次 release 以来的提交记录
5. 生成 release notes：
   - **优先使用仓库根目录的 `.release.md` 模板**（如果存在）：读取整个模板作为骨架，按提交记录填充 `<VERSION>`、`<PREV_VERSION>`、功能标题、修复要点等占位符；模板里的安装/升级指引、Claude Code 署名等固定段保留原样
   - 若 `.release.md` 不存在，退回默认结构：新功能（feat）/ 修复（fix）/ 其他改进 三段中文 notes
   - 生成后删掉模板里本次没用到的小节（例如无破坏性变更就整段删掉 ⚠️ 小节），不要留空标题
   - 所有占位符 `<...>` 必须替换干净，发布前自查一遍不能有残留
6. 检查是否需要构建附件：
   - 查看项目根目录是否存在 Makefile、Cargo.toml、go.mod、package.json 等构建文件
   - 查看是否存在 `.goreleaser.yml`、`Justfile`、`build.sh` 等发布相关脚本
   - 如果存在构建配置，询问用户是否需要构建并附加二进制/产物文件
7. 向用户确认：版本号、release notes 内容、是否构建附件
8. 创建 tag 并推送（先推送 tag，确保构建时能从 tag 获取正确版本号）：
   ```
   git tag -a <版本号> -m "Release <版本号>"
   git push origin <版本号>
   ```
9. 如果用户确认需要构建附件：
   - 执行对应的构建命令（如 `make release`、`cargo build --release`、`go build`、`npm run build` 等）
   - 构建完成后，列出产物文件路径和大小，供用户确认
   - 如果构建失败，告知用户错误信息，但不要删除已推送的 tag（由用户决定是否回退）
10. 使用 `gh release create` 发布 GitHub Release：
   ```
   # 无附件
   gh release create <版本号> --title "Release <版本号>" --notes "$(cat <<'EOF'
   <release notes>
   EOF
   )"

   # 有附件时，将文件路径追加在命令末尾
   gh release create <版本号> --title "Release <版本号>" --notes "..." ./path/to/file1 ./path/to/file2
   ```
11. 运行 `gh release view <版本号>` 确认发布成功，返回 release 链接

## 注意事项

- 发布前务必向用户展示版本号和 release notes 并确认
- 如果该版本号的 tag 已存在，告知用户并停止操作
- 不要使用 `--force` 覆盖已有 tag
- 默认不标记为 prerelease，如用户要求则加 `--prerelease`
- 默认不标记为 latest，由 GitHub 自动判断；如用户要求可加 `--latest`
- 附件文件上传前需向用户确认文件列表和大小
- 不要上传 `.git`、`node_modules`、临时文件等非产物文件
- 如果构建失败，告知用户错误信息，不要继续发布
- `.release.md` 模板命中时，长内容建议用 `--notes-file` 写到临时文件再传给 `gh release create`，避免 HEREDOC 里大量反引号转义出错
