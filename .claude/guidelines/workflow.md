# 项目工作流（$JIRA_EPIC Firebase → Go + AWS 迁移）

本文档基于 [通用工作流](../.remote-cache/guidelines/01-workflow.md)，针对 $JIRA_EPIC 项目的特化说明。

## 完整流程

### 1. 确认/创建 JIRA 工单

**已有工单：** 从 JIRA 读取工单内容，确认需求范围

**需要新建：** 按照 [jira.md](jira.md) 的规范创建工单
- 类型：Epic（Phase 级）/ Story（功能级）/ Task（技术级）
- 必填字段：标题、描述、修复版本、经办人
- Epic 链接（如为 Story）：$JIRA_EPIC

### 2. 创建设计文档

在 `design/phases/<Phase描述>.md` 或 `design/<TICKET>.md` 中记录：
- 背景和目标
- 需求分析
- 技术方案
- 实现清单
- 灰度策略
- 风险评估

**方案确认：** 需获得 2+ 评审人员同意后再开始实现

### 3. 创建分支

```bash
git checkout main && git pull origin main
git checkout -b <change-type>/$JIRA_PROJECT-XXXX-<description>
```

分支命名规范参考 [branch.md](branch.md)

### 4. 实现代码

编码规约参考 [coding.md](coding.md)

遵循：

- [编码规约](coding.md) 中的 Go 标准和测试要求
- 单元测试覆盖率 ≥ 80%，集成测试覆盖率 ≥ 70%

### 5. 提交前审查

执行 commit 前，必须按照 [通用提交前审查清单](../.remote-cache/.claude/guidelines/06-pre-commit-review.md) 完成全部检查项。

审查结果需提示给用户，获得用户确认后方可提交。

### 6. 提交（commit）

```bash
git add <specific-files>
git commit -m "feat($JIRA_PROJECT-XXXX): description

- 变更点1
- 变更点2"
```

commit message 格式：`<type>(<ticket>): <summary>`

### 7. 推送 & 创建 PR

```bash
git push origin <branch-name>
```

在 GitHub 创建 PR，base 分支为 `main`

PR 描述中包含：
- 变更目的和背景
- 主要改动列表
- 测试确认项
- 灰度部署计划（如适用）

### 8. 处理代码审查意见

PR 创建后，收到 Code Review 评论时：

1. 评估每条意见，确认是否需要修正
2. 修正后推送新 commit
3. 对每条意见逐一回复（说明修正内容或不修正的理由）

### 9. 事后整理

每次完成开发后，检查以下内容：

- **规范更新**：本次遇到的规则注意点，是否需要补充到规范中？
- **Skill 新增**：本次操作中是否出现了可复用的步骤？

## Phase 特化说明

### Phase 1：TokenService 迁移（W1-W6）

关键 Epic：$JIRA_EPIC-phase-1-token-service

工作项：
- Schema 设计
- TokenService Go 实现
- 单元测试编写
- 灰度部署（5% → 20% → 100%）

### Phase 2：GroupService 优化（W7-W10）

关键 Epic：$JIRA_EPIC-phase-2-group-service

工作项：
- GroupService Go 实现
- N+1 查询优化
- 缓存策略设计
- 灰度部署

### 更多 Phases

参考 `design/MIGRATION_ROADMAP.md` 了解完整的 Phase 划分和时间表
