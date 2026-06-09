extends Control

signal role_selected(character_id: String)

## 输出角色选择项。
## [参数] characters：角色配置列表。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 角色选择 UI 占位。
func render_roles(characters: Array) -> void:
	# 1. 角色只展示固定套装，不展示武器切换入口。
	for character in characters:
		print("ROLE_UI id=%s weapon=%s" % [character.get("id", ""), character.get("weapon", {}).get("id", "")])
