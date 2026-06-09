# 存档结构

## 存放位置

- 运行时目录：`user://saves/`
- 存档槽数量：3 个独立槽位
- 文件命名：`slot_1.json`、`slot_2.json`、`slot_3.json`

## 字段

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `schema_version` | number | 存档结构版本，第一版为 `1`。 |
| `slot_index` | number | 存档槽索引，从 `0` 开始。 |
| `highest_cleared_level` | number | 当前存档最高已通关关卡。 |
| `selected_character` | string | 当前选中角色。 |
| `owned_items` | string[] | 永久道具池。 |
| `equipped_items` | string[] | 当前搭配道具。 |
| `coins` | number | 当前长期金币。 |
| `unlocked_stages` | string[] | 已解锁阶段。 |

## 兼容策略

新增字段必须由 `SaveManager._with_defaults` 补默认值。失败只记录日志，不回退 `highest_cleared_level`、`owned_items`、`unlocked_stages` 等长期资产。
