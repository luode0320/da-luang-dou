extends Node

## 读取角色固定武器说明。
## [参数] character_config：角色配置。
## [返回] Dictionary，固定武器配置。
## 最近修改时间：2026-06-09 01:01:30 固定武器入口。
func get_fixed_weapon(character_config: Dictionary) -> Dictionary:
	# 1. 武器完全由角色配置绑定，首版不提供切换入口。
	return character_config.get("weapon", {})
