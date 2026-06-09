extends RefCounted

const SCHEMA_VERSION := 1
const SLOT_COUNT := 3
const DEFAULT_CHARACTER := "runner"

## 生成默认存档结构说明。
## [参数] slot_index：存档槽索引。
## [返回] Dictionary，默认存档字段。
## 最近修改时间：2026-06-09 01:01:30 存档结构说明。
static func default_slot(slot_index: int) -> Dictionary:
	# 1. 这里和 SaveManager 的默认结构保持同口径，便于文档和工具复用。
	return {
		"schema_version": SCHEMA_VERSION,
		"slot_index": slot_index,
		"highest_cleared_level": 0,
		"selected_character": DEFAULT_CHARACTER,
		"owned_items": [],
		"equipped_items": [],
		"coins": 0,
		"unlocked_stages": ["stage_001"]
	}
