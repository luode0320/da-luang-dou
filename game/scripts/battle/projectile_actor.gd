extends Area2D

@export var speed := 520.0
var direction := Vector2.RIGHT

## 初始化发射物。
## [参数] launch_direction：发射方向。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 固定武器发射物。
func setup(launch_direction: Vector2) -> void:
	# 1. 发射方向归一化，避免不同方向速度不一致。
	direction = launch_direction.normalized()

## 更新发射物。
## [参数] delta：帧间隔。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 发射物运动。
func _process(delta: float) -> void:
	# 1. 发射物也读取统一倍率。
	position += direction * speed * delta * GameTime.time_scale
