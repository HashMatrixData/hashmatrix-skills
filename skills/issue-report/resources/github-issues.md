# Issue Report — GitHub Issues 创建流程

> 通用流程参见 SKILL.md 主文件。本文件覆盖 `gh` CLI 的具体创建细节与 label 约定。

## 前置检查

```bash
gh auth status          # 确认已登录且对目标仓库有写权限
git remote get-url origin   # 自动判定当前仓库归属（HashMatrixData/<repo>）
```

## 创建流程

```bash
# 1) 正文先用 Write 工具写入临时文件，避免长文本/中文/代码块在命令行被 shell 解析
#    （写到 /tmp/issue-body.md）

# 2) 创建（label 必须来自真实列表，见下）
gh issue create \
  --repo HashMatrixData/<repo> \
  --title "<按 SKILL.md 标题格式>" \
  --body-file /tmp/issue-body.md \
  --label "<label1>" --label "<label2>"

# 3) 输出返回的 issue URL，删除临时正文文件
```

## Label 约定

label 随项目演进，**不要硬编码完整列表**。创建前先拉当前真实 label：

```bash
gh label list --repo HashMatrixData/<repo> --limit 100
```

按命名空间从**真实列表**中选（label 不在列表里就不要传，否则 `gh` 会报错或误建新 label）：

| 维度 | 命名空间 / label | 选择规则 |
|------|-----------------|---------|
| 类型 | `bug` / `enhancement` / `type/*`（`type/feature`、`type/task`） | Bug→`bug`；Feature→`enhancement` 或 `type/feature`；Task→`type/task` |
| 优先级 | `priority/*`（`priority/high`/`medium`/`low`） | 按 SKILL.md Step 6 映射，无对应档就近取 |
| 模块 | `area/*`（如 `area/api`、`area/connector`、`area/ui`…） | 按 Issue 涉及子系统选 ≥1 个；拿不准列候选请用户确认 |
| 状态 | `status/*`（如 `status/backlog`、`blocked`） | 仅在确属该状态时加 |

> 若目标仓库尚未建立这些 label：先不传不存在的 label 创建 Issue，再建议补充组织级标准 label 集（`type/*`、`priority/*`、`area/*`）。

## 字段说明

GitHub Issue **无必填自定义字段**，正文按 SKILL.md Step 2（必填字段）+ Step 3（证据）+ `templates.md` 模板组织即可。

## 关联与去重

- 创建前可 `gh issue list --repo HashMatrixData/<repo> --search "<关键词>"` 查重，避免重复建单。
- 与 PR/其他 Issue 有关联时，在正文用 `#<number>` 或 `Closes #<number>` 交叉引用。

## 红线

正文/标题/label **不得包含**：真实主机 IP、SSH/账号/密码、token、客户可识别信息。粘日志前先脱敏。
