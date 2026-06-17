---
name: split-task
description: Story/Epic 科学拆分子任务工作流。把一个较大的 GitHub Issue / Epic / 设计文档切成多个可独立交付的子任务，用 GitHub sub-issue 能力下单，输出含依赖图与集成回归守护的拆分方案。当用户说「拆分这个任务」「把 Epic 拆成子任务」「分解任务」「给一个 Story 切刀方案」时触发。依赖 gh CLI / GitHub MCP。
argument-hint: "<GitHub Issue URL/编号 | 设计文档路径 | 自由描述>"
---

# Split Task — Story/Epic 科学拆分

把一个较大 Story/Epic/Issue 切成职责清晰、可独立追踪的子任务清单，并用 GitHub **sub-issue** 能力落地。

**层级化硬约束**（按 Phase 0.5 识别选用）：
- **PR 边界（Epic → Story/Task/Issue）**：每子任务单独 merge 后 main 可消费（编译 / 单测 / 业务行为不破）。
- **Story 内分解（Story → Sub-task）**：默认同上；仅在**编译期/类型期耦合**（abstractmethod / interface / type signature 等）必要打包条件下可豁免中间态破坏——子任务显式标注「Story 边界前禁单独 merge」，依赖图末端 sub-task 必须把 main 拉回可消费。

**软指标 + 必要打包**：单 sub-task ~200 LOC 参考；逻辑边界 > 行数；运行时耦合的原子单元保留打包，宁可大不引入 Optional default / 临时兼容层等过渡债。

## 与其他 skill 的关系

| Skill | 角色 | 衔接 |
|------|------|------|
| `split-task`（本 skill） | **事前拆**：把大 Story/Epic/Issue 切成子任务 | 输出 GitHub sub-issue 号列表 |
| `add-feature` | 单 Story 端到端实现 | 对每个子任务单独驱动 |
| `fix-issue` | 单 Issue 修复 | 对每个修复型子任务单独驱动 |

`add-feature` 评估出大型规模需拆时，先调用本 skill 完成方法论级拆分，再回流到 `add-feature` 驱动每个子项。

## 前置依赖

`gh auth status` 确认登录且对目标仓有 Issue 写权限。GitHub sub-issue 用 GitHub MCP `sub_issue_write` 或 REST（见 Phase 7.2）。

> **项目差异**：模块边界识别与关键架构能力守护清单按项目不同，见 `{baseDir}/resources/<project>.md`（按 `_template.md` 格式，随各项目技术选型落地补充；缺失时按本主流程执行）。仓库与项目键见 `issue-report` 的仓库映射表。

## Phase 0：输入识别

| 输入形式 | 处理 |
|---------|------|
| GitHub Issue URL / `owner/repo#N` | `gh issue view <url> --comments` 拉详情；记录 owner/repo 与父号 |
| 设计文档路径 | Read 文件；`AskUserQuestion` 询问落地仓库与父 Issue（无父则建议先建一个 Epic/Story Issue） |
| 自由描述 | `AskUserQuestion` 确认归属仓库、是否已有父 Issue |
| 未提供 | 引导用户给出拆分对象 |

**准出**：scope 清晰（目标产物 / 影响模块 / 关键约束），落地仓库与父 Issue 号已定。

## Phase 0.5：识别拆分层级

| 拆分对象 | 子产物 | 硬约束 |
|---------|-------|-------|
| Epic | Story / Task / Issue | main 可消费（强） |
| Story / Task / Issue | Sub-task | 同上；编译期/类型期耦合可豁免中间态，末端 sub-task 必须拉回 main 可消费 |

## Phase 1：改动地形勘察

搞清 scope 内会动多少地：① 受影响文件清单（grep 关键符号/模块路径/依赖类）；② 模块归属（每文件落到哪个 layer）；③ 依赖追踪（上游 caller / 下游 callee / 共享数据结构）。

**按项目类型**：参见 `{baseDir}/resources/<project>.md` 的「模块边界识别」章节。

**准出**：地形图清晰（受影响文件 + 模块 + 依赖）。

## Phase 2：候选切分识别

按职责轴画切刀候选，每条写明：职责描述（一句话）、范围（文件/函数）、粗估 LOC。

**切刀启发**：沿层切（API/Service/DAL/Schema）｜沿职责切（数据修复 vs 行为新增 vs 测试守护）｜沿模块边界切（DDD 分层、前端组件原子等）。

**准出**：候选切刀清单，每刀职责单一、可一句话描述。

## Phase 3：切刀验证（"main 可消费"测试，硬门槛）

对每个候选 sub-task，模拟独立 merge 进 main，逐项检查：

