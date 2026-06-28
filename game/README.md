# game

Godot 4 主游戏工程目录。

## 职责

- 承载 Godot 场景、脚本、资源、导出配置和运行态逻辑。
- 只读取后台发布后的配置结果，不承担内容编辑职责。
- 正式实现应优先通过 Godot 编辑器、Godot AI MCP、GDScript 和 Godot 资源链路推进。

## 目录现状

- 当前仅建立目录骨架。
- `project.godot`、场景、脚本和资源尚未创建。
- 涉及场景、运行验证或截图前，必须先确认 Godot AI MCP 连接和编辑器 ready 状态。

## 目标分层

后续实现优先围绕以下运行时读取分层推进：

- `bootstrap/`：游戏启动、发布版本选择、配置系统初始化
- `runtime/config/io/`：读取 `manifest`、`compatibility` 和索引
- `runtime/config/merge/`：执行全局、模块、实体覆盖与默认值合并
- `runtime/config/cache/`：管理模块缓存、关卡缓存、实体缓存
- `runtime/config/compat/`：字段别名、废弃字段、ID 重定向兼容
- `runtime/config/trace/`：输出发布版本、覆盖来源、错误与警告追踪

目标不是在任意脚本里随手读 YAML，而是围绕发布包契约建立稳定读取链。
