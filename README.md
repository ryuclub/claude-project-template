# claude-project-template

Claude Code 项目模板，支持两层规范体系（通用规范 + 项目特化规范）。采用**环境变量驱动**设计，无需占位符替换。

## 快速开始

```bash
# 1. 复制模板到新项目
git clone <this-repo> my-new-project
cd my-new-project

# 2. 初始化配置文件
cp .claude/config/claude.env.example .claude/config/claude.env

# 3. 编辑配置，填写项目信息
vi .claude/config/claude.env

# 4. 完成！Claude Code 启动时自动加载所有环境变量
```

## 环境变量配置

Claude Code 和规范脚本所需的凭证和配置通过 `.claude/config/claude.env` 提供。

### 必填变量

```bash
# Claude-common 同步配置（SessionStart hook 自动使用）
COMMON_REPO_URL="https://github.com/ryuclub/claude-common.git"
COMMON_CACHE_DIR=".claude/.remote-cache"
COMMON_CACHE_TTL="86400"

# Atlassian JIRA（AI 调用 JIRA skill 需要）
ATLASSIAN_USERNAME="your-email@example.com"
ATLASSIAN_API_KEY="your-api-token"
ATLASSIAN_DOMAIN="mycompany.atlassian.net"
JIRA_PROJECT="ABC"

# GitHub（AI 调用 PR skill 需要）
GITHUB_ORG="your-org"
GITHUB_REPO="your-repo"
GIT_REPO_URL="https://github.com/${GITHUB_ORG}/${GITHUB_REPO}.git"
GIT_BRANCH_BASE="main"
```

详见 `.claude/config/claude.env.example`

## 两层规范体系

### Layer 1：通用规范（跨项目）

来自 `claude-common` 仓库，由 `auto-load.sh` 自动同步到 `.claude/.remote-cache/guidelines/`：

- `01-workflow.md` — 9步通用开发工作流
- `02-design-document.md` — 设计文档编写标准
- `03-branch-management.md` — Git 分支管理
- `04-coding-principles.md` — 通用编码原则
- `05-review-checklist.md` — 代码审查清单
- `06-pre-commit-review.md` — 提交前 7 项检查
- `07-jira-conventions.md` — JIRA 工单约定

### Layer 2：项目特化规范（本项目）

存储在 `.claude/guidelines/`，包含项目特定的工作流、编码规范等：

- `workflow.md` — 项目工作流规范
- `branch.md` — 分支命名规则（使用 `$JIRA_PROJECT` 等变量）
- `coding.md` — 编码语言规范
- `jira.md` — 项目工单规范（使用 `$JIRA_DOMAIN` 等变量）

这些文件中的 `$VARIABLE` 引用在 Claude Code 启动时自动展开。

## 工作原理

```
Claude Code 启动
  ↓
SessionStart hook (auto-load.sh)
  ├─ 加载 .claude/config/claude.env 到环境
  ├─ 同步 claude-common（检查 24h TTL）
  └─ 生成规范和 Skills 索引
  ↓
所有环境变量和规范可用，AI 助手准备就绪
```

## 文件结构

```
.claude/
├── CLAUDE.md                      # AI 行为指南（核心）
├── README.md                      # .claude 目录说明
├── settings.json                  # Claude Code 项目设置
├── hooks/
│   ├── auto-load.sh              # SessionStart hook
│   └── verify-sync.sh            # 验证脚本
├── guidelines/                    # 项目特化规范（4 个文件）
│   ├── workflow.md
│   ├── branch.md
│   ├── coding.md
│   └── jira.md
├── config/
│   ├── claude.env.example        # 配置模板（✅ 提交）
│   ├── claude.env                # 实际凭证（❌ 不提交）
│   └── infrastructure.md         # 基础设施参考
└── skills/                        # 项目特定 Skills（通常为空）
```

## 提交清单

**✅ 应提交到 Git:**
- `.claude/CLAUDE.md`
- `.claude/README.md`
- `.claude/settings.json`
- `.claude/hooks/` 所有脚本
- `.claude/guidelines/` 所有规范文件
- `.claude/config/claude.env.example`（配置模板）
- `.claude/config/infrastructure.md`（基础设施参考）

**❌ 不应提交到 Git:**
- `.claude/config/claude.env`（本地敏感凭证，已在 .gitignore 中）
- `.claude/.remote-cache/`（运行时生成的缓存）
- `.claude/.remote-load.json`（运行时生成的索引）

## 常见操作

### 强制重新同步远程规范

