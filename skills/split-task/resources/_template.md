# Split Task — <项目名> 专属指南（模板）

> 通用流程参见 SKILL.md 主文件。本文件只记录 **<项目名>** 拆分时相对通用流程的差异。
> 复制为 `resources/<project>.md`（项目键见 `.claude/skills/create-skill/resources/project-profiles.md`），随该项目技术选型落地后填充。

## 模块边界识别（Phase 1）

- 分层 / 模块拓扑：<如 API→Service→Repo；或前端 DTO→Service→Component；或 Operator CRD 层级>
- 切刀常用边界：<该项目天然的职责/层/模块切点>
- 依赖追踪要点：<共享数据结构 / 契约（主仓 contracts/）/ 跨子模块调用>

## 关键架构能力守护清单（Phase 6）

> 末端集成测试 sub-task 必须覆盖的、跨 sub-task 边界的关键不变量。

- <如：schema 兼容性 / 状态机流转 / RBAC 多租户隔离 / 事务边界 / 缓存一致性 / Connector SPI 契约>

## 项目专属审核（Phase 6 末）

- <该项目额外的拆分核验点，如 Flink 作业 checkpoint 兼容、Helm values 双轨（开源/信创）覆盖等>

## 验证命令

```bash
# <该项目 编译 / 单测 / lint 命令，用于 Phase 3「main 可消费」验证>
```
