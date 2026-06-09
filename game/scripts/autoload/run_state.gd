extends Node

var slot_index := 0
var current_level := 1
var selected_character := "runner"
var equipped_items: Array[String] = []
var run_coins := 0
var dev_mode := false

## 从存档初始化本次挑战状态。
## [参数] slot：存档数据。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 主流程状态初始化。
func start_from_slot(slot: Dictionary) -> void:
	# 1. 正式流程默认挑战下一个未通过关卡。
	slot_index = int(slot.get("slot_index", 0))
	current_level = int(slot.get("highest_cleared_level", 0)) + 1
	selected_character = String(slot.get("selected_character", "runner"))
	equipped_items = _to_string_array(slot.get("equipped_items", []))
	run_coins = 0
	dev_mode = false

## 应用开发测试直达状态。
## [参数] launch_state：开发测试入口状态。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 支持关卡直达调试。
func apply_debug_launch(launch_state: Dictionary) -> void:
	# 1. 测试直达只改当前运行态，不写入玩家长期存档。
	slot_index = int(launch_state.get("slot_index", 0))
	current_level = int(launch_state.get("level", 1))
	selected_character = String(launch_state.get("character_id", "runner"))
	equipped_items = _to_string_array(launch_state.get("equipped_items", []))
	run_coins = int(launch_state.get("coins", 0))
	dev_mode = true

## 设置当前角色。
## [参数] character_id：角色编号。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 阶段换角支持。
func set_character(character_id: String) -> void:
	# 1. 换角只换角色编号，武器技能仍由角色配置固定决定。
	selected_character = character_id

## 设置已搭配道具。
## [参数] item_ids：道具编号列表。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 永久道具搭配支持。
func set_equipped_items(item_ids: Array[String]) -> void:
	# 1. 携带上限由调用方按阶段配置裁剪。
	equipped_items = item_ids.duplicate()

## 判断当前关卡是否阶段结束。
## [参数] 无
## [返回] bool，第 10 关等阶段末尾返回 true。
## 最近修改时间：2026-06-09 01:01:30 10 关阶段推进判断。
func is_stage_end() -> bool:
	# 1. 首版按 10 关一个阶段，后续可改为读取阶段配置。
	return current_level % 10 == 0

## 转换为字符串数组。
## [参数] value：任意数组值。
## [返回] Array[String]，字符串数组。
## 最近修改时间：2026-06-09 01:01:30 配置和存档数组兼容。
func _to_string_array(value: Variant) -> Array[String]:
	# 1. JSON 读取没有强类型数组，这里统一转成脚本侧字符串数组。
	var output: Array[String] = []
	if typeof(value) == TYPE_ARRAY:
		for item in value:
			output.append(String(item))
	return output
