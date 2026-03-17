# 编码规约

本项目使用 Go 语言，遵循官方规范 + 项目特化规则。

## 通用原则

- 代码注释和文档使用中文
- 遵循 Go 官方编码规范（`gofmt` 格式化）
- 错误处理必须显式处理，禁止忽略错误

## 日志规范

- 生产环境日志级别为 `Info`，调试信息使用 `Debug`

**必要日志（Info 级别）：**
- 请求入口：方法、路径
- 认证验证成功/失败
- 关键业务逻辑执行

**调试日志（Debug 级别）：**
- 中间处理步骤
- 参数内容
- 数据库操作详情

**禁止输出：** 敏感信息（密钥、Token、签名参数等）

## 数据库操作

- 读操作使用 `ReadDB`，写操作使用 `WriteDB`
- 数据库重试逻辑遵循配置的重试策略
- 使用参数化查询防止 SQL 注入

## API 文档/Swagger 注释

**规范：** 遵循 Swagger 2.0 规范，使用 `swag` 工具生成文档

### 注释模板

```go
// GetToken godoc
// @Summary 获取 Token 信息
// @Description 根据 pubkey 和 tokenValue 查询 Token 详情
// @Tags Token
// @Accept json
// @Produce json
// @Param pubkey header string true "公钥"
// @Param tokenValue query string true "Token 值"
// @Success 200 {object} res.Result[res.TokenResponse] "成功"
// @Failure 4001 {object} xerror.Error "Token 不存在"
// @Failure 5001 {object} xerror.Error "数据库错误"
// @Router /api/v1/token [get]
func (h *TokenHandler) GetToken(ctx *gin.Context) {
    // 实现
}
```

### 关键规则

| 项目 | 说明 |
|------|------|
| **认证参数** | 使用 `pubkey` header 作为主要认证方式 |
| **成功响应** | 使用泛型 `res.Result[T]`，code 字段为业务码（0=成功） |
| **错误码** | 定义在 `internal/model/xerror/`，形如 4xxx（客户端）或 5xxx（服务端） |
| **路由路径** | 从对应 `RegisterXxxHandler` 函数中确认 |

### HTTP 状态码约定

本项目的 `response.Success` / `response.Error` **始终返回 HTTP 200**，错误信息通过 JSON body 中的 `code` 字段传递。

因此 Swagger 注释中：
- `@Success 200` → HTTP 200，正常响应
- `@Failure <4xxx>` → 业务错误码（非 HTTP 状态码）

### 验证注释

修改 Swagger 注释后必须执行：

```bash
swag init --parseInternal
```

验证生成成功，无报错。

## 错误处理

使用自定义错误类型：

```go
type CustomError struct {
    Code    string      // 错误码（如 "4001"）
    Message string      // 错误描述
    Err     error       // 原始错误（便于追踪）
}
```

## 项目结构

标准的 Go 项目布局：

```
cmd/
  └─ <service>/
      └─ main.go

internal/
  ├─ service/          # 业务逻辑
  ├─ repository/       # 数据访问
  ├─ handler/          # HTTP 请求处理
  ├─ model/            # 数据结构
  ├─ config/           # 配置管理
  └─ middleware/       # 中间件

pkg/
  ├─ awsutil/          # AWS 工具类
  ├─ retry/            # 重试逻辑
  └─ errors/           # 通用错误定义
```

## 编码检查

提交前运行：

```bash
make lint          # [lint 工具] + gofmt
make test          # 单元测试 ≥ 80% 覆盖率
make build         # 构建验证
```

**测试要求：**

- 单元测试覆盖率 ≥ 80%（Service 层 ≥ 95%，Handler 层 ≥ 70%）
- 集成测试覆盖关键业务流程
- 性能基准：单个查询 <1ms，批量 1000 条 <100ms
