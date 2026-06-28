# admin/backend

后台配置系统 Go 后端目录。

## 规划职责

- 配置草稿管理。
- YAML Schema 校验。
- 引用完整性校验。
- 发布包生成与回滚。
- 版本矩阵、发布记录和权限审计。

## 结构约束

- 单服务入口优先使用根级 `main.go`。
- 私有业务代码进入 `internal/`。
- `internal/service/` 按业务域拆子目录，不在根目录堆业务实现。
- 请求、响应和第三方结果结构体优先放 `internal/entity/<domain>/`。

## 目标分层

后续实现优先围绕以下分层推进：

- `main.go`：启动入口与依赖装配
- `internal/router/`：路由与中间件
- `internal/controller/`：草稿、校验、发布、回滚接口
- `internal/service/draft/`：草稿装载与保存
- `internal/service/validation/`：字段、引用、素材、节点、兼容校验
- `internal/service/publish/`：生成 `manifest`、`compatibility`、`indexes/` 与正文发布包
- `internal/service/rollback/`：回滚稳定版本
- `internal/service/audit/`：发布与回滚审计
- `internal/entity/publish/`：发布包契约结构

目标不是把 YAML 文件直接复制到 `published/`，而是输出一套可校验、可追踪、可回滚的标准发布契约。
