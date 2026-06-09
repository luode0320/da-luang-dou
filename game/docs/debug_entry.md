# 开发测试直达入口

## 入口

主界面提供“开发测试直达”按钮，用于从指定关卡、角色、道具和金币状态开始。

## 默认直达状态

```json
{
  "slot_index": 0,
  "level": 10,
  "character_id": "runner",
  "equipped_items": ["magnet_core"],
  "coins": 30
}
```

## 隔离规则

开发测试直达只修改 `RunState` 当前运行态，不直接写入玩家长期存档。正式玩家流程仍按存档槽最高通关进度推进。
