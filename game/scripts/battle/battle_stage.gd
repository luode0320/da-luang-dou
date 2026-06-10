extends Node2D

signal battle_finished(success: bool, rewards: Dictionary)

const ENEMY_SCENE := preload("res://scenes/battle/Enemy.tscn")
const PROJECTILE_SCENE := preload("res://scenes/battle/Projectile.tscn")
const COIN_DROP_SCENE := preload("res://scenes/battle/CoinDrop.tscn")
const ARENA_RECT := Rect2(Vector2(120, 110), Vector2(1040, 550))
const PLAYER_HIT_DISTANCE := 24.0
const PROJECTILE_HIT_DISTANCE := 22.0
const COIN_PICKUP_DISTANCE := 30.0

@onready var player: CharacterBody2D = %Player
@onready var hud_label: Label = %BattleInfo

var active := false
var elapsed := 0.0
var spawned := 0
var defeated := 0
var coins := 0
var player_hp := 5
var level_config: Dictionary = {}
var character_config: Dictionary = {}
var spawn_timer := 0.0
var attack_timer := 0.0
var enemies: Array[Node2D] = []
var projectiles: Array[Node2D] = []
var coin_drops: Array[Node2D] = []
var paused := false

## 开始战斗。
## [参数] level_data：关卡配置；character_data：角色配置；equipped_items：已搭配永久道具。
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 接入真实怪物、子弹、金币和生命值。
func start_battle(level_data: Dictionary, character_data: Dictionary, equipped_items: Array[String]) -> void:
	# 1. 重置战斗运行态，保证每次挑战可回放。
	_clear_runtime_nodes()
	level_config = level_data
	character_config = character_data
	elapsed = 0.0
	spawned = 0
	defeated = 0
	coins = 0
	player_hp = 5
	spawn_timer = 0.0
	attack_timer = _weapon_cooldown()
	active = true
	paused = false
	player.global_position = Vector2(640, 360)
	_apply_item_bonuses(equipped_items)
	_spawn_timer_tick()
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
## 最近修改时间：2026-06-09 23:44:00 驱动真实刷怪、自动攻击、命中和拾取。
func _process(delta: float) -> void:
	# 1. 非战斗状态不运行刷怪和结算。
	if not active or paused:
		return
	var scaled_delta := delta * _time_scale()
	elapsed += scaled_delta
	spawn_timer += scaled_delta
	attack_timer += scaled_delta
	player.global_position = _clamp_to_arena(player.global_position)
	if spawn_timer >= _spawn_interval():
		_spawn_timer_tick()
	if attack_timer >= _weapon_cooldown():
		_fire_at_nearest_enemy()
	_resolve_projectile_hits()
	_resolve_enemy_contacts()
	if not active:
		return
	_resolve_coin_pickups()
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
		var item := _get_item(item_id)
		print("ITEM_EQUIPPED id=%s effect=%s" % [item_id, str(item.get("effect", {}))])

## 处理刷怪节拍。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 生成真实怪物节点。
func _spawn_timer_tick() -> void:
	# 1. 每个节拍按关卡配置生成真实怪物，难度优先来自怪物节奏和行为组合。
	spawn_timer = 0.0
	spawned += 1
	var enemy := ENEMY_SCENE.instantiate() as Node2D
	var enemy_data := _next_enemy_config()
	enemy.global_position = _spawn_position(spawned)
	enemy.call("setup", player, enemy_data)
	add_child(enemy)
	enemies.append(enemy)
	print("ENEMY_SPAWN level=%d enemy=%s spawned=%d alive=%d" % [
		level_config.get("level", 0),
		enemy_data.get("id", ""),
		spawned,
		enemies.size()
	])

## 结束战斗。
## [参数] success：是否通关。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 战斗结算。
func _finish(success: bool) -> void:
	# 1. 结算信号只返回本次挑战收益，长期资产由 SaveManager 统一写入。
	active = false
	_clear_runtime_nodes()
	var rewards := {
		"coins": coins,
		"defeated": defeated,
		"elapsed": elapsed
	}
	print("BATTLE_FINISH success=%s rewards=%s" % [str(success), str(rewards)])
	battle_finished.emit(success, rewards)

## 切换暂停状态。
## [参数] 无
## [返回] bool，切换后的暂停状态。
## 最近修改时间：2026-06-10 00:08:00 支持 ESC 暂停和恢复。
func toggle_pause() -> bool:
	# 1. 只有战斗进行中允许暂停，避免结算或菜单状态被误暂停。
	if not active:
		return false
	paused = not paused
	_update_hud()
	return paused

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
	return int(_get_config("drops").get("coin_per_enemy", 1))

## 读取武器冷却。
## [参数] 无
## [返回] float，自动攻击冷却秒数。
## 最近修改时间：2026-06-09 23:44:00 接入固定武器自动攻击。
func _weapon_cooldown() -> float:
	# 1. 角色武器固定，冷却从角色配置读取。
	return float(character_config.get("weapon", {}).get("cooldown_seconds", 1.0))

