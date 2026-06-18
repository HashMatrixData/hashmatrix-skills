# Contracts — <项目名> 专属指南（模板）

> 通用流程参见 SKILL.md 主文件。本文件只记录 **<项目名>**「契约 → 本地可用」相对通用流程的差异。
> 复制本模板为 `resources/<project>.md`（如 `governance.md`、`privacy.md`、`webui.md`），随该项目技术选型落地后填充。
> 项目键与定位见 `.claude/skills/create-skill/resources/project-profiles.md`。技术未定的部分写「待定」占位，不臆造框架细节。

## 契约形态

- 本仓消费/提供的契约形态：<待定，如 OpenAPI / proto(gRPC) / AsyncAPI / header-ICD>

## 契约 → 本地 stub/SDK（生成方式）

- 生成工具链：<待定，按选型补充>
  - 参考方向（落地后据实填写）：Java → Maven + openapi-generator / `buf generate`；TS/`webui` → OpenAPI → `packages/sdk`；Python/`privacy` → codegen；`gateway` → Lua、无 codegen、只读 header ICD。
- 产物落点：<生成的 stub/SDK 放哪个模块/包>

## 引用约定

- 消费方如何引依赖：<如 Maven 坐标 / npm workspace 包 / Python 包，待定>
- 刷新策略：<契约更新后重新生成的触发与校验，待定>

## 校验命令

```bash
# <该项目：拉契约 → 生成 → 编译校验 的命令；选型未定先留空>
```
