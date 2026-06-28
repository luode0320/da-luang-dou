# 怪物Boss分层与难度形态规范

## 文档说明

- 用途: 统一项目中普通怪、精英怪、Boss、Boss 终极形态、Boss 狂暴形态、技能分层、难度开放映射和掉落绑定的长期契约。
- 事实来源: `项目设计.md`、`doc/3-实施/2026-06-26_阶段5_GodotAI怪物技能动作构建与后台配置游戏模块怪物.md`、`doc/1-架构/附录-关卡节点与波次奖励规范.md`、`doc/1-架构/附录-后台字段级配置规范.md`、`doc/1-架构/附录-配置目录规范.md`
- 适用范围: `game/data/global/enemies/`、`game/data/global/bosses/`、`game/data/modules/<module_id>/enemies/`、`game/data/modules/<module_id>/bosses/`、难度开放映射、Boss 节点发布校验
- 最近同步时间: 2026-06-28

## 分层总原则

### 1. 怪物层只负责“敌人怎么战斗和掉什么”，不替代关卡节点和地图区域正文

- 怪物正文负责基础属性、技能分层、动作包、掉落表和形态配置。
- 关卡节点负责“这一关刷哪些怪、哪一关出 Boss、Boss 节点如何推进”。
- 地图区域负责“怪从哪里刷、Boss 在哪个区域出现、事件在哪触发”。
- 难度入口负责“当前开放哪些技能、Boss 哪个阶段出现、是否允许狂暴形态”。

### 2. 难度来自技能开放、形态切换和组合压力，不来自同类怪物堆血量

- 同类怪物在不同难度下血量上限不作为主要难度杠杆。
- 普通、噩梦、地狱三档难度主要通过技能开放范围、Boss 阶段出现时机、刷怪组合和狂暴概率形成差异。
- 若确实需要少量数值微调，应通过单独倍率字段显式声明，不允许把“难度设计”简化为统一堆血量。

### 3. Boss 不是单一实体，而是“主实体 + 形态层 + 阶段技能层”的组合

- Boss 主实体负责公共身份、掉落、预览和基础资源绑定。
- Boss 形态层负责基础、终极、狂暴等阶段配置。
- Boss 技能层负责不同阶段开放哪些基础技能与终极技能。

## 目录与载体

### 全局默认怪物目录

```text
game/data/global/enemies/<enemy_id>/
├── config.yaml
├── skills/
│   ├── base.yaml
│   └── ultimate.yaml
├── assets/
└── overrides/
```

### 全局默认 Boss 目录

```text
game/data/global/bosses/<boss_id>/
├── config.yaml
├── phases/
│   ├── base.yaml
│   ├── ultimate.yaml
│   └── enraged.yaml
├── skills/
├── assets/
└── overrides/
```

### 模块怪物与 Boss 覆盖目录

```text
game/data/modules/<module_id>/enemies/<enemy_id>/
game/data/modules/<module_id>/bosses/<boss_id>/
```

## 怪物主配置最小契约

### `enemies/<enemy_id>/config.yaml`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `enemy_id` | string | 怪物稳定 ID。 |
| `name_zh` | string | 怪物中文名。 |
| `enemy_type` | string | `normal` / `elite`。 |
| `base_hp` | number | 基础血量。 |
| `move_speed` | number | 基础移速。 |
| `attack_speed` | number | 基础攻速。 |
| `base_skill_ids` | string[] | 基础技能列表。 |
| `ultimate_skill_ids` | string[] | 终极技能列表；普通怪通常为空。 |
| `animation_pack_id` | string | 动作包引用。 |
| `loot_table_id` | string | 掉落表引用。 |
| `difficulty_unlock_map` | object | 难度开放映射。 |
| `status` | string | `active` / `disabled` / `deprecated`。 |

### 怪物分层最小约束

- `normal` 怪物最多使用 3 个基础技能，不挂终极技能。
- `elite` 怪物允许使用 3 个基础技能 + 1 个终极技能。
- `base_skill_ids` 缺失或引用断链时不得发布。
- `status=disabled` 的怪物不得出现在正式刷怪表中。

## Boss 主配置与形态契约

### `bosses/<boss_id>/config.yaml`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `boss_id` | string | Boss 稳定 ID。 |
| `name_zh` | string | Boss 中文名。 |
| `base_hp` | number | Boss 基础血量。 |
| `animation_pack_id` | string | Boss 公共动作包引用。 |
| `phase_ids` | string[] | Boss 可用形态列表。 |
| `loot_table_id` | string | Boss 掉落表引用。 |
| `difficulty_unlock_map` | object | 不同难度下可出现的形态开放映射。 |
| `status` | string | `active` / `disabled` / `deprecated`。 |

### `phases/<phase_id>.yaml`

| 字段 | 说明 |
| --- | --- |
| `phase_id` | 形态 ID，如 `base`、`ultimate`、`enraged`。 |
| `phase_type` | `base` / `ultimate` / `enraged`。 |
| `base_skill_ids` | 当前形态可用基础技能。 |
| `ultimate_skill_ids` | 当前形态可用终极技能。 |
| `trigger_rule` | 进入该形态的触发条件。 |
| `hp_reset_mode` | 是否恢复满血。 |
| `move_speed_ratio` | 当前形态移速倍率。 |
| `attack_speed_ratio` | 当前形态攻速倍率。 |
| `skill_cooldown_ratio` | 当前形态技能冷却倍率。 |