## 读取武器伤害。
## [参数] 无
## [返回] int，自动攻击伤害。
## 最近修改时间：2026-06-09 23:44:00 接入固定武器伤害。
func _weapon_damage() -> int:
	# 1. 角色武器固定，伤害从角色配置读取。
	return int(character_config.get("weapon", {}).get("damage", 1))

## 向最近怪物自动开火。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 实现可见自动攻击。
func _fire_at_nearest_enemy() -> void:
	# 1. 没有怪物时保留冷却，等下一轮刷怪后再攻击。
	attack_timer = 0.0
	var target := _nearest_enemy()
	if target == null:
		return
	var projectile := PROJECTILE_SCENE.instantiate() as Node2D
	projectile.global_position = player.global_position
	projectile.call("setup", player.global_position.direction_to(target.global_position), _weapon_damage())
	add_child(projectile)
	projectiles.append(projectile)

## 查找最近怪物。
## [参数] 无
## [返回] Node2D，找不到时返回 null。
## 最近修改时间：2026-06-09 23:44:00 为自动攻击提供目标。
func _nearest_enemy() -> Node2D:
	# 1. 自动攻击优先打最近威胁，形成类 Brotato 的基础手感。
	var nearest: Node2D = null
	var nearest_distance := INF
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var distance := player.global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = enemy
	return nearest

## 处理发射物命中。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 实现击败怪物和金币掉落。
func _resolve_projectile_hits() -> void:
	# 1. 首版用距离判定保证可玩，后续再升级到碰撞层和碰撞体。
	for projectile in projectiles.duplicate():
		if not is_instance_valid(projectile):
			projectiles.erase(projectile)
			continue
		for enemy in enemies.duplicate():
			if not is_instance_valid(enemy):
				enemies.erase(enemy)
				continue
			if projectile.global_position.distance_to(enemy.global_position) > PROJECTILE_HIT_DISTANCE:
				continue
			projectiles.erase(projectile)
			projectile.queue_free()
			if bool(enemy.call("take_damage", int(projectile.get("damage")))):
				_defeat_enemy(enemy)
			break

## 处理怪物接触玩家。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 实现失败条件。
func _resolve_enemy_contacts() -> void:
	# 1. 怪物撞到玩家后扣除生命并消失，避免单只怪物每帧连续扣血。
	for enemy in enemies.duplicate():
		if not is_instance_valid(enemy):
			enemies.erase(enemy)
			continue
		if enemy.global_position.distance_to(player.global_position) > PLAYER_HIT_DISTANCE:
			continue
		enemies.erase(enemy)
		enemy.queue_free()
		player_hp -= 1
		if player_hp <= 0:
			_finish(false)
			return

## 处理金币拾取。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 实现打怪掉金币并拾取。
func _resolve_coin_pickups() -> void:
	# 1. 玩家靠近金币即拾取，金币收益进入本次通关结算。
	for coin_drop in coin_drops.duplicate():
		if not is_instance_valid(coin_drop):
			coin_drops.erase(coin_drop)
			continue
		if coin_drop.global_position.distance_to(player.global_position) > COIN_PICKUP_DISTANCE:
			continue
		coins += int(coin_drop.value)
		coin_drops.erase(coin_drop)
		coin_drop.queue_free()

## 击败怪物。
## [参数] enemy：被击败的怪物。
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 击败后生成金币掉落。
func _defeat_enemy(enemy: Node2D) -> void:
	# 1. 击败记录和掉落分开，避免金币在未拾取时直接入账。
	var drop_position := enemy.global_position
	enemies.erase(enemy)
	enemy.queue_free()
	defeated += 1
	var coin_drop := COIN_DROP_SCENE.instantiate() as Node2D
	coin_drop.global_position = drop_position
	coin_drop.call("setup", _coin_per_enemy())
	add_child(coin_drop)
	coin_drops.append(coin_drop)
	print("ENEMY_DEFEATED level=%d defeated=%d drops=%d" % [
		level_config.get("level", 0),
		defeated,
		coin_drops.size()
	])

## 选择下一只怪物配置。
## [参数] 无
## [返回] Dictionary，怪物配置。
## 最近修改时间：2026-06-09 23:44:00 按关卡怪物组轮换刷怪。
func _next_enemy_config() -> Dictionary:
	# 1. 多怪物组按生成次数轮换，避免靠单纯数值堆难度。
	var groups: Array = level_config.get("enemy_groups", [])
	if groups.is_empty():
		var fallback_enemies: Array = _get_config("enemies").get("enemies", [])
		if fallback_enemies.is_empty():
			return {}
		return fallback_enemies[0]
	var group: Dictionary = groups[(spawned - 1) % groups.size()]
	var enemy_id := String(group.get("enemy_id", "chaser"))
	for enemy_data in _get_config("enemies").get("enemies", []):
		if String(enemy_data.get("id", "")) == enemy_id:
			return enemy_data
	return {}

