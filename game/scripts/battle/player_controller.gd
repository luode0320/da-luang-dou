extends CharacterBody2D

@export var speed := 260.0

## 处理玩家移动。
## [参数] delta：物理帧间隔。
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 玩家移动接入统一倍率。
func _physics_process(delta: float) -> void:
	# 1. WASD 输入满足第一阶段 PC 桌面游戏形态。
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed * _time_scale()
	move_and_slide()

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
