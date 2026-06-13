extends Node2D

signal battle_finished(success: bool, rewards: Dictionary)

const ENEMY_SCENE := preload("res://scenes/battle/Enemy.tscn")
const PROJECTILE_SCENE := preload("res://scenes/battle/Projectile.tscn")
const COIN_DROP_SCENE := preload("res://scenes/battle/CoinDrop.tscn")
const ARENA_TEXTURE_PATH := "res://assets/maps/arena_kenney_open_grass.png"
const DEFAULT_ARENA_RECT := Rect2(Vector2.ZERO, Vector2(1280, 720))
const WORLD_VIEWPORT_MULTIPLIER := 3.0
const ARENA_COVER_PADDING := 2.0
const SPAWN_MARGIN := 48.0
const PLAYER_HIT_DISTANCE := 24.0
const PROJECTILE_HIT_DISTANCE := 22.0
const COIN_PICKUP_DISTANCE := 30.0

@onready var arena: Sprite2D = %Arena
@onready var arena_background: Node2D = %ArenaBackground
@onready var camera: Camera2D = %BattleCamera
@onready var player: CharacterBody2D = %Player
@onready var hud_label: Label = %BattleInfo
@onready var level_toast: Label = %LevelToast

var arena_rect := DEFAULT_ARENA_RECT
var viewport_size := DEFAULT_ARENA_RECT.size
var active := false
var elapsed := 0.0
var spawned := 0
var defeated := 0
var coins := 0
var player_hp := 5
var level_start_coins := 0
var level_start_defeated := 0
var level_config: Dictionary = {}
var character_config: Dictionary = {}
var spawn_timer := 0.0
var attack_timer := 0.0
var enemies: Array[Node2D] = []
var projectiles: Array[Node2D] = []
var coin_drops: Array[Node2D] = []
var paused := false
var level_toast_tween: Tween

## 初始化战斗舞台。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-11 00:09:18 启动时创建三倍屏幕世界并配置相机边界。
func _ready() -> void:
	# 1. 进入场景后立即同步扩展战斗世界，避免首帧仍按屏幕大小限制玩家。
	_sync_arena_to_viewport()
	get_viewport().size_changed.connect(_sync_arena_to_viewport)

## 开始战斗。
## [参数] level_data：关卡配置；character_data：角色配置；equipped_items：已搭配永久道具。
## [返回] 无
## 最近修改时间：2026-06-11 00:57:03 记录本关奖励基线并隐藏关卡切换提示。
func start_battle(level_data: Dictionary, character_data: Dictionary, equipped_items: Array[String]) -> void:
	# 1. 重置战斗运行态，保证每次挑战可回放。
	_sync_arena_to_viewport()
	set_paused(false)
	_clear_runtime_nodes()
	level_config = level_data
	character_config = character_data
	elapsed = 0.0
	spawned = 0
	defeated = 0
	coins = 0
	level_start_coins = coins
	level_start_defeated = defeated
	player_hp = 5
	spawn_timer = 0.0
	attack_timer = _weapon_cooldown()
	active = true
	paused = false
	_hide_level_toast()
	player.global_position = arena_rect.position + arena_rect.size * 0.5
	camera.position = Vector2.ZERO
	player.call("setup_visual", String(character_config.get("id", "runner")))
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

## 连续切换到下一关。
## [参数] level_data：下一关配置。
## [返回] bool，成功切换返回 true。
## 最近修改时间：2026-06-11 00:57:03 普通关卡切换不清场，只更新刷怪配置并显示居中提示。
func continue_to_next_level(level_data: Dictionary) -> bool:
	# 1. 下一关只刷新关卡节奏和本关奖励基线，保留角色位置、怪物、子弹和掉落物。
	if level_data.is_empty():
		return false
	level_config = level_data
	elapsed = 0.0
	spawn_timer = 0.0
	attack_timer = minf(attack_timer, _weapon_cooldown())
	level_start_coins = coins
	level_start_defeated = defeated
	active = true
	paused = false
	set_paused(false)
	_show_level_toast("进入第 %d 关" % int(level_config.get("level", 0)))
	_update_hud()
	print("BATTLE_CONTINUE level=%d alive=%d defeated_total=%d coins_total=%d" % [
		level_config.get("level", 0),
		enemies.size(),
		defeated,
		coins
	])
	return true

