extends Area2D

@export var speed := 520.0
var direction := Vector2.RIGHT
var damage := 1
var lifetime := 2.0

## 初始化发射物。
## [参数] launch_direction：发射方向；weapon_damage：伤害值。
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 接入自动攻击伤害。
func setup(launch_direction: Vector2, weapon_damage: int = 1) -> void:
	# 1. 发射方向归一化，避免不同方向速度不一致，伤害来自固定武器配置。
	direction = launch_direction.normalized()
	damage = weapon_damage

## 更新发射物。
## [参数] delta：帧间隔。
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 发射物自动过期。
func _process(delta: float) -> void:
	# 1. 发射物也读取统一倍率，并在生命周期结束后清理。
	var scale := _time_scale()
	position += direction * speed * delta * scale
	lifetime -= delta * scale
	if lifetime <= 0.0:
		queue_free()

## 读取统一游戏倍率。
## [参数] 无
## [返回] float，当前游戏倍率。
## 最近修改时间：2026-06-09 23:44:00 兼容命令行验证环境。
func _time_scale() -> float:
	# 1. 正常游戏读取 Autoload，验证环境缺失时回退 1 倍速。
	var game_time := get_node_or_null("/root/GameTime")
	if game_time == null:
		return 1.0
	return float(game_time.get("time_scale"))
