extends RefCounted

const REQUIRED_STAGE_FIELDS := ["stage_id", "level_start", "level_end", "item_carry_limit"]
const REQUIRED_LEVEL_FIELDS := ["level", "duration_seconds", "enemy_groups", "clear_condition"]
const REQUIRED_CHARACTER_FIELDS := ["id", "name_key", "weapon", "skill"]

## 检查对象是否具备必需字段。
## [参数] source：待检查对象；required_fields：字段名列表。
## [返回] Array[String]，缺失字段列表。
## 最近修改时间：2026-06-09 01:01:30 配置字段校验辅助。
static func missing_fields(source: Dictionary, required_fields: Array) -> Array[String]:
	# 1. 配置校验只返回缺失项，不在模型层决定错误展示方式。
	var missing: Array[String] = []
	for field in required_fields:
		if not source.has(String(field)):
			missing.append(String(field))
	return missing