## 停止当前连续战斗并清理动态实体。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-11 00:57:03 阶段结束或回到菜单时显式清场，避免普通换关误清空。
func stop_battle() -> void:
	# 1. 只有离开战斗流程时才清理运行实体，普通下一关保持连续战斗。
	set_paused(false)
	active = false
	_hide_level_toast()
	_clear_runtime_nodes()

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
## 最近修改时间：2026-06-10 22:54:03 先入树再初始化怪物贴图，避免 onready 节点为空。
func _spawn_timer_tick() -> void:
	# 1. 每个节拍按关卡配置生成真实怪物，难度优先来自怪物节奏和行为组合。
	spawn_timer = 0.0
	spawned += 1
	var enemy := ENEMY_SCENE.instantiate() as Node2D
	var enemy_data := _next_enemy_config()
	enemy.global_position = _spawn_position(spawned)
	# 2. 怪物贴图节点依赖 @onready，必须先进入场景树再执行 setup。
	add_child(enemy)
	enemy.call("setup", player, enemy_data)
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
## 最近修改时间：2026-06-11 00:57:03 成功通关只结算本关增量，失败才清理战斗实体。
func _finish(success: bool) -> void:
	# 1. 结算信号只返回本次挑战收益，长期资产由 SaveManager 统一写入。
	set_paused(false)
	active = false
	if not success:
		_clear_runtime_nodes()
	var rewards := {
		"coins": max(0, coins - level_start_coins),
		"defeated": max(0, defeated - level_start_defeated),
		"elapsed": elapsed
	}
	print("BATTLE_FINISH success=%s rewards=%s" % [str(success), str(rewards)])
	battle_finished.emit(success, rewards)

## 切换暂停状态。
## [参数] 无
## [返回] bool，切换后的暂停状态。
## 最近修改时间：2026-06-10 22:54:03 使用 Godot 原生暂停冻结所有战斗实体。
func toggle_pause() -> bool:
	# 1. 只有战斗进行中允许暂停，避免结算或菜单状态被误暂停。
	return set_paused(not paused)

## 设置暂停状态。
## [参数] paused_state：是否暂停。
## [返回] bool，最终暂停状态。
## 最近修改时间：2026-06-10 22:54:03 同步战斗标记和 SceneTree 暂停状态。
func set_paused(paused_state: bool) -> bool:
	# 1. Godot 原生暂停会冻结玩家、怪物、子弹和掉落物，避免实体脚本绕过 BattleStage.paused。
	if paused_state and not active:
		return false
	paused = paused_state
	get_tree().paused = paused
	_update_hud()
	return paused

## 同步战斗区域到当前视口。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-11 00:09:18 让地图、叠加层、相机和边界共用三倍屏幕世界。
func _sync_arena_to_viewport() -> void:
	# 1. 以当前视口推导三倍屏幕的战斗世界，让玩家可以在延展地图中移动。
	var viewport_rect := get_viewport_rect()
	viewport_size = viewport_rect.size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = DEFAULT_ARENA_RECT.size
	arena_rect = Rect2(Vector2.ZERO, viewport_size * WORLD_VIEWPORT_MULTIPLIER)
	_fit_arena_sprite()
	arena_background.call("setup", arena_rect)
	_configure_camera_limits()

## 配置战斗相机边界。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-11 00:42:16 关闭相机平滑减少移动残影和子像素抖动。
func _configure_camera_limits() -> void:
	# 1. 相机限制在完整地图范围内，关闭平滑避免相机追随延迟造成移动残影。
	camera.make_current()
	camera.limit_left = int(arena_rect.position.x)
	camera.limit_top = int(arena_rect.position.y)
	camera.limit_right = int(arena_rect.end.x)
	camera.limit_bottom = int(arena_rect.end.y)
	camera.position_smoothing_enabled = false

## 缩放地图贴图到覆盖战斗区域。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-11 01:39:27 场景缓存未带入纹理时兜底加载开放草地地图。
func _fit_arena_sprite() -> void:
	# 1. 场景缓存若未带入贴图，运行时兜底加载新开放草地地图，避免回到空白或旧地图状态。
	var texture := arena.texture
	if texture == null:
		texture = load(ARENA_TEXTURE_PATH) as Texture2D
		arena.texture = texture
		if texture == null:
			return
	var texture_size := texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	var fill_scale := maxf(1.0, maxf((arena_rect.size.x + ARENA_COVER_PADDING) / texture_size.x, (arena_rect.size.y + ARENA_COVER_PADDING) / texture_size.y))
	arena.position = arena_rect.position + arena_rect.size * 0.5
	arena.scale = Vector2(fill_scale, fill_scale)

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
## 最近修改时间：2026-06-11 00:18:41 清理已释放发射物时避免 TypedArray 反复擦除无效实例。
func _resolve_projectile_hits() -> void:
	# 1. 首版用距离判定保证可玩，后续再升级到碰撞层和碰撞体。
	for projectile_index in range(projectiles.size() - 1, -1, -1):
		var projectile := projectiles[projectile_index]
		# 1.1 已经被生命周期释放的发射物按索引移除，避免 TypedArray 校验无效实例时报错。
		if not is_instance_valid(projectile):
			projectiles.remove_at(projectile_index)
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
## [返回] Vector2，当前镜头周围的刷怪入口。
## 最近修改时间：2026-06-11 00:25:12 扩展地图下改为从当前视野四周刷怪。
func _spawn_position(spawn_index: int) -> Vector2:
	# 1. 使用确定性序列围绕当前镜头刷怪，避免大地图边缘怪物离玩家过远。
	var side := spawn_index % 4
	var ratio := float((spawn_index * 37) % 100) / 100.0
	var spawn_rect := _visible_spawn_rect()
	var spawn_position := Vector2.ZERO
	if side == 0:
		spawn_position = Vector2(spawn_rect.position.x - SPAWN_MARGIN, spawn_rect.position.y + spawn_rect.size.y * ratio)
	elif side == 1:
		spawn_position = Vector2(spawn_rect.end.x + SPAWN_MARGIN, spawn_rect.position.y + spawn_rect.size.y * ratio)
	elif side == 2:
		spawn_position = Vector2(spawn_rect.position.x + spawn_rect.size.x * ratio, spawn_rect.position.y - SPAWN_MARGIN)
	else:
		spawn_position = Vector2(spawn_rect.position.x + spawn_rect.size.x * ratio, spawn_rect.end.y + SPAWN_MARGIN)
	return _clamp_to_arena_bounds(spawn_position)

