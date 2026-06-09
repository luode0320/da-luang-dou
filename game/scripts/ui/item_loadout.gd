extends Control

signal loadout_confirmed(item_ids: Array[String])

## 计算可携带道具。
## [参数] owned_items：永久道具池；carry_limit：携带上限。
## [返回] Array[String]，默认选中的道具。
## 最近修改时间：2026-06-09 01:01:30 道具搭配 UI 逻辑。
func default_loadout(owned_items: Array, carry_limit: int) -> Array[String]:
	# 1. 首版默认按永久池顺序装备，后续再扩展手动勾选。
	var selected: Array[String] = []
	for item in owned_items:
		if selected.size() >= carry_limit:
			break
		selected.append(String(item))
	return selected