### Boss 形态最小约束

- `base` 形态至少包含 3 个基础技能 + 1 个终极技能。
- `ultimate` 形态在 `base` 形态能力之上追加 3 个基础技能 + 1 个终极技能。
- `enraged` 形态只允许在配置声明开启且当前难度允许时触发。
- `enraged` 形态默认恢复满血，移速、攻速和技能冷却统一加快一倍，但血量上限不增加。

## 难度开放映射契约

### `difficulty_unlock_map` 建议结构

| 难度 | 开放规则 |
| --- | --- |
| `normal` | 同类怪物本局随机固定 1 个基础技能；Boss 仅按普通难度规则开放基础阶段。 |
| `nightmare` | 普通怪与精英怪开放全部技能；第 10 关基础形态 Boss，第 20 关终极形态 Boss。 |
| `hell` | 普通怪与精英怪开放全部技能；第 5 关基础形态 Boss，第 10 关终极形态 Boss，第 20 关终极形态死亡后按概率触发狂暴。 |

### 最小约束

- `difficulty_unlock_map` 必须明确声明每档难度允许的技能开放范围和 Boss 形态范围。
- 关卡节点与 Boss 出现规则必须与 [附录-关卡节点与波次奖励规范](附录-关卡节点与波次奖励规范.md) 保持一致。
- 若同一 Boss 在某难度不允许进入某形态，运行态不得通过临时逻辑绕开映射限制。

## 掉落与奖励绑定契约

### 普通怪与精英怪

- 普通怪与精英怪通过 `loot_table_id` 引用掉落表。
- 掉落表只负责“掉什么”，不负责声明关卡推进或 Boss 节点。

### Boss

- Boss 掉落仍通过 `loot_table_id` 引用，但允许额外绑定 `boss_reward_pool_id` 作为关卡收束奖励来源。
- Boss 掉落、Boss 收束奖励和关卡通关奖励必须分层，不允许把三种结果混成一个字段。

## 动画、特效与资源绑定契约

### 怪物动作包

- 普通怪和精英怪至少支持待机、移动、攻击、受击、死亡动作。
- Boss 额外支持施法、阶段切换或变身动作。
- 怪物与 Boss 的动作资源必须先经过 `imagegen` 设计预览，再进入 Godot AI MCP 构建与接入。

### 技能与特效绑定

- 基础技能和终极技能允许分别绑定不同特效与投射物资源。
- Boss 不同形态如有不同特效，应在阶段配置中显式声明，而不是靠运行时硬编码猜测。

## 发布前最小校验集合

| 校验项 | 通过条件 | 阻断条件 |
| --- | --- | --- |
| 怪物主配置完整性 | `enemy_id`、技能、动作、掉落齐全 | 关键字段缺失 |
| 普通怪技能分层 | 普通怪不超过 3 个基础技能 | 普通怪挂终极技能或技能数量越界 |
| 精英怪技能分层 | 精英怪为 3 基础 + 1 终极 | 精英怪缺少必要技能层 |
| Boss 形态完整性 | `base`、`ultimate`、`enraged` 形态规则清晰 | Boss 形态缺失或触发条件不明 |
| 难度映射合法性 | 每档难度均声明技能与形态开放规则 | 难度口径缺失或互相冲突 |
| 血量一致性 | 同类怪物不同难度血量口径一致 | 通过难度直接堆同类怪物血量 |
| 掉落表引用 | `loot_table_id` 与奖励池引用合法 | 掉落或奖励引用断链 |
| Boss 节点引用 | Boss 节点可解析到合法 Boss 与合法形态 | 关卡节点引用不存在的 Boss 或形态 |

## 与其他长期专题的关系

- 与 [附录-关卡节点与波次奖励规范](附录-关卡节点与波次奖励规范.md) 的关系:
  - 关卡节点决定何时刷怪、何时出 Boss；
  - 本文决定怪与 Boss 自身如何分层和开放。
- 与 [附录-地图分层与区域机制规范](附录-地图分层与区域机制规范.md) 的关系:
  - 地图区域决定怪从哪里刷、Boss 在哪里出现；
  - 本文不重复定义区域语义。
- 与 [附录-配置目录规范](附录-配置目录规范.md) 的关系:
  - 本文细化 `enemies/` 与 `bosses/` 的正文契约；
  - 总目录分层仍以配置目录规范为准。

## 结论

- 怪物和 Boss 长期不是“单个血条配置”，而是“主实体 + 技能分层 + 难度开放映射 + 掉落绑定 + 形态层”的稳定配置单元。
- 普通怪、精英怪、Boss、Boss 终极形态和 Boss 狂暴形态必须分别建模。
- 后续阶段 5 的后台怪物配置器、Godot 怪物运行态、阶段 6 的 Boss 节点配置和难度验证都应直接复用本文。
