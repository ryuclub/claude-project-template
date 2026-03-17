# JIRA 工单规范

## 项目信息

- **项目 Key**: `MOS`
- **主 Epic**: `$JIRA_EPIC`（Firebase → Go + AWS 迁移）
- **工单 URL**: `https://$JIRA_DOMAIN/browse/$JIRA_PROJECT-XXXX`
- **看板**: https://$JIRA_DOMAIN/jira/software/c/projects/MOS/boards/170

## 工单类型

| 类型 | 用途 |
|------|------|
| `长篇故事` | Epic，跨多个 Sprint 的大功能（如 Phase 1、Phase 2 等） |
| `故事` | 用户故事/功能，一个迭代内可完成 |
| `任务` | 技术任务（refactor、docs、chore 等） |
| `缺陷` | Bug 修复 |
| `子任务` | 细分任务，归属于 Story/Task |

## 创建工单时的必填字段

所有新建工单必须包含以下字段：

| 字段 | 值 | 说明 |
|------|-----|------|
| **系统** (customfield_10037) | `Server` | 标记为 Server 系统 |
| **修复版本** (fixVersions) | 最新未发布的 Server 版本 | 如 `Server-1.8.1` |
| **经办人** (assignee) | 创建人自己 | 分配给具体负责人 |

## 使用脚本创建工单

工具路径：`.claude/.remote-cache/.claude/skills/jira-manage-ticket/scripts/jira_api.py`

凭据配置：`.claude/config/claude.env`（参照 `.claude/config/claude.env.example`）

```bash
# 创建独立工单（Story/Task/Bug）
python3 .claude/.remote-cache/.claude/skills/jira-manage-ticket/scripts/jira_api.py \
  create-task "<标题>" "<描述>" [预估工时h] [工单类型]

# 示例：创建 Phase 1 的 Token Schema 设计 Story
python3 .claude/.remote-cache/.claude/skills/jira-manage-ticket/scripts/jira_api.py \
  create-task "设计 DynamoDB Token 表 Schema" \
  "为 TokenService 设计优化的 DynamoDB schema，支持高效查询" 5 故事

# 创建子工单
python3 .claude/.remote-cache/.claude/skills/jira-manage-ticket/scripts/jira_api.py \
  create MOS-1234 "<子任务标题>" "<描述>" [预估工时h]

# 获取工单信息
python3 .claude/.remote-cache/.claude/skills/jira-manage-ticket/scripts/jira_api.py get MOS-1234

# 搜索工单（JQL）
python3 .claude/.remote-cache/.claude/skills/jira-manage-ticket/scripts/jira_api.py \
  search "project = MOS AND assignee = currentUser() AND status != Done"

# 状态变更
python3 .claude/.remote-cache/.claude/skills/jira-manage-ticket/scripts/jira_api.py \
  transition MOS-1234 "进行中"
```

## JIRA 评论格式

JIRA 评论使用 **JIRA Wiki 标记**，禁止使用 Markdown。

| 要素 | 写法 |
|------|------|
| 二级标题 | `h2. 标题` |
| 三级标题 | `h3. 标题` |
| 有序列表 | `# 项目` |
| 无序列表 | `* 项目` |
| 行内代码 | `{{code}}` |
| 粗体 | `*text*` |
| 链接 | `[显示文本\|URL]` |

## 工单与分支的对应

一个工单对应一个分支，分支命名规则参照 [branch.md](branch.md)。

```
Epic $JIRA_EPIC (主迁移 Epic)
  ├─ Story MOS-1234 (Phase 1 - Token Schema)
  │   └─ feat/MOS-1234-token-schema
  │       └─ PR → main
  │
  └─ Story MOS-1235 (Phase 1 - Token Service)
      └─ feat/MOS-1235-token-service
          └─ PR → main
```

## Phase 工单结构

### Phase 1（W1-W6）

主 Epic：`$JIRA_EPIC-phase-1-token-service`

Story 示例：
- `MOS-xxxx`: 设计 DynamoDB Token Schema
- `MOS-xxxx`: 实现 TokenService Go 版本
- `MOS-xxxx`: 编写单元测试
- `MOS-xxxx`: 灰度部署验证

### Phase 2+

参考 `design/MIGRATION_ROADMAP.md` 了解各 Phase 的工单规划
