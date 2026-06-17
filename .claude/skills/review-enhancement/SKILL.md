---
name: review-enhancement
description: 审查 enhance-skill 提交到 hashmatrix-skills 仓的改进 Issue，评估建议合理性与落点，与用户商议后实施改进并关单。供插件维护者持续提升 Skill 质量（本仓自用，不分发）。
argument-hint: "[issue-number]"
---

# Review Enhancement — Skill 改进审查与实施

审查 `enhance-skill` 提交到 `HashMatrixData/hashmatrix-skills` 的改进建议，评估合理性与落点，与用户商议后落地。**在 hashmatrix-skills 仓内运行**（目标文件是本仓的 `skills/<skill>/...`）。

## 参数解析

`/review-enhancement [issue-number]`：给 number → 直接审该 Issue；未给 → 列出待处理由用户选。

---

## Step 1：获取待审查 Issue

```bash
# 指定
gh issue view <number> --repo HashMatrixData/hashmatrix-skills --comments
# 未指定 → 列出待处理
gh issue list --repo HashMatrixData/hashmatrix-skills --label enhancement --state open
```

展示列表供用户选择（序号、标题、目标 skill）。

## Step 2：读取 Issue 并定位目标文件

解析 Issue（enhance-skill 模板）提取：**目标 Skill**（标题 `[skill]`）、**建议落点**（`SKILL.md` 或 `resources/<project>.md`）、**反馈类型**、**使用上下文**（项目/环境/版本）。

读取目标文件当前内容：

```bash
cat skills/<skill>/SKILL.md
cat skills/<skill>/resources/<project>.md   # 如涉及
```

## Step 3：评估建议合理性

| 维度 | 评估要点 |
|------|---------|
| 准确性 | 建议指出的问题是否确实存在？（在当前文件中验证） |
| 普适性 | 改进对所有使用者有益，还是仅适用特定场景？ |
| 抽象层级 | 是**项目级架构不变量**，还是单次事故/特定子系统/一次场景的衍生物？ |
| 一致性 | 是否与 Skill 整体设计理念一致？ |
| 副作用 | 是否可能破坏其他项目的使用？ |
| 行数限制 | 改后 SKILL.md ≤ 249 行、resource ≤ 200 行？ |

### 抽象层级筛选准则（重要）

Skill 与 resource 是**跨场景共性载体**，不是事故 runbook，也不是某次问题的备忘录。吸收建议时必须剔除或泛化：

- **事故衍生物**：以「上次 X 出问题」「某 Issue 历史教训」为主要论据的清单项 → 不写入。
- **特定子系统重点**：仅在某一具体类/模块/API 下成立、而非项目层面普遍成立 → 不写入。
- **一次性场景产物**：仅在特定上下游组合/数据形态下需要的步骤 → 不写入。

判断口诀：**「换一个不相关的需求，这条还成立吗？」** 成立→保留；不成立→剔除或泛化（提取背后的架构不变量后再写入）。事故经验应沉淀到提报者本地 Skill / 项目 runbook / 个人 memory，而非本插件仓。

### 评估结论（三种判定）

- **采纳**：合理可直接实施 → 展示具体修改方案（哪个文件、改什么）。
- **需讨论**：有价值但需调整 → 抽象层级偏低则商议泛化；普适性局限则落 `resources/<project>.md` 而非主文件；与理念冲突则提替代方案。
- **拒绝**：不适合 → 说明原因（事故衍生物/仅个别场景/与理念冲突），建议提报者沉淀到本地。

## Step 4：与用户商议

用 `AskUserQuestion` 展示评估结论与修改方案，征求意见。**允许多轮讨论**：用户可提修改意见、要求更多上下文、或改变结论，直到达成共识。

## Step 5：实施改进

用户确认后执行：
1. 编辑 `skills/<skill>/SKILL.md` 和/或 `skills/<skill>/resources/<project>.md`。
2. 行数检查（SKILL.md ≤ 249、resource ≤ 200）。
3. 关联检查：若改了主流程步骤编号，同步 resource 中的引用。
4. 红线检查：不引入凭据/真实 IP/客户可识别信息。

展示 `git diff` 供用户最终确认。

## Step 6：⭐ 改动涉及分发内容则 bump version

**关键**：若本次修改触及**分发内容**（`skills/`、`agents/`、`.mcp.json`），必须把 `.claude-plugin/plugin.json`（及 `marketplace.json` 的 `metadata.version`）的 `version` 抬一位（如 0.2.0 → 0.3.0）。**否则用户 `/plugin update` 不会刷新已安装缓存**（安装缓存按 version 寻址）。仅改 `.claude/skills/`（本仓自用、不分发）则无需 bump。

## Step 7：关闭 Issue

1. 回复：`gh issue comment <number> --repo HashMatrixData/hashmatrix-skills --body-file ...`（采纳→说明修改+commit；拒绝→说明原因与建议）。正文先用 Write 写临时文件。
2. 关闭：`gh issue close <number> --repo HashMatrixData/hashmatrix-skills`。
3. 提交代码（如有修改 + version bump）：由用户决定是否立即提交推送。

---

## 批量处理

待处理 Issue 较多时逐个处理，每个完成后询问是否继续。**指向同一 Skill 的多条建议合并处理**，避免反复改同一文件、反复 bump version。
