# 分支管理规则

## 基本规则

- 以 `main` 分支为基点创建新分支
- 完成开发后，向 `main` 分支提交 Pull Request
- 定期删除已合并的远程分支

## 分支命名规范

**格式：** `<change-type>/$JIRA_PROJECT-XXXX-<description>`

| 变更类型 | 用途 | 说明 |
|---------|------|------|
| `feat` | 新功能开发 | 对应 Feature/Story 票 |
| `fix` | Bug 修复 | 对应 Bug 票 |
| `hotfix` | 紧急 Bug 修复 | 直接从 `main` 创建 |
| `perf` | 性能优化 | 对应性能相关票 |
| `refactor` | 代码重构 | 对应重构票 |
| `chore` | 构建/配置变更 | 维护性改动 |
| `docs` | 文档变更 | 仅文档变更 |

## 示例

```
feat/MOS-1234-token-service-migration
fix/MOS-2345-fix-retry-queue-bug
perf/MOS-2569-optimize-group-query
hotfix/MOS-999-critical-error
refactor/MOS-888-simplify-handler
docs/MOS-777-update-readme
chore/MOS-666-update-deps
```

## 分支生命周期

```
main (生产/稳定)
  ↑
  ├─ feat/MOS-234-xxx   (特性开发)
  ├─ fix/MOS-456-xxx    (bug修复)
  └─ hotfix/MOS-999-xxx (紧急修复)
```

## 提交规范

在提交 PR 后会进行自动检查，包括：
- 代码格式（[lint 工具]）
- 单元测试（覆盖率 ≥ 80%）
- 构建验证

**测试覆盖率要求：** Service 层 ≥95%，Repository 层 ≥80%，Handler 层 ≥70%，总体 ≥80%