## 计算当前镜头覆盖区域。
## [参数] 无
## [返回] Rect2，当前镜头在世界中的可见区域。
## 最近修改时间：2026-06-11 00:25:12 为扩展地图提供近屏刷怪范围。
func _visible_spawn_rect() -> Rect2:
	# 1. 镜头中心按相机边界裁剪，保证靠近地图边缘时刷怪仍围绕玩家可见区域。
	var half_viewport := viewport_size * 0.5
	var center := Vector2(
		clamp(player.global_position.x, arena_rect.position.x + half_viewport.x, arena_rect.end.x - half_viewport.x),
		clamp(player.global_position.y, arena_rect.position.y + half_viewport.y, arena_rect.end.y - half_viewport.y)
	)
	return Rect2(center - half_viewport, viewport_size)

## 裁剪到战斗世界边界。
## [参数] position_value：待裁剪坐标。
## [返回] Vector2，战斗世界内坐标。
## 最近修改时间：2026-06-11 00:25:12 复用给扩展地图刷怪入口。
func _clamp_to_arena_bounds(position_value: Vector2) -> Vector2:
	# 1. 怪物和其他非玩家节点只需要限制在世界边界内，不套用玩家半径。
	return Vector2(
		clamp(position_value.x, arena_rect.position.x, arena_rect.end.x),
		clamp(position_value.y, arena_rect.position.y, arena_rect.end.y)
	)

## 裁剪到战斗区域。
## [参数] position_value：待裁剪坐标。
## [返回] Vector2，战斗区域内坐标。
## 最近修改时间：2026-06-10 23:24:38 按运行时战斗区域限制玩家移动。
func _clamp_to_arena(position_value: Vector2) -> Vector2:
	# 1. 玩家只能在可见战斗区域内移动，保证 PC Demo 操作反馈明确。
	return Vector2(
		clamp(position_value.x, arena_rect.position.x + 16.0, arena_rect.position.x + arena_rect.size.x - 16.0),
		clamp(position_value.y, arena_rect.position.y + 16.0, arena_rect.position.y + arena_rect.size.y - 16.0)
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

## 显示居中关卡切换提示。
## [参数] text：提示文案。
## [返回] 无
## 最近修改时间：2026-06-11 00:57:03 关卡切换反馈只覆盖战斗 HUD，不打断战斗流程。
func _show_level_toast(text: String) -> void:
	# 1. 居中提示用短动画表达进入下一关，同时让底层战斗继续推进。
	if level_toast_tween != null:
		level_toast_tween.kill()
	level_toast.text = text
	level_toast.visible = true
	level_toast.modulate = Color(1, 1, 1, 0.0)
	level_toast_tween = create_tween()
	level_toast_tween.tween_property(level_toast, "modulate:a", 1.0, 0.18)
	level_toast_tween.tween_interval(0.95)
	level_toast_tween.tween_property(level_toast, "modulate:a", 0.0, 0.28)
	level_toast_tween.finished.connect(_hide_level_toast)

## 隐藏关卡切换提示。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-11 00:57:03 统一收口提示动画和初始隐藏状态。
func _hide_level_toast() -> void:
	# 1. 隐藏时保留文字内容无影响，下一次显示会重新覆盖文案。
	level_toast.visible = false
	level_toast.modulate = Color(1, 1, 1, 0.0)

## 刷新战斗 HUD。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-10 23:03:37 全屏地图下保持 HUD 靠近窗口上沿。
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
