extends Node

const CONFIG_PATHS := {
	"stage": "res://data/stages/stage_001.json",
	"levels": "res://data/levels/level_001_010.json",
	"characters": "res://data/characters.json",
	"enemies": "res://data/enemies.json",
	"items": "res://data/items.json",
	"drops": "res://data/drops.json"
}

var configs: Dictionary = {}
var errors: Array[String] = []

## 加载首版配置并执行关键字段校验。
## [参数] 无
## [返回] bool，配置全部加载且校验通过时返回 true。
## 最近修改时间：2026-06-09 01:01:30 首版配置驱动闭环入口。
func load_all() -> bool:
	# 1. 清空上一轮配置，避免开发测试直达时读到旧数据。
	configs.clear()
	errors.clear()
	for key in CONFIG_PATHS.keys():
		var loaded := _read_json(CONFIG_PATHS[key])
		if loaded.is_empty():
			errors.append("配置为空或读取失败: %s" % CONFIG_PATHS[key])
		configs[key] = loaded

	# 2. 关键配置必须一次性校验，防止带缺字段进入战斗。
	_validate_stage()
	_validate_levels()
	_validate_characters()
	_validate_items()
	return errors.is_empty()

## 读取指定配置分组。
## [参数] key：配置分组名。
## [返回] Variant，返回对应配置，缺失时返回空字典。
## 最近修改时间：2026-06-09 01:01:30 首版配置读取接口。
func get_config(key: String) -> Variant:
	# 1. 所有业务读取都从统一配置表进入，后续替换 Resource 时只改这里。
	return configs.get(key, {})

## 按关卡编号读取关卡配置。
## [参数] level_number：关卡编号。
## [返回] Dictionary，缺失时返回空字典。
## 最近修改时间：2026-06-09 01:01:30 支持无尽关卡配置定位。
func get_level(level_number: int) -> Dictionary:
	# 1. 关卡数组保持配置驱动，不按编号硬编码分支。
	for level in configs.get("levels", {}).get("levels", []):
		if int(level.get("level", 0)) == level_number:
			return level
	return {}

## 按角色编号读取角色配置。
## [参数] character_id：角色编号。
## [返回] Dictionary，缺失时返回空字典。
## 最近修改时间：2026-06-09 01:01:30 支持固定角色套装。
func get_character(character_id: String) -> Dictionary:
	# 1. 角色固定武器和技能来自配置，不允许运行时换武器。
	for character in configs.get("characters", {}).get("characters", []):
		if String(character.get("id", "")) == character_id:
			return character
	return {}

## 按道具编号读取永久道具配置。
## [参数] item_id：道具编号。
## [返回] Dictionary，缺失时返回空字典。
## 最近修改时间：2026-06-09 01:01:30 支持永久道具池搭配。
func get_item(item_id: String) -> Dictionary:
	# 1. 道具效果首版只做可追踪字段，后续阶段继续扩展。
	for item in configs.get("items", {}).get("items", []):
		if String(item.get("id", "")) == item_id:
			return item
	return {}

## 读取 JSON 文件。
## [参数] path：Godot 资源路径。
## [返回] Dictionary，读取失败或格式错误时返回空字典。
## 最近修改时间：2026-06-09 01:30:32 显式声明 Variant，兼容 Godot 4.6 导出检查。
func _read_json(path: String) -> Dictionary:
	# 1. 明确记录读取失败原因，便于配置驱动阶段排查。
	if not FileAccess.file_exists(path):
		errors.append("配置文件不存在: %s" % path)
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		errors.append("配置不是对象: %s" % path)
		return {}
	return parsed

## 校验阶段配置。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 01:30:32 显式声明 Dictionary，兼容 Godot 4.6 导出检查。
func _validate_stage() -> void:
	# 1. 阶段必须表达 10 关版本阶段和携带上限。
	var stage: Dictionary = configs.get("stage", {})
	for field in ["stage_id", "level_start", "level_end", "item_carry_limit"]:
		if not stage.has(field):
			errors.append("stage_001 缺少字段: %s" % field)

## 校验关卡配置。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 01:30:32 显式声明 Array，兼容 Godot 4.6 导出检查。
func _validate_levels() -> void:
	# 1. 首版必须提供 1-10 关，证明 10 关阶段推进。
	var levels: Array = configs.get("levels", {}).get("levels", [])
	if levels.size() != 10:
		errors.append("第一阶段必须配置 10 个关卡")
	for level in levels:
		for field in ["level", "duration_seconds", "enemy_groups", "clear_condition"]:
			if not level.has(field):
				errors.append("关卡配置缺少字段: %s" % field)

## 校验角色配置。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 固定角色套装校验。
func _validate_characters() -> void:
	# 1. 每个角色必须绑定固定武器和固定技能。
	for character in configs.get("characters", {}).get("characters", []):
		for field in ["id", "name_key", "weapon", "skill"]:
			if not character.has(field):
				errors.append("角色配置缺少字段: %s" % field)

## 校验道具配置。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 永久道具池校验。
func _validate_items() -> void:
	# 1. 道具必须能进入永久池并被搭配界面读取。
	if configs.get("items", {}).get("items", []).is_empty():
		errors.append("永久道具池不能为空")
