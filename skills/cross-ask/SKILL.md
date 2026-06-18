---
name: cross-ask
description: 跨项目问询/讨论。子项目对其他项目（尤其主项目）的公共依赖、契约或承诺有疑问、又尚未成型为 Issue 时，向目标项目仓库发起一条 GitHub Discussion 灵活讨论，可 @ 指定回答人，讨论达成结论后再落成 Issue 或其它解决办法。当用户说「跨项目问一下」「向主项目提个讨论」「cross-ask」「公共依赖/承诺有疑问想讨论」时使用。依赖 gh CLI（GraphQL Discussions）。
argument-hint: "<目标项目> [回答人(org 成员)] — [疑问描述]"
---

# Cross-Ask — 跨项目问询讨论

子项目（如 `governance`）对其他项目（尤其主项目 `hashmatrix` 的公共依赖 / 契约 / 承诺）有疑问、但**尚未成型为 Issue** 时，用本 skill 向**目标项目仓库**发起一条 **GitHub Discussion** 灵活讨论；可 @ 指定回答人，讨论达成结论后再**落成 Issue 或其它解决办法**。

**为何用 Discussion 而非 Issue**：此阶段问题尚未定型（不是缺陷 / 需求工单），Discussion 是「还不是 Issue」的天然载体，且可一键 convert 为 Issue（落成）。本组织 **Issue 仍是唯一追踪载体**，Discussion 只承载**前置讨论**。

## 参数解析

`/cross-ask <目标项目> [回答人] — [疑问描述]`
1. **目标项目（必填）**：项目键（`governance` / `webui`…）、仓名（`hashmatrix-governance`）或「主项目 / main」→ 解析为 `HashMatrixData/<repo>`。缺失则询问。映射见 `issue-report` 主文件「仓库映射」表与 `.claude/skills/create-skill/resources/project-profiles.md`。
2. **回答人（可选）**：当前 org 合法成员，用于 @mention（Discussion 无 assignee）。须校验组织成员资格。
3. **疑问描述（可选）**：未给则交互收集。

## 前置依赖

```bash
gh auth status                       # 已登录、对目标仓有读写 Discussion 权限
git remote get-url origin            # 自报提问方（HashMatrixData/<from-repo>）
```

## Step 1. 定位双方 + 校验回答人

- 提问方 = 当前仓（`git remote get-url origin`）。
- 目标方 = 参数解析出的 `HashMatrixData/<repo>`。
- 回答人（若指定）校验为 org 成员：

```bash
gh api "orgs/HashMatrixData/members/<user>" --silent && echo "✓ org 成员" || echo "✗ 非成员/不可见 → 请核对用户名"
```

非成员或拿不准 → 提示用户核对，**不强行 @**。

## Step 2. 组织讨论内容（灵活，非 Issue 模板）

不套 Issue 必填模板；保持「谁问谁、关于什么、差距在哪、期望什么」清晰。正文先用 Write 写入 `/tmp/cross-ask-body.md`：

```markdown
## 背景
- 提问方：<from-project>（`HashMatrixData/<from-repo>`）
- 目标方：<target-project>（`HashMatrixData/<target-repo>`）
- 触及：<公共依赖 / 契约 / 约定 名称>

## 疑问 / 讨论点
<1–3 条：承诺/文档 vs 实际行为的差距，具体到接口/字段/版本>

## 期望与引用
- 期望：<希望对方澄清或调整什么>
- 引用（胜于粘贴）：<契约路径 / PR# / 代码位置 / commit>

## 可能的落点
- [ ] 澄清即可（无需改动）
- [ ] 落成 Issue（之后用 /issue-report 提到 <target-repo>）
- [ ] 其它：<…>

> cc @<回答人>（如指定）
```

标题格式：`[<from-project> → <target-project>] <一句话疑问>`。

## Step 3. 取目标仓 repo ID 与 Discussion 分类

```bash
gh api graphql -f query='
{ repository(owner:"HashMatrixData", name:"<target-repo>") {
    id
    hasDiscussionsEnabled
    discussionCategories(first:25){ nodes{ id name slug isAnswerable } }
} }'
```

- `hasDiscussionsEnabled=false` → **停止**：提示在目标仓 Settings 启用 Discussions，或改走 `/issue-report` 提一条 `question` Issue（由用户决定）。
- 选 category：优先 `isAnswerable=true` 的 Q&A 类（支持「采纳为答案」）；否则 `General`；再否则第一个。记录其 `id`。

## Step 4. 创建 Discussion

```bash
gh api graphql \
  -f query='mutation($repoId:ID!,$catId:ID!,$title:String!,$body:String!){
    createDiscussion(input:{repositoryId:$repoId,categoryId:$catId,title:$title,body:$body}){
      discussion{ url number }
    }
  }' \
  -f repoId='<repo-id>' \
  -f catId='<category-id>' \
  -f title='[<from> → <target>] <疑问>' \
  -F body=@/tmp/cross-ask-body.md
```

> `-F body=@file` 读文件为字符串变量，避免长文本 / 中文 / 代码块在命令行被 shell 解析。

输出返回的 discussion URL，删除临时正文文件。

## Step 5. 后续落点

- **澄清即可**：在讨论里继续，得到答复后标记答案 / 关闭。
- **落成 Issue**：结论清晰且需追踪 → `/issue-report` 提到目标仓（Bug / Feature / Task），正文引用本 Discussion URL；或用 GitHub 原生「Convert to issue」。
- **其它解决办法**：直接在讨论中沉淀结论。

> 反向：若问题其实出在契约 / 公共依赖本身，先用 `/contracts` 查阅最新契约确认差距，再决定讨论或建单。

## 反模式

| 不规范 | 纠正 |
|--------|------|
| 未定型的问题直接糊一个 Issue | 用 Discussion 先讨论，定型后再 `/issue-report` |
| @ 一个非 org 成员或拼错用户名 | Step 1 校验组织成员资格 |
| 把契约大段贴进讨论 | 引用契约路径 / PR / commit（引用胜于粘贴），契约查阅走 `/contracts` |
| 目标仓未启用 Discussions 仍硬建 | Step 3 检测 `hasDiscussionsEnabled`，否则改走 `issue-report` |
| 标题只写「有个问题」 | `[from → target] 一句话疑问`，谁问谁、关于什么一目了然 |

---

红线：讨论标题 / 正文 / 引用**不得**含客户可识别信息、凭据、真实 IP；粘任何片段前先脱敏。仅引用本组织自有仓。
