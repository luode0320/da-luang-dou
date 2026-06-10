extends CharacterBody2D

@export var move_speed := 120.0
var enemy_id := "chaser"
var hp := 10
var target: Node2D

## 初始化怪物目标。
## [参数] player：玩家节点；enemy_data：怪物配置。
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 接入真实刷怪和生命值。
func setup(player: Node2D, enemy_data: Dictionary = {}) -> void:
	# 1. 首版怪物形态先以追踪压力表达，生命和速度来自配置。
	target = player
	enemy_id = String(enemy_data.get("id", enemy_id))
	hp = int(enemy_data.get("hp", hp))
	move_speed = float(enemy_data.get("move_speed", move_speed))

## 承受伤害。
## [参数] amount：伤害值。
## [返回] bool，生命值归零时返回 true。
## 最近修改时间：2026-06-09 23:44:00 支持发射物命中击败怪物。
func take_damage(amount: int) -> bool:
	# 1. 命中只扣当前怪物生命，击败后的掉落由战斗舞台统一处理。
	hp -= amount
	return hp <= 0

## 更新怪物移动。
## [参数] delta：物理帧间隔。
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 通过根节点读取统一倍率。
func _physics_process(delta: float) -> void:
	# 1. 怪物行为受统一时间倍率影响。
	if target == null:
		return
	var direction := global_position.direction_to(target.global_position)
	velocity = direction * move_speed * _time_scale()
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
