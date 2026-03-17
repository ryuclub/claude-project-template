# 基础设施参考

项目配置和基础设施信息（非敏感）。

---

## Jira 配置

```
Jira Domain:  $JIRA_DOMAIN
Project Code: MOS
Main Epic:    $JIRA_EPIC (完整重构方案)
```

## AWS 配置

```
Region:           $AWS_REGION
Account ID:       [XXXX-XXXX-XXXX] (敏感，见 sensitive.env)
CLI Profile:      $AWS_PROFILE-dev
```

## 容器 & 部署

```
ECR Repository:   $AWS_PROFILE-firebase-to-go
ECR Registry:     [ACCOUNT_ID].dkr.ecr.$AWS_REGION.amazonaws.com

ECS Cluster:      $AWS_PROFILE-prod
ECS Service:      pushMessage-service

ALB:              $AWS_PROFILE-prod-alb
Target Group:     pushMessage-tg
```

## 数据库

```
RDS Endpoint:     db.$AWS_PROFILE.internal
RDS Port:         5432
RDS Database:     $AWS_PROFILE_prod
RDS Engine:       PostgreSQL 14+

DynamoDB Tables:
  - $AWS_PROFILE-tokens
  - $AWS_PROFILE-retry-queue

ElastiCache:      redis.$AWS_PROFILE.internal:6379
```

## Git 配置

```
Repository:   https://github.com/$AWS_PROFILE/$AWS_PROFILE-firebaseFunction
Main Branch:  main
Release Tag:  v*
```

## 灰度部署配置

```
阶段 1:  5%  流量，24 小时
阶段 2:  20% 流量，24 小时
阶段 3:  50% 流量，48 小时
阶段 4:  100% 流量，全量

自动回滚条件：
  - 错误率 > 1%
  - P99 延迟 > 500ms
  - 自定义告警触发
```

## 监控 & 告警

```
CloudWatch Logs:     /aws/ecs/$AWS_PROFILE-pushMessage
CloudWatch Metrics:  Custom namespace: MosaviPushService

告警：
  - Error rate > 1%
  - P99 latency > 500ms
  - Cost threshold exceeded
  - DynamoDB throttling
```

---

**敏感信息详见 `claude.env`（本地私有）**

