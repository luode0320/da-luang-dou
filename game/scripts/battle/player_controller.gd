extends CharacterBody2D

const CHARACTER_TEXTURES := {
	"runner": preload("res://assets/sprites/player_runner.svg"),
	"guard": preload("res://assets/sprites/player_guard.svg")
}

@export var speed := 260.0
@onready var body_sprite: Sprite2D = $Body

## 设置玩家角色贴图。
## [参数] character_id：角色编号。
## [返回] 无
## 最近修改时间：2026-06-10 22:22:00 接入首版原创角色占位素材。
func setup_visual(character_id: String) -> void:
	# 1. 按角色配置切换贴图，找不到时回退 runner，避免配置扩展时显示为空。
	body_sprite.texture = CHARACTER_TEXTURES.get(character_id, CHARACTER_TEXTURES["runner"])

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
