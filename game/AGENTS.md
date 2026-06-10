# AGENTS.md

## 适用范围

- 本文件适用于本仓库下所有代码、脚本、配置与文档变更。

## 项目基线

- 项目主入口文档为 `项目设计.md`。
- 需求与实施计划默认维护在 `ment/`。
- 测试验证资产默认维护在 `test/` 下的当天时间戳目录。
- 主游戏工程位于 `game/`，第一阶段起使用 Godot 4，不使用 CSS/Web 作为主游戏实现。
- 本项目默认通过 AI 辅助构建 Godot 游戏工程，后续实现优先使用 Godot 编辑器、Godot AI 插件、Godot 场景和 GDScript 资产链路推进。

## 素材获取规则

- 后续 AI 构建项目时，游戏素材优先从以下网站检索和筛选：
  - Kenney：`https://kenney.nl/assets`
  - itch.io 免费 2D 素材：`https://itch.io/game-assets/free/tag-2d`
  - itch.io 免费 Godot 素材：`https://itch.io/game-assets/free/tag-godot`
  - OpenGameArt：`https://opengameart.org/`
  - Godot Asset Library：`https://godotengine.org/asset-library/asset`
  - GodotAssetLibrary.com：`https://godotassetlibrary.com/`
- 选材优先级：优先选择 `CC0`、`MIT`、`Apache-2.0` 等可商用且限制少的素材。
- 使用 `CC-BY` 素材时必须记录作者、来源链接和署名要求。
- 默认避免使用 `GPL`、`CC-BY-SA` 或授权不清的美术、音效和字体素材，除非用户明确确认可接受对应再分发要求。
- 同一阶段尽量使用 1-2 个主风格素材包，避免混用过多作者导致画面风格割裂。
- 下载或导入素材前必须先记录素材来源、许可证和用途，禁止把来源不明的素材直接放入工程。

## 注释任务强制流程

- 触发词：补充注释 / 注意中文编码 / 只补注释 / 注释完善 / 加注释。
- 第一步：先声明命中的注释类 skill。
- 第二步：读取对应 `SKILL.md` 后再改代码。
- 第三步：最终回复给执行证据：改动点、UTF-8、格式化/编译/测试结果。

## 中文编码规则

- 新增或修改中文文档、脚本输出和代码注释时保持 UTF-8。
- Windows PowerShell 读写中文文件必须显式指定 UTF-8。
- 禁止提交乱码、问号替代中文或混乱编码文本。

## 变更最小化

- 每次改动聚焦当前任务目标，不顺手重构无关模块。
- 不回退用户已有改动。
- 注释补充不改变业务逻辑。