删除缓存时间戳，下次启动会强制更新：

```bash
rm .claude/.remote-cache/.sync
bash .claude/hooks/auto-load.sh
```

### 修改 claude-common 源

编辑 `.claude/settings.json` 中的 `remoteRules.repository`：

```json
"remoteRules": {
  "repository": "https://github.com/your-new-org/claude-common.git",
  "cacheTTL": 86400,
  "cacheDir": ".claude/.remote-cache"
}
```

然后手动执行：
```bash
bash .claude/hooks/auto-load.sh
```

### 验证同步状态

```bash
bash .claude/hooks/verify-sync.sh
```

输出应包含：
```
✓ Remote cache exists
✓ Git repository initialized
✓ 8 guidelines found
✓ Skills configured
✓ Config generated
```

## 为什么用环境变量而不是占位符替换？

| 方案 | 占位符替换 | 环境变量 |
|------|-----------|---------|
| 初始化步骤 | 需要脚本自动替换文件 | 只需编辑一个文件 |
| 模板复用性 | 低（文件被修改） | 高（文件保持通用） |
| 配置管理 | 分散在多个文件中 | 集中在 claude.env |
| CI/CD 集成 | 需要修改步骤 | 直接环境变量注入 |
| 维护成本 | 高（多个版本变异） | 低（单一版本） |

## 项目初始化检查清单

新项目初始化完成后，确认以下项：

- [ ] 复制 `claude.env.example` 为 `claude.env`
- [ ] 填写 `claude.env` 中所有必填环境变量
- [ ] 确保 `claude.env` 已在 `.gitignore` 中
- [ ] 运行 `bash .claude/hooks/auto-load.sh` 验证同步
- [ ] 提交 `.claude/` 目录（除 `claude.env`）
- [ ] 团队成员可通过 `cp claude.env.example claude.env` 本地创建

## .claude 目录结构

```
.claude/
├── CLAUDE.md                    # ⭐ AI 行为指南（核心）
├── settings.json                # Claude Code 项目设置
├── .remote-load.json            # 自动生成：规范索引
├── hooks/
│   ├── auto-load.sh             # SessionStart hook
│   └── verify-sync.sh           # 验证脚本
├── guidelines/                  # 项目特化规范（4个文件）
│   ├── workflow.md              # 项目工作流规范
│   ├── branch.md                # 分支管理规范
│   ├── coding.md                # 编码规约
│   └── jira.md                  # JIRA 工单规范
├── config/
│   ├── claude.env               # 🔐 本地凭证（不提交）
│   ├── claude.env.example       # 凭证模板（提交）
│   └── infrastructure.md        # 基础设施参考（提交）
├── skills/                      # 项目特定 Skills（通常为空）
└── .remote-cache/               # 自动生成缓存（不提交）
    ├── guidelines/              # 同步的通用规范
    ├── skills/                  # 同步的 Skills
    └── .sync                    # 缓存时间戳
```

## AI 助手工作流

当 Claude Code 启动时：

```
1. SessionStart hook 触发
    ↓
2. 执行 auto-load.sh
    ├─ 同步 claude-common（检查 24h TTL）
    ├─ 加载 .claude/config/claude.env 到环境
    └─ 生成规范和 Skills 索引
    ↓
3. AI 助手准备就绪
```

## 故障排查

### auto-load.sh 执行失败

**检查步骤：**

```bash
# 检查 git 和网络
git --version
ping github.com

# 手动测试克隆
git clone --depth=1 https://github.com/ryuclub/claude-common.git /tmp/test-clone

# 检查脚本语法
bash -n .claude/hooks/auto-load.sh
```

**常见原因：**

- git 未安装或无法访问 GitHub
- `remoteRules.repository` URL 错误
- 网络问题

### 环境变量未加载

**检查步骤：**

```bash
# 检查 claude.env 存在性
ls -la .claude/config/claude.env

# 手动测试加载
set -a
source .claude/config/claude.env
set +a
echo $JIRA_PROJECT
```

**常见原因：**

- `claude.env` 文件不存在
- 文件格式错误（特殊字符未转义）
- 变量名包含特殊字符

### 同步缓存过旧

强制更新缓存（默认 24 小时更新一次）：

```bash
rm .claude/.remote-cache/.sync
bash .claude/hooks/auto-load.sh
```

## 环境变量用法

### 在 Bash 中

```bash
curl -u $ATLASSIAN_USERNAME:$ATLASSIAN_API_KEY \
  https://$ATLASSIAN_DOMAIN/rest/api/3/issue/$JIRA_PROJECT-2590
```

