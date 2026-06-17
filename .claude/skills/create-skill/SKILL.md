---
name: create-skill
description: 创建新的跨项目 Claude Code Skill（本仓开发工具，不分发）。引导按「共性放主文件、差异放 resources/」原则编写 SKILL.md 与项目资源，确保符合本仓信息红线。当需要新增/规范化一个 Skill 时使用。
argument-hint: "[skill 名称] [一句话用途]"
---

# 创建跨项目 Skill

本 Skill 用于在 `hashmatrix-skills` 仓内规范地新增 Skill。产出供所有 HashMatrix 子项目共用，必须遵循跨项目设计原则。

## 设计原则（必须遵守）

1. **共性放主文件**：`SKILL.md` 只放所有项目通用的流程与步骤。
2. **差异放 resources/**：按项目拆 `resources/<project>.md`，记录语言/框架/架构差异。项目键见 `{baseDir}/resources/project-profiles.md`。
3. **引用胜于嵌入**：当前仓内文件用 Markdown 链接；**跨项目内容必须嵌入** resource（使用者不一定有其他仓权限）。
4. **实践基础**：至少在一个项目中验证过的实践，才值得固化成 Skill。
5. **红线合规**：任何文件都不得含客户可识别信息、凭据、真实 IP（见仓库 `CLAUDE.md`）。

## 步骤

### Step 1. 确定定位
- 名称（kebab-case）、一句话用途、触发场景。
- 判断分发与否：面向各项目 → `skills/<name>/`；本仓开发工具 → `.claude/skills/<name>/`。

### Step 2. 写 SKILL.md
- frontmatter：`name`、`description`（含「当…时使用」触发语）、可选 `argument-hint`。
- 正文：分 Step 的通用流程。涉及项目差异处，写「**按项目类型**：参见 `{baseDir}/resources/<project>.md` 的 <章节>」。

### Step 3. 写项目资源（如有差异）
- 复制 `skills/code-review/resources/_template.md` 风格，为相关项目建 `resources/<project>.md`。
- 当前各子模块技术选型未定的，可先建占位、随选型落地补充。

### Step 4. 追踪/建单约定
- 涉及建 Issue 的，统一走 **GitHub Issues**（不是 Jira），复用 `skills/issue-report/resources/github-issues.md` 的流程与 label 约定。

### Step 5. 自检与提交
- `make validate` 校验清单 JSON（若改了 manifest）。
- 提交前过一遍仓库 `CLAUDE.md` 的「提交前自检」。
- 推送到 main，用户通过 `/plugin update hashmatrix-toolkit@hashmatrix-skills` 获取。

## 参考骨架

```
skills/<name>/
├── SKILL.md
└── resources/
    ├── _template.md          # 可选：项目资源模板
    └── <project>.md          # 按需，逐项目补充
```
