---
name: issue-report
description: 规范化提交 GitHub Issue（Bug / Feature / Task）。引导用户按最佳实践填写关键信息，自动选择归属仓库、套用模板、打 label 并通过 gh CLI 创建。适用于缺陷反馈、功能需求、技术任务。
argument-hint: "[repo 或 area] [描述内容]"
---

# Issue Report（GitHub Issues）

规范化提交 Issue，减少来回沟通。目标：让收到工单的工程师无需追问即可理解问题或需求。**本组织统一用 GitHub Issues 追踪，不使用 Jira。**

## 参数解析

用法：`/issue-report [repo 或 area] [描述内容]`，两个参数均可选。
1. 第一个词匹配已知仓库名/区域（见映射表）→ 视为归属，剩余为描述。
2. 不匹配 → 整串为描述，归属后续确认（优先按当前 `git remote get-url origin` 自动判定）。

## Issue 类型判定

| 类型 | label | 适用场景 | 标题格式 |
|------|-------|----------|----------|
| **Bug** | `bug` | 现有功能不符合预期、报错、崩溃、数据异常 | `[组件] 用户可见症状 — 根因简述`（根因未知时省略后半段） |
| **Feature** | `enhancement` / `type/feature` | 新功能、增强、体验改进 | `[组件] 作为X希望Y以便Z` 或简洁描述 |
| **Task** | `type/task` | 技术债务、重构、文档、配置、运维 | `[组件] 动词 + 目标` |

> 判定技巧：「不能用/报错/白屏」→ Bug；「希望支持/能不能加」→ Feature；「需要升级/清理/迁移」→ Task。

## 仓库映射（HashMatrixData 组织）

**核心原则：Issue 是谁的，就提到对应的仓库里。** 优先按 `git remote` 自动检测；多端问题判断主要实现方。

| 归属 | 仓库 | 说明 |
|------|------|------|
| 主仓/部署/契约 | `HashMatrixData/hashmatrix` | 公共依赖、Helm 部署、ICD 契约 |
| 前端 | `HashMatrixData/hashmatrix-webui` | WebUI / 大屏 / 可视化编排前端 |
| 网关 | `HashMatrixData/hashmatrix-gateway` | 路由/限流/鉴权配置与插件 |
| 数据治理 | `HashMatrixData/hashmatrix-governance` | 元数据/模型/质量 |
| 数据安全 | `HashMatrixData/hashmatrix-security` | 分类分级/标签/审批/审计 |
| 数据工具 | `HashMatrixData/hashmatrix-tools-bi` | 报表BI/可视编排 |
| 隐私计算 | `HashMatrixData/hashmatrix-privacy` | MPC/PSI/匿踪 |
| 数据基础 | `HashMatrixData/hashmatrix-data-foundation` | 采集/计算/湖仓/Connector |
| 平台公共 | `HashMatrixData/hashmatrix-platform-common` | 调度/工作流/认证/元数据 |

> 横跨前后端：接口返回值错 → 后端；调用参数/时序错 → 前端。

## 批量场景

输入含「这些/全部/所有」+「bug/issue」时进入批量模式：先一次性提取公共信息（仓库、环境、可复现性），列出工单总览表请用户确认拆分，再逐个创建，最后汇总链接。

## 执行步骤

### Step 1. 判断类型
Bug / Feature / Task，不确定直接问。

### Step 2. 收集信息（按类型必填字段）
- **Bug**：模块、标题、复现步骤（≥2 步，动词开头）、实际结果、预期结果、错误日志/堆栈（完整不截断）、可复现性（全环境必现/特定环境/特定数据/不稳定+频率/无法复现）。强烈建议：环境+URL、严重程度、TraceID、首次出现时间。
- **Feature**：模块、标题、用户故事（角色/功能/价值）、验收标准（≥2 条可验证）。
- **Task**：模块、标题、任务描述、完成标准。

详见 `{baseDir}/resources/templates.md`。

### Step 3. 证据收集（Bug 专用，缺则不提交）
排版/样式→截图；时序/交互→录屏；接口/数据→错误日志或响应体（代码块包裹，不截图文字）；崩溃/白屏→Console 日志+截图；后端异常→服务端日志片段（含时间窗口）+ Trace ID。

### Step 4. 追问缺失
一次性列出所有缺失项，不逐个问。复现步骤要具体；验收标准要可验证；「偶现」须追问频率。

### Step 5. 质量检查
- [ ] 标题清晰（<100 字符），**Bug 标题以用户可见症状开头**（根因已知用 ` — ` 附在末尾）
- [ ] 描述简洁（<300 词），复现步骤编号且最小化，代码片段 <30 行
- [ ] 无对话历史痕迹、无冗余工具输出，仅含可操作信息
- [ ] **Bug Report 不含修复建议**（修复方案由维护者决策）
- [ ] **根因分析仅作可选补充**（≤20% 篇幅，须有日志支撑）
- [ ] 无凭据/真实 IP/客户可识别信息（红线）

### Step 6. 确认优先级（label `priority/*`）
P0 系统崩溃/数据丢失/安全漏洞/生产不可用 → `priority/high`；P1 核心功能不可用无绕过 → `priority/high`；P2 有绕过/部分用户 → `priority/medium`；P3 UI/文案/体验 → `priority/low`（无对应档就近取）。

### Step 7. 创建 GitHub Issue
按 `{baseDir}/resources/github-issues.md` 的 gh CLI 流程创建（正文先 Write 到临时文件再 `--body-file`；label 先 `gh label list` 拉真实列表再选）。创建成功后输出 issue URL 并清理临时文件。

---

## 常见反模式

| 不规范 | 引导改进 |
|--------|---------|
| 「页面白屏了」 | 哪个 URL？Console 报错？是否必现？**提供截图** |
| 「接口报错」 | 哪个接口（URL+Method）？状态码？响应体？ |
| 「有时候会崩」 | 多少次出现几次？有无规律？选可复现性类型 |
| 标题只写技术根因 | 谁受影响、用户看到什么？症状在前、根因在后 |
| 「加一个 XX 功能」 | 谁用？解决什么问题？怎样算做好（验收标准）？ |
