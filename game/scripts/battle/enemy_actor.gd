extends CharacterBody2D

@export var move_speed := 120.0
var target: Node2D

## 初始化怪物目标。
## [参数] player：玩家节点。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 怪物追踪行为。
func setup(player: Node2D) -> void:
	# 1. 首版怪物形态先以追踪压力表达，后续按行为标签扩展。
	target = player

## 更新怪物移动。
## [参数] delta：物理帧间隔。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 怪物基础行为。
func _physics_process(delta: float) -> void:
	# 1. 怪物行为受统一时间倍率影响。
	if target == null:
		return
	var direction := global_position.direction_to(target.global_position)
	velocity = direction * move_speed * GameTime.time_scale
	move_and_slide()
