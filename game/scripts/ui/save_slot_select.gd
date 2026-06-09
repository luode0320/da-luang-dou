extends Control

signal slot_selected(slot_index: int)
signal slot_reset(slot_index: int)

## 构建存档槽按钮。
## [参数] slots：存档槽数据。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 存档选择 UI 占位。
func render_slots(slots: Array[Dictionary]) -> void:
	# 1. 该脚本预留给后续拆分 UI，首版主流程先在 Main 中直接构建按钮。
	for index in range(slots.size()):
		print("SAVE_SLOT_UI index=%d highest=%d" % [index, slots[index].get("highest_cleared_level", 0)])
