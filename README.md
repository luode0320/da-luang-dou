# da-luang-dou

`da-luang-dou` 是一款面向 Steam/PC 的 2D 自动战斗闯关游戏项目。当前仓库处于“规则、设计文档、阶段拆分和目录骨架”阶段，后续实现以 Godot 4 主游戏工程和 Go + Vue 后台配置系统为核心。

## 当前入口

- 项目主入口：[项目设计.md](项目设计.md)
- 长期记忆：[PROJECT_MEMORY.md](PROJECT_MEMORY.md)
- 长期风格：[PROJECT_STYLE.md](PROJECT_STYLE.md)
- 文档目录：[doc/README.md](doc/README.md)
- 按领域入口：[doc/1-架构/README.md](doc/1-架构/README.md)、[doc/2-需求/README.md](doc/2-需求/README.md)、[doc/3-实施/README.md](doc/3-实施/README.md)、[doc/4-bugs/README.md](doc/4-bugs/README.md)、[doc/5-tests/README.md](doc/5-tests/README.md)、[doc/6-审查/README.md](doc/6-审查/README.md)、[doc/7-验收/README.md](doc/7-验收/README.md)

## 根 README 不负责什么

- 不重复 `项目设计.md` 的项目目标、当前实现状态表和下一步优先级。
- 不重复 `doc/1-架构/README.md` 的架构目录导航、专题速查和历史专题承接映射。
- 不重复 `doc/2-需求/README.md`、`doc/3-实施/README.md` 等子目录首页的详细导航。
- 不长期维护历史实施计划整理说明入口；这类过程说明统一留在 `doc/6-审查/`。

## 核心约束

- 主游戏使用 Godot 4，工程目录为 `game/`。
- 后台配置系统位于 `admin/`，拆分为 Go 后端和 Vue 前端。
- 游戏内容以后台发布后的 YAML 配置包为真源，游戏侧只负责加载、校验、合并、运行和渲染。
- 新增模块、关卡、角色、怪物、地图、技能、道具和掉落规则时，原则上只改配置，不改业务代码。
- 正式 2D 素材先走 `2d-asset-design` / `imagegen` 设计，再进入 Godot 构建与接入流程。

## 目录总览

| 路径 | 职责 |
| --- | --- |
| `AGENTS.md` | Codex 仓库级执行规则。 |
| `PROJECT_MEMORY.md` | 长期项目事实记忆。 |
| `PROJECT_STYLE.md` | 长期项目风格记忆。 |
| `项目设计.md` | 项目级设计主入口。 |
| `doc/` | 项目通用文档目录入口。 |
| `doc/1-架构/README.md` | 架构目录入口与归档边界。 |
| `doc/2-需求/README.md` | 需求目录入口与命名约定。 |
| `doc/3-实施/README.md` | 实施目录入口与阶段/实施文档导航。 |
| `doc/4-bugs/README.md` | Bug 目录入口与单问题归档方式。 |
| `doc/5-tests/README.md` | 测试目录入口与时间戳验证资产归档方式。 |
| `doc/6-审查/README.md` | 审查目录入口与结构归位/规则核对落点。 |
| `doc/7-验收/README.md` | 验收目录入口与验收文档导航。 |
| `doc/1-架构/` | 配置、后台、字段、读取和编码规范。 |
| `doc/2-需求/` | 项目总需求、需求索引和需求配套 SVG 图表。 |
| `doc/3-实施/` | 阶段拆分、实施总览和阶段实施文档。 |
| `doc/4-bugs/` | Bug 记录、定位、验证和配套 SVG 图表。 |
| `doc/5-tests/` | 验证脚本、测试说明、回归记录和临时验证资产。 |
| `doc/6-审查/` | 结构归位、实现审查和规则核对记录。 |
| `doc/7-验收/` | 验收标准和最终验收文档。 |
| `game/` | Godot 4 主游戏工程。 |
| `game/data/` | 游戏侧读取的 YAML 发布配置真源。 |
| `admin/` | 后台配置系统目录，拆分为 Go 后端与 Vue 前端。 |
| `tools/windows/` | Windows 打包、安装器和发布辅助脚本。 |
