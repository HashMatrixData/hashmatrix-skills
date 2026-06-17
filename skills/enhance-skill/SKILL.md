---
name: enhance-skill
description: 反馈 hashmatrix-toolkit Skill 本身的问题或改进建议。自动识别当前会话使用的 Skill，提取改进点、判定落点（主文件 vs resource），收集版本信息，通过 gh CLI 提交 GitHub Issue 到 hashmatrix-skills 仓库。当使用某个 Skill 时发现步骤错误、分支遗漏、文档过时、体验不畅时调用。
argument-hint: "[改进描述]"
---

# Enhance Skill — 插件 Skill 反馈

使用 hashmatrix-toolkit 的 Skill 过程中发现问题或有改进想法时，通过本 Skill 把结构化反馈提交为 GitHub Issue（`HashMatrixData/hashmatrix-skills`）。**本 Skill 只建单，不自动修改任何 Skill 文件。**

## 参数解析

`/enhance-skill [改进描述]`，描述可选，未提供时从会话上下文自动提取。

## Step 1：识别目标 Skill

从当前会话上下文识别用户正在使用（或刚用完）的 Skill：
1. 搜索最近调用的 `/<skill>` 或 `/hashmatrix-toolkit:<skill>`。
2. 找到多个 → 用 `AskUserQuestion` 确认反馈针对哪一个。
3. 未找到 → 直接询问用户要反馈哪个 Skill。

记录目标 skill 名（如 `code-review`、`fix-issue`、`issue-report`）。

## Step 2：读取目标 Skill 源文件

定位插件根并读取目标 skill 的全部文件：

```bash
ls "$CLAUDE_PLUGIN_ROOT/skills/<skill>/"
cat "$CLAUDE_PLUGIN_ROOT/skills/<skill>/SKILL.md"
# 及 resources/ 下相关文件
```

同时按 `git remote get-url origin` 确定当前用户所在项目，找到对应的 `resources/<project>.md`（如有）。

## Step 3：提取改进点

结合会话上下文与源文件，分析维度：

| 维度 | 典型问题 |
|------|---------|
| 步骤错误 | 命令不正确、路径已变更、API 已废弃 |
| 分支遗漏 | 某种场景/条件未覆盖 |
| 信息过时 | 端口/域名/版本已变更 |
| 流程缺失 | 缺少必要步骤、顺序不合理 |
| Resource 缺失 | 某项目应有差异指南但未创建 |
| Resource 不准 | 项目 resource 与实际不符 |
| 体验改进 | 步骤可简化、可增加自动化 |

用 `AskUserQuestion` 与用户确认提取到的改进点是否准确。

### Step 3.1：判定落点（主文件 vs resource）⭐

**关键原则**：每个 Skill 服务 8 个子项目。`SKILL.md` 只放**所有项目共性**的流程，差异必须落在 `resources/<project>.md`。单项目视角下很容易把应放 resource 的改进错塞到主文件——提交前必须显式判定。

| 改进特征 | 落点 |
|---------|------|
| 涉及具体语言/框架/命令/路径/端口 | `resources/<project>.md` |
| 仅对当前项目有意义（其他项目无此能力） | `resources/<project>.md` |
| 当前项目 resource 尚未提及 | `resources/<project>.md`（新增章节） |
| 所有项目都应遵守的流程/原则/决策点 | `SKILL.md`（主文件） |
| 主文件步骤错误或顺序不合理 | `SKILL.md`（主文件） |

**自检（生成 Issue 前必答）**：
- [ ] 换成另一个项目（Java 的 `governance`、Python 的 `privacy`、TS 的 `webui`）是否仍成立？
- [ ] 否 → 落点必须是 `resources/<project>.md`
- [ ] 是 → 才考虑 `SKILL.md`，且检查主文件是否已超行数（SKILL.md ≤ 249 行）

**反模式**：单项目痛点 → 直接改主流程 ❌；未检查其他项目 resource 就新增主文件章节 ❌。先问「其他项目是否有类似需要」→ 否则落 resource ✅。

## Step 4：收集版本信息

- 插件版本：`git -C "$CLAUDE_PLUGIN_ROOT" rev-parse --short HEAD 2>/dev/null`；取不到则用 `.claude-plugin/plugin.json` 的 `version`。
- 当前项目版本：`git log --oneline -1`。
- OS：`uname -s`。

## Step 5：前置检查

`gh auth status` 确认已登录且对 `HashMatrixData/hashmatrix-skills` 有 Issue 提报权限。若不可用，将格式化后的 Issue 内容输出到会话供用户手动提交到：
`https://github.com/HashMatrixData/hashmatrix-skills/issues/new`

## Step 6：格式化并提交 GitHub Issue

### 标题
`[<skill>] <简要描述>`　示例：`[code-review] resources 缺 data-foundation 的 Flink 作业审查维度`

### 正文（先用 Write 写入临时文件，避免中文/代码块被 shell 解析）

```markdown
## 反馈类型
<步骤错误 / 分支遗漏 / 信息过时 / 流程缺失 / Resource 缺失 / Resource 不准 / 体验改进>

## 目标 Skill
- **Skill**: <skill 名>
- **建议落点**: <resources/<project>.md 或 SKILL.md>（必填，见 Step 3.1）
- **落点理由**: <为什么是这个落点，含「是否对其他项目也成立」的判断>
- **插件版本**: <commit hash 或 version>

## 使用上下文
- **项目**: <当前项目>
- **项目版本**: <commit hash>
- **环境**: <dev / test / staging>
- **OS**: <macOS / Linux / Windows>

## 问题描述
<哪里有问题、什么场景触发>

## 建议改进
<具体建议，含建议修改的文件与内容方向>

---
*由 enhance-skill 自动生成*
```

### 提交

```bash
gh issue create --repo HashMatrixData/hashmatrix-skills \
  --title "[<skill>] <描述>" \
  --body-file /tmp/enhance-body.md \
  --label "enhancement"
```

> label 先 `gh label list --repo HashMatrixData/hashmatrix-skills` 拉真实列表（见 `issue-report` 的 `resources/github-issues.md`）；`enhancement` 不在列表就不传。成功后输出 Issue 链接并删除临时正文。

## 注意事项

- **不自动改 Skill 文件**：只提交反馈 Issue。
- **敏感信息过滤（红线）**：提交前移除 IP / 密码 / token / 客户可识别信息。
- **一次一个改进**：多个改进点分别建单，避免大杂烩。
- **与 issue-report 的区别**：`issue-report` 提报**产品** Bug/Feature 到对应业务仓；`enhance-skill` 反馈 **Skill 本身**的问题到 `hashmatrix-skills` 仓。
