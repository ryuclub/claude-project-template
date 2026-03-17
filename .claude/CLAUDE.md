# AI 指南

本文件由 AI 助手自动读取，为项目工作提供行为规则和规范指导。

---

## 🎯 AI 行为约定

### 输出要求

- **语言**：始终使用中文
  - 代码注释 → 中文
  - JIRA 评论 → 中文（使用JIRA Wiki标记，禁止Markdown）
  - Commit messages → 中文
  - PR 内容（标题、描述、Review评论）→ 中文

### 署名规则

- ❌ 不添加「Co-Authored-By: Claude」到 commit message
- ❌ 不添加「Generated with Claude Code」到 PR 或 Review 评论
- ❌ 不在 JIRA 评论中提及 AI 工具名称
- ✅ 代码质量本身说话

### 工作流约定

开始任何工作前，理解项目的两层规范体系和具体工作流（见下文）。

---

## 📚 规范导航

### 项目规范 (`.claude/guidelines/`)

| 规范                                       | 用途                                              | 何时查看         |
| ------------------------------------------ | ------------------------------------------------- | ---------------- |
| [workflow.md](./guidelines/workflow.md)    | Phase级工作流、灰度部署、设计评审                 | 理解项目流程     |
| [branch.md](./guidelines/branch.md)        | 分支命名规则、创建分支                            | 创建分支         |
| [coding.md](./guidelines/coding.md)        | 编码规范、日志、测试覆盖率                        | 编写代码         |
| [jira.md](./guidelines/jira.md)            | 工单约定、脚本、必填字段                          | 操作工单         |

### 通用规范 (`.claude/.remote-cache/guidelines/`)

自动同步自 [claude-common](https://github.com/ryuclub/claude-common)：

- `01-workflow.md` — 9步完整工作流
- `02-design-document.md` — 设计文档规范
- `03-branch-management.md` — 分支策略
- `04-coding-principles.md` — 语言无关原则
- `05-review-checklist.md` — 代码审查标准
- `06-pre-commit-review.md` — 提交前检查清单
- `07-jira-conventions.md` — JIRA 最佳实践

---

## ⚙️ 系统自动化

### 环境变量和凭证

**自动加载机制：** SessionStart hook 通过 `$CLAUDE_ENV_FILE` 自动加载凭证

```
.claude/config/claude.env（本地，.gitignore）
    ↓
SessionStart hook 读取
    ↓
导出到 Claude Code 环境
    ↓
AI 和规范脚本可用
```

**必填变量：**

- Claude 自动化：`COMMON_REPO_URL`, `COMMON_CACHE_DIR`, `COMMON_CACHE_TTL`
- JIRA：`ATLASSIAN_USERNAME`, `ATLASSIAN_API_KEY`, `ATLASSIAN_DOMAIN`, `JIRA_PROJECT`
- GitHub：`GITHUB_ORG`, `GITHUB_REPO`, `GIT_REPO_URL`, `GIT_BRANCH_BASE`

详见 `.claude/config/claude.env.example`

### 已加载的 Skills

| Skill                | 用途                  |
| -------------------- | --------------------- |
| `jira-manage-ticket` | JIRA 工单管理（CRUD） |
| `jira-wiki-reader`   | 读取 Confluence Wiki  |
| `pr-creator`         | 自动生成 PR 和创建 PR |

使用方法详见项目规范文档。

---

## 📂 配置和文件

### 必须了解的文件

| 文件                                  | 用途                                           | 提交?           |
| ------------------------------------- | ---------------------------------------------- | --------------- |
| `.claude/settings.json`             | Claude Code 项目设置、hooks、skills路径        | ✅              |
| `.claude/CLAUDE.md`                 | **本文件** — AI 行为指南                | ✅              |
| `.claude/guidelines/`               | 项目特化规范（workflow, branch, coding, jira） | ✅              |
| `.claude/hooks/init.sh`        | SessionStart hook — 同步rules、加载凭证       | ✅              |
| `.claude/config/claude.env`         | 🔐 敏感信息（本地）                            | ❌ (.gitignore) |
| `.claude/config/claude.env.example` | 配置模板                                       | ✅              |
| `.claude/config/infrastructure.md`  | 非敏感参考信息（AWS、JIRA、RDS等）             | ✅              |
| `.claude/.remote-cache/`            | claude-common 自动同步缓存                     | ❌ (由hook生成) |

### 配置参考

详见 `.claude/config/` 中的文档：

- `infrastructure.md` — AWS、JIRA、数据库等参考信息
- `claude.env.example` — 配置模板
- `.claude/config/claude.env` — 本地凭证（.gitignore）

---

## 🚀 工作流快速参考

### 开始一个任务

```
1. 确认/创建 JIRA 工单 (MOS-XXXX)
   └─ 参考: .claude/guidelines/jira.md

2. 创建设计文档（可选但推荐）
   └─ design/phases/ 或 design/MOS-XXXX.md
   └─ 参考: .remote-cache/guidelines/02-design-document.md

3. 创建分支
   └─ git checkout -b feat/MOS-XXXX-description
   └─ 参考: .claude/guidelines/branch.md

4. 编写代码
   └─ 参考: .claude/guidelines/coding.md
   └─ Go格式化、日志规范、≥80%测试覆盖率

5. 提交前审查（必需）
   └─ 执行 .remote-cache/guidelines/06-pre-commit-review.md 的7项检查
   └─ 获得用户确认

6. 创建 commit
   └─ 使用中文 commit message（无「Co-Authored-By」）

7. 创建 PR
   └─ 使用中文标题和描述（无「Generated with」署名）

8. 响应 review
   └─ 按review意见修改，重新提交

9. 合并和整理
   └─ 更新 JIRA 工单状态
```

详细版本见 `.claude/guidelines/workflow.md`

---

**最后更新：** 2026-03-17 | **版本：** v2
