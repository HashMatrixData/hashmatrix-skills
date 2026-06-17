# HashMatrix Skills

HashMatrix 数据中台团队的 **Claude Code Plugin Marketplace**（开源）。包含一组开发 Skill、一个隔离上下文的 Code Review 子代理，以及随附的 MCP 服务。

## 安装

```bash
# 1. 添加 marketplace
/plugin marketplace add https://github.com/HashMatrixData/hashmatrix-skills.git

# 2. 安装 hashmatrix-toolkit（含全部 skill / agent / mcp）
/plugin install hashmatrix-toolkit@hashmatrix-skills

# 3. 重载插件使其生效
/reload-plugins
```

安装后 Skill 通过 `/skill-name` 调用（如 `/code-review`、`/add-feature`、`/issue-report`）。

> 本地开发/离线兜底：`/plugin marketplace add /Users/<你>/IdeaProjects/hashmatrix-skills`

### 更新

```bash
/plugin update hashmatrix-toolkit@hashmatrix-skills   # 手动
claude config set --user autoUpdatesEnabled true       # 开启自动更新
```

## 包含内容

### Skills（分发）

| Skill | 说明 |
|-------|------|
| `/code-review` | 架构级代码审查（rubric 唯一源），支持 工作区 / commit / 范围 / `--pr` / GitHub PR URL |
| `/fix-review` | 修复 Code Review 报告中的 `[B*]`/`[W*]` 问题，支持分级与讨论模式 |
| `/add-feature` | Feature 实现完整工作流，实现后**内嵌拉起 `code-reviewer` 子代理**做客观审查 |
| `/fix-issue` | 从 GitHub Issue 出发：复现 → 修复 → 回归 → 关单 |
| `/issue-report` | 规范化创建 **GitHub Issue**（Bug/Feature/Task），引导收集关键信息 |

### Agent（子代理）

| Agent | 说明 |
|-------|------|
| `code-reviewer` | 隔离上下文、只读审查子代理。复用 `code-review` 的 rubric，输出 `[B*]/[W*]` 阻塞清单与裁决，供 `/fix-review` 解析 |

### 开发工具（不分发，`.claude/skills/`）

| Skill | 说明 |
|-------|------|
| `/create-skill` | 创建新的跨项目 Skill（共性放主文件 / 差异放 resources/） |

## MCP 与凭据（重要）

本插件随附 3 个 MCP 服务（`.mcp.json`）：

| MCP | 包 | 用途 |
|-----|----|----|
| `playwright` | `@playwright/mcp` | 浏览器自动化 / E2E / 截图 |
| `tmux` | `tmux-mcp` | 终端会话编排（长任务、交互式进程） |
| `ssh` | `@fangjunjie/ssh-mcp-server` | 远程主机执行 / 上传下载 |

> ⚠️ **`.mcp.json` 不内嵌任何 SSH 凭据**（公开仓，红线）。SSH 目标请在**本地未入库文件**中配置，例如在你个人的 Claude 配置里覆盖 `ssh` 服务的 `--ssh` 参数，或用环境变量。**任何主机/账号/密码都不得提交到本仓**（`.gitignore` 已挡 `.mcp.local.json`、`ssh-targets.json`、`.env`）。

## 设计约定

- **共性放 `SKILL.md`，项目差异放 `resources/<project>.md`**（跨项目内容嵌入，不外链）。
- **追踪平台：GitHub Issues**（`HashMatrixData/<repo>`），label 用 `type/*`、`priority/*`、`area/*`。
- 项目档案见 `.claude/skills/create-skill/resources/project-profiles.md`。

## 添加新 Skill

```bash
/create-skill
# 或手动：
# 1. skills/<name>/SKILL.md（含 name/description frontmatter）
# 2. 可选 skills/<name>/resources/<project>.md
# 3. 提交推送到 main，用户 /plugin update 获取
```

## License

[Apache-2.0](./LICENSE)
