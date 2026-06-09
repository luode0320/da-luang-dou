extends Control

signal debug_launch_requested(state: Dictionary)

## 创建默认直达状态。
## [参数] 无
## [返回] Dictionary，默认开发直达配置。
## 最近修改时间：2026-06-09 01:01:30 开发测试直达 UI。
func default_state() -> Dictionary:
	# 1. 默认直达第 10 关，用于验证阶段结束和换角流程。
	return {
		"slot_index": 0,
		"level": 10,
		"character_id": "runner",
		"equipped_items": ["magnet_core"],
		"coins": 30
	}
