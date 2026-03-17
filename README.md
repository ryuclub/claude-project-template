# claude-project-template

Claude Code 项目模板，支持两层规范体系（通用规范 + 项目特化规范）。采用**环境变量驱动**设计，无需占位符替换。

## 快速开始（推荐）

使用初始化脚本直接从 GitHub 创建新项目：

```bash
bash <(curl -s https://raw.githubusercontent.com/ryuclub/claude-project-template/main/init-project.sh) my-project
```

或使用 wget：

```bash
bash <(wget -qO- https://raw.githubusercontent.com/ryuclub/claude-project-template/main/init-project.sh) my-project
```

脚本会自动：
1. 创建项目目录
2. 获取模板（首次clone或更新现有）
3. 复制.claude配置
4. 初始化claude.env
5. 提示后续配置步骤

---

## 手动快速开始

如果不想用脚本，也可以手动执行：

```bash
# 1. 创建项目目录
mkdir my-project
cd my-project

# 2. 获取模板（首次 clone，或 pull 更新现有的）
if [ -d claude-project-template ]; then
  cd claude-project-template && git pull && cd ..
else
  git clone https://github.com/ryuclub/claude-project-template.git
fi

# 3. 复制 .claude 目录到你的项目
cp -r claude-project-template/.claude .

# 4. 初始化配置文件
cp .claude/config/claude.env.example .claude/config/claude.env

# 5. 编辑配置，填写凭证和项目信息
vi .claude/config/claude.env

# 6. （可选）初始化项目的 git
git init
git remote add origin https://github.com/YOUR_ORG/my-project.git
git add .claude/
git commit -m "初始化 Claude Code 配置"

# 7. 完成！Claude Code 启动时自动加载环境变量
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

Claude Code 启动时，SessionStart hook (`auto-load.sh`) 自动：

1. 加载 `.claude/config/claude.env` 到环境
2. 同步 `claude-common` 规范（24h 缓存）
3. 生成规范和 Skills 索引

AI 助手准备就绪，可使用所有环境变量和规范。

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

## 项目初始化检查清单

新项目初始化完成后，确认以下项：

- [ ] 复制 `claude.env.example` 为 `claude.env`
- [ ] 填写 `claude.env` 中所有必填环境变量
- [ ] 确保 `claude.env` 已在 `.gitignore` 中
- [ ] 运行 `bash .claude/hooks/auto-load.sh` 验证同步
- [ ] 提交 `.claude/` 目录（除 `claude.env`）
- [ ] 团队成员可通过 `cp claude.env.example claude.env` 本地创建

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

## 典型提示词示例

### 1. 查看已加载的规范和 Skills

```
显示所有已加载的规范文件和 Skills
```

### 2. 读取 JIRA 工单

```
读取 JIRA 工单 MOS-2590 的标题、描述和状态
```

### 3. 创建 JIRA 工单

```
为 MOS 项目创建 Story 工单，标题"实现 Token Schema"，估时 5 小时
```

### 4. 创建分支

```
根据规范为工单 MOS-2590 创建特性分支名
```

### 5. 提交前审查

```
按照项目的提交前审查清单检查我的改动
```

### 6. 编写 JIRA 评论

```
在 JIRA 工单 MOS-2590 上添加评论，用 JIRA Wiki 格式
```

### 7. 创建 PR

```
为分支 feat/MOS-2590-token-schema 创建 PR 到 main
```

### 8. 查询编码规范

```
项目对 Go 代码的日志、错误处理、测试覆盖率有什么要求?
```

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
