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

所有项目特化信息都通过 `.claude/config/claude.env` 提供，模板文件保持通用，无需修改。

### 必填变量

```bash
# Atlassian JIRA（必须）
ATLASSIAN_USERNAME="your-email@example.com"
ATLASSIAN_API_KEY="your-api-token"
ATLASSIAN_DOMAIN="mycompany.atlassian.net"
JIRA_PROJECT="ABC"

# Git（必须）
GIT_REPO_OWNER="your-org"
GIT_REPO_NAME="your-repo"
```

### 可选变量

根据项目需要添加（详见 `.claude/config/claude.env.example`）：

- **AWS**: `AWS_REGION`, `AWS_ACCOUNT_ID`, `AWS_PROFILE`
- **数据库**: `RDS_ENDPOINT`, `RDS_USERNAME`, `RDS_PASSWORD` 等
- **容器**: `ECR_REPO_NAME`, `ECS_CLUSTER_NAME`
- **灰度部署**: `CANARY_WEIGHT_PHASE1_NEW` 等
- **业务系统**: `STRIPE_API_KEY`, `KAFKA_BROKERS` 等
- **日志监控**: `CLOUDWATCH_LOG_GROUP`, `DD_API_KEY` 等

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
- `coding.md` — 编码语言规范（引用 `$TECH_STACK`）
- `jira.md` — 项目工单规范（使用 `$JIRA_DOMAIN` 等变量）

所有这些文件中的 `$VARIABLE` 引用会在 Claude Code 启动时自动展开。

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

## 相关文档

- `.claude/CLAUDE.md` — AI 行为指南
- `.claude/guidelines/workflow.md` — 项目工作流
- `.claude/guidelines/coding.md` — 编码规约
- `.claude/guidelines/jira.md` — JIRA 规范

---

**模板版本：** v2（环境变量驱动）
**最后更新：** 2026-03-17
**状态：** ✅ 准备使用
