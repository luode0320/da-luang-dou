extends Node

const SAVE_DIR := "user://saves"
const SLOT_COUNT := 3
const SCHEMA_VERSION := 1

var slots: Array[Dictionary] = []

## 初始化并读取三个独立存档槽。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 01:12:25 使用 user 路径目录创建。
func load_slots() -> void:
	# 1. 存档目录缺失时创建，避免首次启动无法写入。
	var user_dir := DirAccess.open("user://")
	if user_dir != null and not user_dir.dir_exists("saves"):
		user_dir.make_dir_recursive("saves")
	slots.clear()
	for index in range(SLOT_COUNT):
		slots.append(_load_slot(index))

## 获取指定存档槽。
## [参数] slot_index：存档槽索引，从 0 开始。
## [返回] Dictionary，返回兼容后的存档数据。
## 最近修改时间：2026-06-09 01:01:30 存档读取接口。
func get_slot(slot_index: int) -> Dictionary:
	# 1. 越界时回退到第一个存档槽，避免开发入口传错导致崩溃。
	if slot_index < 0 or slot_index >= slots.size():
		return slots[0]
	return slots[slot_index]

## 保存指定存档槽。
## [参数] slot_index：存档槽索引；data：存档数据。
## [返回] bool，写入成功返回 true。
## 最近修改时间：2026-06-09 01:01:30 存档写入接口。
func save_slot(slot_index: int, data: Dictionary) -> bool:
	# 1. 存档写入前统一补版本和槽位，保证后续兼容迁移有锚点。
	var normalized := _with_defaults(data, slot_index)
	var path := _slot_path(slot_index)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("存档写入失败: %s" % path)
		return false
	file.store_string(JSON.stringify(normalized, "\t"))
	slots[slot_index] = normalized
	print("SAVE_WRITE slot=%d highest_level=%d coins=%d items=%s" % [
		slot_index,
		normalized.get("highest_cleared_level", 0),
		normalized.get("coins", 0),
		str(normalized.get("owned_items", []))
	])
	return true

## 重置指定存档槽。
## [参数] slot_index：存档槽索引。
## [返回] Dictionary，返回重置后的默认存档。
## 最近修改时间：2026-06-09 01:01:30 支持玩家主动重置单槽。
func reset_slot(slot_index: int) -> Dictionary:
	# 1. 只重置被选择的槽，避免污染其他存档。
	var fresh := _default_slot(slot_index)
	save_slot(slot_index, fresh)
	return fresh

## 记录通关结果和长期资产。
## [参数] slot_index：存档槽索引；level_number：通关关卡；coins_delta：新增金币。
## [返回] Dictionary，返回保存后的存档。
## 最近修改时间：2026-06-09 01:14:48 拆分通关收益和金币抽道具。
func record_clear(slot_index: int, level_number: int, coins_delta: int) -> Dictionary:
	# 1. 成功通关只推进最高关卡，不回退历史进度。
	var data := get_slot(slot_index).duplicate(true)
	data["highest_cleared_level"] = max(int(data.get("highest_cleared_level", 0)), level_number)
	data["coins"] = int(data.get("coins", 0)) + coins_delta
	save_slot(slot_index, data)
	return data

## 使用金币抽取永久道具。
## [参数] slot_index：存档槽索引；cost：抽取消耗金币；new_item_id：抽取到的新道具编号。
## [返回] Dictionary，返回抽取结果和保存后的存档。
## 最近修改时间：2026-06-09 01:14:48 金币抽永久道具并扣费。
func draw_permanent_item(slot_index: int, cost: int, new_item_id: String) -> Dictionary:
	# 1. 金币不足时不抽取，保持“打怪掉金币，金币抽道具”的闭环。
	var data := get_slot(slot_index).duplicate(true)
	if int(data.get("coins", 0)) < cost:
		return {
			"success": false,
			"item_id": "",
			"slot": data
		}
	data["coins"] = int(data.get("coins", 0)) - cost
	if not new_item_id.is_empty() and not data["owned_items"].has(new_item_id):
		data["owned_items"].append(new_item_id)
	save_slot(slot_index, data)
	print("ITEM_DRAW_SAVE slot=%d cost=%d item=%s coins_left=%d" % [slot_index, cost, new_item_id, data.get("coins", 0)])
	return {
		"success": true,
		"item_id": new_item_id,
		"slot": data
	}

## 记录失败结果。
## [参数] slot_index：存档槽索引。
## [返回] Dictionary，返回未回退长期资产的存档。
## 最近修改时间：2026-06-09 01:01:30 失败不惩罚长期资产。
func record_failure(slot_index: int) -> Dictionary:
	# 1. 失败只输出追踪日志，不清理通关进度、永久道具或解锁内容。
	var data := get_slot(slot_index)
	print("RUN_FAILED_KEEP_ASSETS slot=%d highest_level=%d owned_items=%s" % [
		slot_index,
		data.get("highest_cleared_level", 0),
		str(data.get("owned_items", []))
	])
	return data

## 读取单个存档槽。
## [参数] slot_index：存档槽索引。
## [返回] Dictionary，返回兼容后的存档。
## 最近修改时间：2026-06-09 01:30:32 显式声明 Variant，兼容 Godot 4.6 导出检查。
func _load_slot(slot_index: int) -> Dictionary:
	# 1. 缺失存档时生成默认槽，保证首次进入可玩。
	var path := _slot_path(slot_index)
	if not FileAccess.file_exists(path):
		return _default_slot(slot_index)
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return _default_slot(slot_index)
	return _with_defaults(parsed, slot_index)

## 生成默认存档。
## [参数] slot_index：存档槽索引。
## [返回] Dictionary，默认存档数据。
## 最近修改时间：2026-06-09 01:01:30 默认存档结构。
func _default_slot(slot_index: int) -> Dictionary:
	# 1. 首版存档只保留核心闭环必需字段。
	return {
		"schema_version": SCHEMA_VERSION,
		"slot_index": slot_index,
		"highest_cleared_level": 0,
		"selected_character": "runner",
		"owned_items": [],
		"equipped_items": [],
		"coins": 0,
		"unlocked_stages": ["stage_001"]
	}

## 对旧存档补兼容默认值。
## [参数] data：原始存档；slot_index：存档槽索引。
## [返回] Dictionary，兼容后的存档。
## 最近修改时间：2026-06-09 01:01:30 存档兼容策略。
func _with_defaults(data: Dictionary, slot_index: int) -> Dictionary:
	# 1. 新字段追加时用默认值补齐，避免旧存档失效。
	var defaults := _default_slot(slot_index)
	for key in defaults.keys():
		if not data.has(key):
			data[key] = defaults[key]
	data["schema_version"] = SCHEMA_VERSION
	data["slot_index"] = slot_index
	return data

## 获取存档路径。
## [参数] slot_index：存档槽索引。
## [返回] String，存档文件路径。
## 最近修改时间：2026-06-09 01:01:30 存档路径统一入口。
func _slot_path(slot_index: int) -> String:
	# 1. 三个槽各自独立文件，避免进度串档。
	return "%s/slot_%d.json" % [SAVE_DIR, slot_index + 1]
