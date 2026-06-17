# Code Review — <项目名> 专属指南（模板）

> 通用流程参见 SKILL.md 主文件。本文件只记录 **<项目名>** 相对通用流程的差异。
> 复制本模板为 `resources/<project>.md`（如 `governance.md`、`data-foundation.md`），随该项目技术选型落地后填充。
> 项目键与定位见 `.claude/skills/create-skill/resources/project-profiles.md`。

## 架构上下文

- 语言 / 框架：<待定，如 Java 21 + Spring Boot / TS + Next.js / Python>
- 分层 / 模块：<如 API → Service → Repo；或前端 DTO→Service→Component>
- 关键约定：<如统一返回、DI 容器、Connector SPI、CRD reconcile…>

## 架构检查

- <分层边界检查点>
- <DRY / 公共库复用检查点（主仓 libs-java / libs-ts / contracts）>
- <配置管理：是否走 ConfigMap/Nacos 而非硬编码>

## 类型安全

- <该语言的类型完整性要求，如 mypy strict / TS no-any / Java 泛型具体化>

## 测试检查

- <测试框架与分层约定>
- <Mock / 测试数据生成约定>

## 条件维度（按变更内容触发）

- <如：数据模型变更 → 迁移可逆性；并发 → 阻塞调用；Operator → reconcile 幂等>

## 验证

```bash
# <该项目的 format / lint / test 命令>
```
