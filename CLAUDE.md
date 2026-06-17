# CLAUDE.md — hashmatrix-skills 协作与合规指引

本文件为 Claude Code 及所有协作者在本仓库工作的**强制约束**。违反「信息红线」的内容一律不得提交。

## 🔴 信息红线（强制 · 不可协商）

本仓库为**公开开源仓库**。所有内容（代码、注释、文档、Skill/Agent 定义、配置样例、提交信息、Issue/PR）必须满足：

1. **禁止出现任何甲方/客户可识别信息**：真实单位名称/简称/品牌、人员姓名或账号、招标/合同/立项编号、内部项目代号、专有业务术语、真实数据、具体部署地点、网络或系统拓扑。
2. **禁止任何凭据与机密**：SSH 主机/账号/密码、API Key/Token、生产环境 IP、`.env` 内容、真实业务数据样本。
3. **`.mcp.json` 不得内嵌任何连接凭据**。SSH/远程目标由各人在**本地未入库文件**（如 `.mcp.local.json`、环境变量）配置，见 README「MCP 与凭据」。
4. **仅允许记录可面向大众公开的内容**：通用方法论、Skill 流程、开源组件用法、通用工程最佳实践。
5. **示例数据一律虚构脱敏**（`example.com`、`acme`、`tenant-demo`）。

> 判定标准：把本仓任意文件公开到互联网，不会泄露任何客户身份、项目机密或凭据。不确定时一律按「不写入」处理。

## 项目概述

HashMatrix 数据中台团队的 Claude Code **Plugin Marketplace**。用户通过 `/plugin marketplace add` 添加后安装 `hashmatrix-toolkit`，Skill / Agent / MCP 自动加载。托管在 `github.com/HashMatrixData/hashmatrix-skills`。

## 架构

- `.claude-plugin/marketplace.json` — Marketplace，定义单一插件 `hashmatrix-toolkit`
- `.claude-plugin/plugin.json` — 插件清单（name/version/components 自动发现）
- `.mcp.json` — 插件随附的 MCP 服务（playwright / tmux / ssh），**无凭据**
- `agents/` — 子代理（`code-reviewer` 隔离上下文审查）
- `skills/` — 分发给各项目的 Skill，每个含 `SKILL.md`（+ 可选 `resources/`）
- `.claude/skills/` — 本仓**开发工具** Skill（如 `create-skill`），**不分发**

## Skill 设计原则（跨项目）

- **共性放主文件**：`SKILL.md` 只放所有项目通用流程
- **差异放 resources/**：按项目拆 `resources/<project>.md`，记录语言/框架/架构差异
- **引用胜于嵌入**：当前仓内文件用 Markdown 链接；**跨项目内容必须嵌入** resource（使用者不一定有其他仓权限）
- 用 `/create-skill` 创建新的跨项目 Skill

## 追踪平台：GitHub Issues（非 Jira）

本组织**统一用 GitHub Issues 追踪**（`HashMatrixData/<repo>`）。涉及建单的 Skill（`issue-report` / `fix-issue` / `enhance-skill`）一律走 `gh` CLI + `type/*`、`priority/*`、`area/*` label 约定，详见 `skills/issue-report/resources/github-issues.md`。

## 提交前自检

- [ ] 无甲方/客户可识别信息、无凭据/IP/密码
- [ ] `.mcp.json` 无连接凭据
- [ ] 示例数据均为虚构/脱敏
- [ ] 跨项目差异已放入对应 `resources/<project>.md`