## 计算刷怪位置。
## [参数] spawn_index：当前生成序号。
## [返回] Vector2，舞台边缘位置。
## 最近修改时间：2026-06-09 23:44:00 让怪物从四周进入战场。
func _spawn_position(spawn_index: int) -> Vector2:
	# 1. 使用确定性序列，保证同关卡调试时刷怪入口可复现。
	var side := spawn_index % 4
	var ratio := float((spawn_index * 37) % 100) / 100.0
	if side == 0:
		return Vector2(ARENA_RECT.position.x, ARENA_RECT.position.y + ARENA_RECT.size.y * ratio)
	if side == 1:
		return Vector2(ARENA_RECT.position.x + ARENA_RECT.size.x, ARENA_RECT.position.y + ARENA_RECT.size.y * ratio)
	if side == 2:
		return Vector2(ARENA_RECT.position.x + ARENA_RECT.size.x * ratio, ARENA_RECT.position.y)
	return Vector2(ARENA_RECT.position.x + ARENA_RECT.size.x * ratio, ARENA_RECT.position.y + ARENA_RECT.size.y)

## 裁剪到战斗区域。
## [参数] position_value：待裁剪坐标。
## [返回] Vector2，战斗区域内坐标。
## 最近修改时间：2026-06-09 23:44:00 防止玩家移动到舞台外。
func _clamp_to_arena(position_value: Vector2) -> Vector2:
	# 1. 玩家只能在可见战斗区域内移动，保证 PC Demo 操作反馈明确。
	return Vector2(
		clamp(position_value.x, ARENA_RECT.position.x + 16.0, ARENA_RECT.position.x + ARENA_RECT.size.x - 16.0),
		clamp(position_value.y, ARENA_RECT.position.y + 16.0, ARENA_RECT.position.y + ARENA_RECT.size.y - 16.0)
	)

## 清理战斗运行节点。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 重开关卡前清空旧实体。
func _clear_runtime_nodes() -> void:
	# 1. 每次开局和结算都清理动态实体，避免旧怪物、子弹或金币残留。
	for node in enemies + projectiles + coin_drops:
		if is_instance_valid(node):
			node.queue_free()
	enemies.clear()
	projectiles.clear()
	coin_drops.clear()

## 刷新战斗 HUD。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-10 00:08:00 操作说明补充暂停状态。
func _update_hud() -> void:
	# 1. HUD 保持大字号关键数据，并直接给玩家基础操作说明。
	var pause_text := ""
	if paused:
		pause_text = " | 已暂停"
	hud_label.text = "Level %d | %.0fs | %.0fx | HP %d | defeated %d | coins %d | WASD/方向键移动，+/-调速，自动攻击" % [
		level_config.get("level", _current_level()),
		elapsed,
		_time_scale(),
		player_hp,
		defeated,
		coins
	] + pause_text

## 读取配置分组。
## [参数] key：配置分组名。
## [返回] Dictionary，配置不存在时返回空字典。
## 最近修改时间：2026-06-09 23:44:00 兼容命令行验证环境。
func _get_config(key: String) -> Dictionary:
	# 1. 正常游戏读取 ConfigDb Autoload，验证环境缺失时回退空配置。
	var config_db := get_node_or_null("/root/ConfigDb")
	if config_db == null:
		return {}
	var value: Variant = config_db.call("get_config", key)
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	return value

## 读取道具配置。
## [参数] item_id：道具编号。
## [返回] Dictionary，道具不存在时返回空字典。
## 最近修改时间：2026-06-09 23:44:00 兼容命令行验证环境。
func _get_item(item_id: String) -> Dictionary:
	# 1. 道具仍由统一配置库管理，缺失时只输出空效果。
	var config_db := get_node_or_null("/root/ConfigDb")
	if config_db == null:
		return {}
	var value: Variant = config_db.call("get_item", item_id)
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	return value

## 读取统一游戏倍率。
## [参数] 无
## [返回] float，当前游戏倍率。
## 最近修改时间：2026-06-09 23:44:00 兼容命令行验证环境。
func _time_scale() -> float:
	# 1. 战斗所有时间相关逻辑都从同一倍率读取，缺失时回退 1 倍速。
	var game_time := get_node_or_null("/root/GameTime")
	if game_time == null:
		return 1.0
	return float(game_time.get("time_scale"))

## 读取当前关卡编号。
## [参数] 无
## [返回] int，当前关卡编号。
## 最近修改时间：2026-06-09 23:44:00 兼容命令行验证环境。
func _current_level() -> int:
	# 1. HUD 默认读取运行状态，验证环境缺失时回退第 1 关。
	var run_state := get_node_or_null("/root/RunState")
	if run_state == null:
		return 1
	return int(run_state.get("current_level"))
