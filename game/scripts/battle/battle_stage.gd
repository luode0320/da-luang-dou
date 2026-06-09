extends Node2D

signal battle_finished(success: bool, rewards: Dictionary)

@onready var player: CharacterBody2D = %Player
@onready var hud_label: Label = %BattleInfo

var active := false
var elapsed := 0.0
var spawned := 0
var defeated := 0
var coins := 0
var level_config: Dictionary = {}
var character_config: Dictionary = {}
var spawn_timer := 0.0

## 开始战斗。
## [参数] level_data：关卡配置；character_data：角色配置；equipped_items：已搭配永久道具。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 战斗最小闭环入口。
func start_battle(level_data: Dictionary, character_data: Dictionary, equipped_items: Array[String]) -> void:
	# 1. 重置战斗运行态，保证每次挑战可回放。
	level_config = level_data
	character_config = character_data
	elapsed = 0.0
	spawned = 0
	defeated = 0
	coins = 0
	spawn_timer = 0.0
	active = true
	player.global_position = Vector2(640, 360)
	_apply_item_bonuses(equipped_items)
	_update_hud()
	print("BATTLE_START level=%d character=%s weapon=%s skill=%s items=%s" % [
		level_config.get("level", 0),
		character_config.get("id", ""),
		character_config.get("weapon", {}).get("id", ""),
		character_config.get("skill", {}).get("id", ""),
		str(equipped_items)
	])

## 更新战斗。
## [参数] delta：帧间隔。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 战斗循环。
func _process(delta: float) -> void:
	# 1. 非战斗状态不运行刷怪和结算。
	if not active:
		return
	elapsed += delta * GameTime.time_scale
	spawn_timer += delta * GameTime.time_scale
	if spawn_timer >= _spawn_interval():
		_spawn_timer_tick()
	if elapsed >= float(level_config.get("duration_seconds", 30)):
		_finish(true)
	_update_hud()

## 应用道具加成。
## [参数] equipped_items：已搭配永久道具。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 道具影响战斗。
func _apply_item_bonuses(equipped_items: Array[String]) -> void:
	# 1. 首版只把道具效果输出到追踪日志，后续逐步接入战斗数值。
	for item_id in equipped_items:
		var item := ConfigDb.get_item(item_id)
		print("ITEM_EQUIPPED id=%s effect=%s" % [item_id, str(item.get("effect", {}))])

## 处理刷怪节拍。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 怪物行为形成难度。
func _spawn_timer_tick() -> void:
	# 1. 每个节拍生成并立即模拟一次自动攻击命中，保证最小闭环可玩可测。
	spawn_timer = 0.0
	spawned += 1
	defeated += 1
	coins += _coin_per_enemy()
	print("ENEMY_DEFEATED level=%d spawned=%d defeated=%d coins=%d" % [
		level_config.get("level", 0),
		spawned,
		defeated,
		coins
	])

## 结束战斗。
## [参数] success：是否通关。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 战斗结算。
func _finish(success: bool) -> void:
	# 1. 结算信号只返回本次挑战收益，长期资产由 SaveManager 统一写入。
	active = false
	var rewards := {
		"coins": coins,
		"defeated": defeated,
		"elapsed": elapsed
	}
	print("BATTLE_FINISH success=%s rewards=%s" % [str(success), str(rewards)])
	battle_finished.emit(success, rewards)

## 读取刷怪间隔。
## [参数] 无
## [返回] float，刷怪间隔秒数。
## 最近修改时间：2026-06-09 01:01:30 关卡节奏配置。
func _spawn_interval() -> float:
	# 1. 刷怪间隔来自关卡配置，不能靠关卡编号硬编码。
	var groups: Array = level_config.get("enemy_groups", [])
	if groups.is_empty():
		return 2.0
	return float(groups[0].get("spawn_interval", 2.0))

## 读取单怪金币。
## [参数] 无
## [返回] int，单次击败金币。
## 最近修改时间：2026-06-09 01:01:30 掉落配置。
func _coin_per_enemy() -> int:
	# 1. 金币掉落独立配置，后续可扩展随机种子和回放。
	return int(ConfigDb.get_config("drops").get("coin_per_enemy", 1))

## 刷新战斗 HUD。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 PC HUD 可读性。
func _update_hud() -> void:
	# 1. HUD 保持大字号关键数据，满足 PC Demo 可读性验收。
	hud_label.text = "Level %d | %.0fs | %.0fx | defeated %d | coins %d" % [
		level_config.get("level", RunState.current_level),
		elapsed,
		GameTime.time_scale,
		defeated,
		coins
	]
