extends Node

var enabled := false
var launch_state := {
	"slot_index": 0,
	"level": 1,
	"character_id": "runner",
	"equipped_items": [],
	"coins": 0
}

## 启用开发测试直达。
## [参数] state：指定关卡、角色、道具和存档状态。
## [返回] Dictionary，返回生效后的直达状态。
## 最近修改时间：2026-06-09 01:01:30 开发测试入口。
func enable(state: Dictionary) -> Dictionary:
	# 1. 开发直达必须显式启用，正式玩家流程默认不展示。
	enabled = true
	for key in state.keys():
		launch_state[key] = state[key]
	print("DEBUG_LAUNCH_ENABLED state=%s" % str(launch_state))
	return launch_state

## 禁用开发测试直达。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 正式流程隔离。
func disable() -> void:
	# 1. 禁用后主流程只按存档推进。
	enabled = false
