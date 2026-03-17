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

## 📚 规范导航（两层体系）

### Layer 1️⃣：通用规范（跨项目）

来自 [claude-common](https://github.com/ryuclub/claude-common)，自动同步到 `.claude/.remote-cache/guidelines/`：

| 规范                                                                     | 核心内容                                                          | 何时使用       |
| ------------------------------------------------------------------------ | ----------------------------------------------------------------- | -------------- |
| [01-workflow.md](.remote-cache/guidelines/01-workflow.md)                   | 9步完整工作流：需求→设计→分支→实现→审查→提交→PR→回复→整理 | 开始任何新任务 |
| [02-design-document.md](.remote-cache/guidelines/02-design-document.md)     | 设计文档写法、审查标准                                            | 编写设计方案   |
| [03-branch-management.md](.remote-cache/guidelines/03-branch-management.md) | 分支命名、选择base分支、生命周期                                  | 创建新分支     |
| [04-coding-principles.md](.remote-cache/guidelines/04-coding-principles.md) | 命名、组织、错误处理等语言无关原则                                | 编写代码       |
| [05-review-checklist.md](.remote-cache/guidelines/05-review-checklist.md)   | 代码审查清单和质量标准                                            | 进行代码审查   |
| [06-pre-commit-review.md](.remote-cache/guidelines/06-pre-commit-review.md) | 提交前7项检查清单                                                 | 创建 commit 前 |
| [07-jira-conventions.md](.remote-cache/guidelines/07-jira-conventions.md)   | JIRA 最佳实践                                                     | 操作工单       |

### Layer 2️⃣：项目特化规范（本项目）

在 `.claude/guidelines/` 中，具体约定：

| 规范                                 | 重点                                               | 查看时机         |
| ------------------------------------ | -------------------------------------------------- | ---------------- |
| [workflow.md](./guidelines/workflow.md) | Phase级工作流、灰度部署、设计评审流程              | 理解项目特定流程 |
| [branch.md](./guidelines/branch.md)     | 分支命名：`<type>/$JIRA_PROJECT-XXXX-description`          | 创建分支         |
| [coding.md](./guidelines/coding.md)     | $TECH_STACK编码规范、日志规范、测试覆盖率要求 | 编写代码       |
| [jira.md](./guidelines/jira.md)         | 项目工单约定、脚本创建、必填字段                   | 创建/操作工单    |

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
所有工具和命令可用
```

**可用变量：**

- JIRA：`ATLASSIAN_USERNAME`, `ATLASSIAN_API_KEY`, `ATLASSIAN_DOMAIN`
- AWS：`AWS_REGION`, `AWS_ACCOUNT_ID`, `AWS_PROFILE`
- 数据库：`RDS_ENDPOINT`, `RDS_USERNAME`, `RDS_PASSWORD` 等
- Firebase：`FIREBASE_HTTP_BASE_URL`, `FIREBASE_PROJECT_ID` 等

详见 `.claude/config/claude.env.example` 和 `ENV_LOADING_GUIDE.md`

### 已加载的 Skills

| Skill                  | 用途                       | 调用方式                        |
| ---------------------- | -------------------------- | ------------------------------- |
| `jira-issue-reader`  | 读取和分析 JIRA 工单       | `/jira-issue-reader MOS-XXXX` |
| `jira-manage-ticket` | 创建、更新、删除 JIRA 工单 | 参考 `guidelines/jira.md`     |
| `jira-wiki-reader`   | 读取和解析 Confluence Wiki | `/jira-wiki-reader <url>`     |
| `pr-creator`         | 自动生成 PR 描述和创建 PR  | 参考通用规范                    |

---

## 📂 配置和文件

### 必须了解的文件

| 文件                                  | 用途                                           | 提交?           |
| ------------------------------------- | ---------------------------------------------- | --------------- |
| `.claude/settings.json`             | Claude Code 项目设置、hooks、skills路径        | ✅              |
| `.claude/CLAUDE.md`                 | **本文件** — AI 行为指南                | ✅              |
| `.claude/guidelines/`               | 项目特化规范（workflow, branch, coding, jira） | ✅              |
| `.claude/hooks/auto-load.sh`        | SessionStart hook — 同步rules、加载凭证       | ✅              |
| `.claude/config/claude.env`         | 🔐 敏感信息（本地）                            | ❌ (.gitignore) |
| `.claude/config/claude.env.example` | 配置模板                                       | ✅              |
| `.claude/config/infrastructure.md`  | 非敏感参考信息（AWS、JIRA、RDS等）             | ✅              |
| `.claude/.remote-cache/`            | claude-common 自动同步缓存                     | ❌ (由hook生成) |

### 配置参考

**基础设施参考（非敏感）：** 见 `.claude/config/infrastructure.md`

- 项目代码、AWS区域、资源名称
- JIRA 项目信息
- 数据库端点

**环境变量加载原理：** 

- 官方 `$CLAUDE_ENV_FILE` 机制
- 环境变量持久化到 session

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

## 💡 常见场景

### 需要读取 JIRA 工单

所有 JIRA 凭证已自动加载，可用以下方式读取：

#### 方式1：通过 curl（推荐）

```bash
curl -u $ATLASSIAN_USERNAME:$ATLASSIAN_API_KEY \
  https://$ATLASSIAN_DOMAIN/rest/api/3/issue/MOS-2590 | jq
```

#### 方式2：通过 Python 脚本

```bash
python3 .claude/.remote-cache/skills/jira-issue-reader/scripts/read_issue.py MOS-2590
```

> **注意：** Skills 目前作为参考文档库，不支持直接 slash command 调用

### 需要创建新工单

```bash
参考 .claude/guidelines/jira.md 中的脚本调用方式：

python3 .claude/.remote-cache/.claude/skills/jira-manage-ticket/scripts/jira_api.py \
  create-task "工单标题" "描述" [工时] [类型]
```

### 编写代码注释

```go
✅ 中文注释：
// 计算用户推送令牌
// 从 DynamoDB 读取令牌列表
func GetPushTokens(userID string) ([]string, error) {
    ...
}

❌ 混合英文：
// Get user push tokens
// 从 DynamoDB 读取
```

### 编写 commit message

```bash
✅ 中文，无AI署名：
git commit -m "feat: 实现推送令牌的DynamoDB存储"

❌ 添加AI署名：
git commit -m "feat: 实现推送令牌的DynamoDB存储

Co-Authored-By: Claude Code <noreply@anthropic.com>"
```

### 编写 PR 描述

```markdown
✅ 中文，无AI署名：
## 标题
实现推送令牌的DynamoDB存储优化

## 说明
- 将 Firestore Token 表迁移到 DynamoDB
- 优化查询性能
- 集成测试覆盖率 ≥ 70%

❌ 添加「Generated with Claude Code」
```

---

## 📖 相关文档

**项目特化规范：** `.claude/guidelines/`

- `workflow.md` — 项目工作流
- `branch.md` — 分支管理
- `coding.md` — 编码规约
- `jira.md` — 工单规范

**通用规范：** `.claude/.remote-cache/guidelines/`

- 通过 SessionStart hook 自动同步
- 7个跨项目复用的规范文件

**配置文档：** `.claude/config/`

- `ENV_LOADING_GUIDE.md` — 环境变量加载机制
- `infrastructure.md` — 基础设施参考
- `claude.env.example` — 配置模板

**项目内存：** `.claude/projects/.../memory/`

- `project_mos2590.md` — MOS-2590项目信息
- `feedback_env_loading.md` — 环境变量标准反馈

---

## 🔧 技术细节

### SessionStart Hook 工作流

```
Claude Code 启动
  ↓
SessionStart hook 触发（auto-load.sh）
  ↓
├─ 同步 claude-common（检查缓存TTL）
├─ 加载 .claude/config/claude.env 到 $CLAUDE_ENV_FILE
├─ 生成 .remote-load.json（规范和skills路径）
└─ 输出初始化状态
  ↓
Claude Code 自动 source $CLAUDE_ENV_FILE
  ↓
环境变量对整个 session 可用
```

### 规范加载逻辑

```
任何任务开始
  ├─ 默认加载：.remote-cache/guidelines/01-workflow.md
  ├─ 编码时：.claude/guidelines/coding.md + .remote-cache/guidelines/04-coding-principles.md
  ├─ 分支操作：.claude/guidelines/branch.md + .remote-cache/guidelines/03-branch-management.md
  ├─ 工单操作：.claude/guidelines/jira.md + .remote-cache/guidelines/07-jira-conventions.md
  └─ 代码审查：.remote-cache/guidelines/05-review-checklist.md
```

---

**最后更新：** 2026-03-17
**版本：** v2 - 面向AI的行为指南
