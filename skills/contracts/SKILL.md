---
name: contracts
description: 跨仓查阅 HashMatrix 主仓最新接口契约 + 同步本仓 CLAUDE.md 契约块。在任意子仓按需「拉最新契约 → 反查本仓 producer/consumer → 引用/刷新本仓契约块」，永远取最新、不存本地副本。当用户说「查契约」「看接口契约」「本仓依赖/提供哪些契约」「同步契约块」「刷新 CLAUDE.md 契约」时触发。依赖 git / gh CLI / WebFetch。
argument-hint: "[consult | sync] 或留空（默认 consult）"
---

# Contracts — 契约查阅与同步

主仓 `HashMatrixData/hashmatrix` 的 `contracts/` 是全组织接口契约**单一事实源**（`registry.yaml` 机器可读索引、`integration.md` 标准块+全仓映射、`CONVENTIONS.md` 规范）。子仓多为独立 clone、主仓 `contracts/` 不在盘，本 skill 让 Claude Code 在**任意仓**按需查阅最新契约并同步本仓 CLAUDE.md 契约块。

**范围**：① 查阅(consult) ② 同步块(sync)。**不含** producer 改契约后的影响面分析（后续演进）。

铁律（贯穿）：**先改契约再改实现 · 加法兼容 · 破坏变更双跑**。

## 参数解析

`/contracts [consult|sync]`：
- `consult`（默认）→ 拉最新契约 + 反查本仓相关项 + 摘要/引用。
- `sync` → 在 consult 基础上，刷新本仓 `CLAUDE.md`「🔗 契约」块（show diff + 确认后写）。

## 前置依赖

- `git`：`git remote get-url origin` 推断当前仓。
- 取契约源二选一：**公开仓免鉴权** `WebFetch`；或 `gh`（`gh auth status` 确认登录，私有/限流时用）。

## Step 1. 解析契约源（永远取最新，不存本地副本）

按优先级定位 `contracts/`：

| 场景 | 取法 |
|------|------|
| superproject 内（当前仓位于 `hashmatrix/services/<repo>` 等子模块路径） | 直接读相对主仓根的 `contracts/`（如 `../../contracts/`）；不确定时向上找含 `contracts/registry.yaml` 的目录 |
| 独立 clone（默认） | `WebFetch https://raw.githubusercontent.com/HashMatrixData/hashmatrix/main/contracts/registry.yaml`（公开仓免鉴权） |
| WebFetch 不可用 / 需鉴权 / 限流 | `gh api repos/HashMatrixData/hashmatrix/contents/contracts/<path> -H "Accept: application/vnd.github.raw"` |

**铁律：永远取主仓 `main` 最新，不在本仓落地契约副本**（引用胜于嵌入，从根上避免漂移）。

按需源文件：`registry.yaml`（索引）、`integration.md`（标准块模板 + 全仓映射）、必要时 `CONVENTIONS.md`、`docs/architecture/06-契约治理.md`。

## Step 2. 推断当前仓 → 反查 producer/consumer

1. `git remote get-url origin` → 解析出 `HashMatrixData/<repo>` → 映射项目键（仓库映射见 `issue-report` 主文件「仓库映射」表；`origin` 缺失/多 remote 时询问用户确认归属）。
2. 在 `registry.yaml` 中按当前仓反查：
   - **producer**：本仓对外提供的契约（others 依赖我）。
   - **consumer**：本仓对外依赖的契约（我依赖 others）。
3. 以 `registry.yaml` **实际字段为准**解析（producer / consumers / 形态 / 源路径），**不臆造 schema**；字段不明时读 `integration.md` 对照。

## Step 3.（模式 A）查阅 consult

- 列出本仓 producer / consumer 契约：契约 id、对端仓、形态（openapi / proto / asyncapi / header-icd 等）、`contracts/<path>` 源位置。
- 按需拉取具体契约文件并**摘要**关键接口/字段；引用时给出主仓路径与 `main` 出处，**不复制大段内容入本仓**。
- 若用户问「能不能改 X 契约」→ 引 `CONVENTIONS.md` 铁律提示（加法兼容 / 破坏变更双跑），必要时引导走主仓契约变更流程。

## Step 4.（模式 B）同步块 sync

> 仅当用户要 `sync` 时执行。**目的：消除手维护契约块与 `registry.yaml` 的漂移。**

1. 以主仓 `integration.md §1` 的**标准块模板为准**，用 Step 2 反查结果填充本仓 producer / consumer。
2. 读当前仓 `CLAUDE.md`，定位既有「🔗 契约（Contracts）」块（无则准备新增到合适位置，如「架构/集成」相关章节附近）。
3. 生成新块（参考结构见下），与既有块对齐。
4. **强制 show diff**：展示 `CLAUDE.md` 拟改动；**用户确认后才写**。绝不静默覆盖手维护内容；用户手工补充的非生成段落须保留。

参考块结构（**实际以主仓 `integration.md §1` 为准**，避免本文件与模板漂移）：

```markdown
## 🔗 契约（Contracts）

> 源：主仓 `HashMatrixData/hashmatrix` `contracts/`（以 `registry.yaml` 为准）。由 `/contracts sync` 刷新，契约演进后重跑。

**producer（本仓对外提供）**
- `<contract-id>` → consumers: `<repo>…` ｜ 形态: `<openapi|proto|asyncapi|header-icd>` ｜ 源: `contracts/<path>`

**consumer（本仓对外依赖）**
- `<contract-id>` ← producer: `<repo>` ｜ 形态: `<…>` ｜ 源: `contracts/<path>`

铁律：先改契约再改实现 · 加法兼容 · 破坏变更双跑。契约→本地生成方式见本仓约定。
```

## 项目差异：契约 → 本地可用

「拉到契约后怎么转成本地可调用的 stub/SDK」**按项目技术选型不同**，属项目差异，不入主文件：

- **按项目类型**：参见 `{baseDir}/resources/<project>.md`（按 `_template.md` 格式，随各项目选型落地补充；**缺失时只做查阅/同步，不臆造生成命令**）。
- 项目键与定位见 `.claude/skills/create-skill/resources/project-profiles.md`；仓库映射见 `issue-report` 主文件。

## 反模式

| 不规范 | 纠正 |
|--------|------|
| 把契约文件拷进本仓「留存一份」 | 永远引用主仓 `main` 最新，不存副本 |
| 直接覆盖 `CLAUDE.md` 契约块 | sync 必须 show diff + 用户确认，保留手工补充段 |
| 在 resources 写未验证的 codegen 命令 | 选型未定写「待定」占位，不臆造 |
| 先改实现再补契约 | 先改契约再改实现；破坏变更双跑 |
| 把某次联调特例写进主文件 | 共性入 SKILL.md，项目差异入 resources，事故经验入本地 |

---

红线：本 skill 仅引用本组织自有公开仓（`HashMatrixData/hashmatrix`），不写入客户可识别信息 / 凭据 / 真实 IP。
