extends CharacterBody2D

@export var speed := 260.0

## 处理玩家移动。
## [参数] delta：物理帧间隔。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 PC 键鼠基础输入。
func _physics_process(delta: float) -> void:
	# 1. WASD 输入满足第一阶段 PC 桌面游戏形态。
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
