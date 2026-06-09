extends Node

## 计算关卡预计刷怪数量。
## [参数] level_config：关卡配置。
## [返回] int，预计刷怪数量。
## 最近修改时间：2026-06-09 01:01:30 刷怪配置辅助。
func estimate_spawn_count(level_config: Dictionary) -> int:
	# 1. 估算用于调试面板，实际战斗仍由 BattleStage 节拍驱动。
	var duration := float(level_config.get("duration_seconds", 30))
	var groups: Array = level_config.get("enemy_groups", [])
	if groups.is_empty():
		return 0
	var interval := float(groups[0].get("spawn_interval", 2.0))
	return int(duration / max(interval, 0.1))
