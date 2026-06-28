# admin

后台配置系统目录，负责把游戏内容生产流程变成可编辑、可校验、可预览、可发布的配置管线。

## 子目录

- `backend/`：Go 后端，负责配置 API、校验、发布、回滚、权限审计和版本矩阵。
- `frontend/`：Vue 前端，负责配置编辑器、素材绑定、预览、发布操作和校验反馈。

## 约束

- 后台生成的发布结果是游戏侧默认真源。
- 能通过后台配置表达的内容，不写死在 Godot 或脚本里。
- Go 后端后续应按 `internal/router`、`internal/controller`、`internal/service/<domain>`、`internal/entity/<domain>`、`common/repository` 等职责分层落位。