### 在 Python 中

```python
import os
jira_key = os.getenv('JIRA_PROJECT')
api_token = os.getenv('ATLASSIAN_API_KEY')
```

### 在 Go 中

```go
jiraProject := os.Getenv("JIRA_PROJECT")
awsRegion := os.Getenv("AWS_REGION")
```

## 典型提示词示例

### 1. 查看已加载的规范和 Skills

**提示词：**
```
显示所有已加载的规范文件和 Skills，简要说明它们的用途
```

**预期输出：**
- 列出 `.claude/.remote-cache/guidelines/` 中的 8 个通用规范
- 列出 `.claude/guidelines/` 中的 4 个项目规范
- 列出已加载的 Skills（如 jira-issue-reader, jira-manage-ticket, pr-creator 等）

---

### 2. 读取 JIRA 工单

**提示词：**
```
读取 JIRA 工单 MOS-2590，告诉我工单的标题、描述、状态和经办人
```

**工作原理：**
- AI 使用 JIRA skill 调用 curl 或 Python 脚本
- 需要 `ATLASSIAN_USERNAME`, `ATLASSIAN_API_KEY`, `ATLASSIAN_DOMAIN`, `JIRA_PROJECT` 已配置
- 脚本：`.claude/.remote-cache/skills/jira-issue-reader/scripts/read_issue.py`

---

### 3. 创建 JIRA 工单

**提示词：**
```
为 MOS 项目创建一个 Story 工单，标题为"实现 DynamoDB Token Schema"，
描述为"为 TokenService 设计优化的 DynamoDB schema，支持高效查询"，
估时 5 小时
```

**工作原理：**
- AI 调用 JIRA manage skill（jira-manage-ticket）
- 脚本：`.claude/.remote-cache/skills/jira-manage-ticket/scripts/jira_api.py`
- 自动关联到 `JIRA_PROJECT`

---

### 4. 创建分支和提交

**提示词：**
```
根据规范为工单 MOS-2590 创建特性分支，分支名应该是什么?
```

**工作原理：**
- AI 查询 `.claude/guidelines/branch.md` 了解分支命名规范
- 规范中使用 `$JIRA_PROJECT` 占位符，自动替换为 "MOS"
- 返回建议的分支名：`feat/MOS-2590-description`

---

### 5. 提交前审查

**提示词：**
```
我要提交代码了，请按照项目的提交前审查清单检查我的改动
```

**工作原理：**
- AI 加载 `.remote-cache/guidelines/06-pre-commit-review.md`（通用清单）
- AI 加载 `.claude/guidelines/coding.md`（项目特化清单）
- 执行 7 项检查并返回审查报告

---

### 6. 编写 JIRA 评论

**提示词：**
```
在 JIRA 工单 MOS-2590 上添加评论，告诉项目组"设计已完成，进入实现阶段"，
格式使用 JIRA Wiki 标记（不是 Markdown）
```

**工作原理：**
- AI 调用 JIRA skill 写入评论
- 自动使用 JIRA Wiki 标记格式（h2., *, [|] 等）
- 遵循 `.claude/guidelines/jira.md` 中的评论规范

---

### 7. 创建 PR

**提示词：**
```
我的分支是 feat/MOS-2590-token-schema，
请为它创建一个 PR，目标是 main 分支，
PR 标题应该体现工单号和功能
```

**工作原理：**
- AI 调用 PR skill（pr-creator）
- 需要 `GITHUB_ORG`, `GITHUB_REPO`, `GIT_REPO_URL`, `GIT_BRANCH_BASE` 已配置
- 自动提取 commit message 生成 PR 描述

---

### 8. 查询编码规范

**提示词：**
```
我在写 Go 代码，项目对日志、错误处理、测试覆盖率有什么要求?
```

**工作原理：**
- AI 加载 `.claude/guidelines/coding.md`
- 返回项目的 Go 编码规范、日志规范、测试覆盖率要求
- 如需通用原则，查询 `.remote-cache/guidelines/04-coding-principles.md`

---

## 相关文档

- `.claude/CLAUDE.md` — AI 行为指南
- `.claude/guidelines/workflow.md` — 项目工作流
- `.claude/guidelines/coding.md` — 编码规约
- `.claude/guidelines/jira.md` — JIRA 规范

---

**模板版本：** v2（环境变量驱动）
**最后更新：** 2026-03-17
**状态：** ✅ 准备使用