| 检查项 | 通过条件 |
|--------|---------|
| 编译 | 无类型错误、无未定义引用 |
| 单测 | 现有测试全过，新增测试对应通过 |
| 业务行为 | 关键链路功能不破（手测或冒烟） |
| 不引入临时债 | 无 Optional default / 临时兼容层 / 半修中间态 |

**按 Phase 0.5 层级**：PR 边界要求全过；Story 内分解的 sub-task 仅编译期/类型期耦合可豁免中间态破坏，末端 sub-task 必须把所有项拉回。**任一项不过** → 撤回此刀，与相邻 sub-task 合并成更大原子单元。

## Phase 4：三轴平衡评估

为每个保留 sub-task 评估：**可观察性**（自带验证手段？范围匹配？）｜**可维护性**（单一文件域/模块？依赖明确？）｜**独立性**（能并行？是否需串行？）。低分项说明理由（如 schema→service 必须串行）或调整切刀。

## Phase 5：依赖图绘制

ASCII 画 blocks / blocked-by：

```
A (schema 修复) ─┐
                 ├─→ D (集成回归测试)
B (service 改) ──┤
C (前端适配) ────┘   // 可与 A/B 并行
```

标注每个 sub-task 是否可并行 ship、关键路径长度。

## Phase 6：集成测试 sub-task 设计（末端）

纯测试子任务，零生产风险，专守「安全性矩阵 / 关键架构能力」回归：单独成 sub-task、放依赖图末端、不混功能改动、覆盖「本次拆分没有任何单 sub-task 能独立守护的跨边界能力」。

**覆盖完整性核验**（硬门槛，逐条勾）：
- [ ] **父级验收逐条映射**：父 Issue 每条验收都映射到 ≥1 个 sub-task，无悬空。
- [ ] **跨 sub-task invariant 守护**：跨边界关键不变量（schema/FSM/RBAC/事务边界/缓存一致性…）每条在末端测试有用例。
- [ ] **过渡机制全测**（如有）：feature flag / 灰度 / 双写 / migration，每个有 on/off 双向用例。
- [ ] **回滚路径可演练**（如有）：引入的 migration/flag 有「回滚生效」测试或演练。
- [ ] **依赖图末端唯一**：末端测试是唯一汇聚点（否则回 Phase 5 调整）。

任一未勾 → 扩末端范围或回 Phase 2 重切。**项目专属审核**：参见 `{baseDir}/resources/<project>.md`。

## Phase 7：用户确认 + GitHub 落地

### 7.1 输出最终拆分方案

```markdown
## 拆分方案
### 拆分理念
[为什么这么切，含"为什么不再细拆 X"]
### Sub-task 清单
#### 1. [标题]
- 目标 / 范围(文件清单) / 预估 LOC / 测试 / 依赖(blocked-by·blocks) / 可独立 ship(是·否+原因) / 验收
#### 2. ...
### 依赖图  [ASCII]
### 总 LOC 估算  N LOC（符合软指标 / 超出但承认必要打包）
```

`AskUserQuestion` 确认方案，用户可逐项调整。**未确认前不在 GitHub 创建任何子项。**

### 7.2 GitHub sub-issue 落地

1. **创建子 Issue**：`gh issue create --repo HashMatrixData/<repo> --title "<标题>" --body-file <tmp> --label "type/task" --label "area/<…>"`（标题/正文规范同 `issue-report`；正文先 Write 到临时文件）。
2. **关联为 sub-issue**：取子 Issue 的 database id `gh api repos/<owner>/<repo>/issues/<子号> --jq .id`，再
   `gh api -X POST repos/<owner>/<repo>/issues/<父号>/sub_issues -F sub_issue_id=<子id>`
   （或 GitHub MCP `sub_issue_write` method=add, issue_number=父号, sub_issue_id=子id）。父 Issue 会自动聚合 sub-issue 进度。
3. **blocks/blocked-by**：GitHub 无原生 issue link；在子 Issue 正文用 `Blocked by #<n>` 文本表达串行依赖。

完成后输出子项号列表 + 依赖图，供 `add-feature` / `fix-issue` 接力。

## 关键决策点（必须与用户对齐）

输入 scope（Phase 0）｜拆分层级（0.5）｜切刀候选职责划分（2）｜哪些刀必须撤回打包（3）｜最终清单是否可下单（7）。

## 反模式

凭行数硬切破 main → 用「main 可消费」验证每刀｜Sub-task 层硬套「main 可消费」过度打包 → 用 0.5 层级化约束｜为小 PR 引入 Optional default/兼容层 → 承认必要打包｜不同职责塞同一 sub-task → 每个一句话说清职责｜漏集成回归 → 末端留集成测试｜切刀前不画依赖图 → 先画 blocks｜跳过用户确认直接建子项 → 方案确认后才下单。
