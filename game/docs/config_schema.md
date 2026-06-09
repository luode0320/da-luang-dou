# 配置结构

## 配置入口

配置统一由 `ConfigDb` 加载，第一版使用 JSON 文件：

- `data/stages/stage_001.json`
- `data/levels/level_001_010.json`
- `data/characters.json`
- `data/enemies.json`
- `data/items.json`
- `data/drops.json`
- `data/i18n/zh_cn.json`

## 关键规则

- 阶段必须包含 `level_start`、`level_end`、`item_carry_limit`。
- 第一阶段必须配置 1-10 关。
- 每个角色必须绑定固定 `weapon` 和固定 `skill`。
- 每个关卡必须通过 `enemy_groups` 描述怪物行为标签和刷新节奏。
- 用户可见文案必须通过 `zh_cn.json` 管理，不直接硬编码到主流程。
