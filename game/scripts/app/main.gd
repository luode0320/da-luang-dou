extends Control

@onready var title_label: Label = %TitleLabel
@onready var status_label: Label = %StatusLabel
@onready var action_panel: VBoxContainer = %ActionPanel
@onready var battle_stage: Node = %BattleStage

var selected_slot := 0
var selected_loadout: Array[String] = []
var transition_tween: Tween

## 初始化主流程。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 启动时隐藏战斗舞台，避免挡住存档选择。
func _ready() -> void:
	# 1. PC Demo 必须用正式窗口形态启动，不做脚本式入口。
	DisplayServer.window_set_title("Da Luang Dou - First PC Demo")
	DisplayServer.window_set_size(Vector2i(1280, 720))
	battle_stage.visible = false
	I18nText.load_texts()
	var config_ok := ConfigDb.load_all()
	SaveManager.load_slots()
	battle_stage.battle_finished.connect(_on_battle_finished)
	title_label.text = I18nText.t("game.title", "大乱斗")
	if not config_ok:
		_show_status("配置错误：%s" % _join_strings(ConfigDb.errors, "; "))
		return
	_show_save_slots()

## 处理键盘倍率调整。
## [参数] event：输入事件。
## [返回] 无
## 最近修改时间：2026-06-10 00:08:00 增加 ESC 暂停输入。
func _unhandled_input(event: InputEvent) -> void:
	# 1. 战斗中 ESC 切换暂停，其余页面保留默认流程。
	if event.is_action_pressed("pause_game") and battle_stage.visible:
		battle_stage.toggle_pause()
		return
	# 2. 加减号直接控制统一倍率，HUD 和战斗逻辑读取同一来源。
	if event.is_action_pressed("speed_up"):
		GameTime.increase()
		_refresh_battle_status()
	if event.is_action_pressed("speed_down"):
		GameTime.decrease()
		_refresh_battle_status()

## 展示存档槽选择。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 未进战斗前隐藏战斗舞台。
func _show_save_slots() -> void:
	# 1. 游戏启动直接进入无尽闯关必要入口，不做复杂首页。
	battle_stage.visible = false
	_clear_actions()
	_show_status(I18nText.t("ui.choose_save", "选择存档槽"))
	for index in range(SaveManager.SLOT_COUNT):
		var slot := SaveManager.get_slot(index)
		_add_button("存档 %d：最高通关 %d，永久道具 %d" % [
			index + 1,
			slot.get("highest_cleared_level", 0),
			slot.get("owned_items", []).size()
		], Callable(self, "_select_slot").bind(index))
		_add_button("重置存档 %d" % [index + 1], Callable(self, "_reset_slot_and_refresh").bind(index))
	_add_button("开发测试直达", Callable(self, "_show_debug_launcher"))

## 选择存档槽。
## [参数] slot_index：存档槽索引。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 存档选择流程。
func _select_slot(slot_index: int) -> void:
	# 1. 读取指定槽后进入角色选择和道具搭配。
	selected_slot = slot_index
	RunState.start_from_slot(SaveManager.get_slot(slot_index))
	_show_role_select()

## 重置存档并刷新。
## [参数] slot_index：存档槽索引。
## [返回] 无
## 最近修改时间：2026-06-09 01:12:25 拆出按钮绑定回调。
func _reset_slot_and_refresh(slot_index: int) -> void:
	# 1. 重置动作只影响指定槽，完成后刷新存档列表。
	SaveManager.reset_slot(slot_index)
	_show_save_slots()

## 展示角色选择。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 角色选择阶段隐藏战斗舞台。
func _show_role_select() -> void:
	# 1. 每次进入阶段入口都允许换角，也允许沿用当前角色。
	battle_stage.visible = false
	_clear_actions()
	_show_status("第 %d 关：选择角色或沿用当前角色" % RunState.current_level)
	for character in ConfigDb.get_config("characters").get("characters", []):
		_add_button(I18nText.t(character.get("name_key", ""), character.get("id", "")), Callable(self, "_select_character").bind(String(character.get("id", ""))))
	_add_button("沿用当前角色：%s" % RunState.selected_character, Callable(self, "_show_item_loadout"))

## 选择角色并进入道具搭配。
## [参数] character_id：角色编号。
## [返回] 无
## 最近修改时间：2026-06-09 01:12:25 拆出按钮绑定回调。
func _select_character(character_id: String) -> void:
	# 1. 角色切换只改变角色编号，固定武器技能仍由配置决定。
	RunState.set_character(character_id)
	_show_item_loadout()

## 展示永久道具搭配。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 道具搭配阶段隐藏战斗舞台。
func _show_item_loadout() -> void:
	# 1. 道具来自当前存档永久池，并按阶段携带上限裁剪。
	battle_stage.visible = false
	_clear_actions()
	var slot := SaveManager.get_slot(selected_slot)
	var owned_items: Array = slot.get("owned_items", [])
	var carry_limit := int(ConfigDb.get_config("stage").get("item_carry_limit", 2))
	selected_loadout.clear()
	for item_id in owned_items:
		if selected_loadout.size() < carry_limit:
			selected_loadout.append(String(item_id))
	RunState.set_equipped_items(selected_loadout)
	_show_status("已搭配 %d/%d 个永久道具" % [selected_loadout.size(), carry_limit])
	_add_button("开始第 %d 关" % RunState.current_level, Callable(self, "_start_battle"))
	_add_button("返回存档选择", Callable(self, "_show_save_slots"))

## 开始战斗。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 开始战斗时显示真实战斗舞台。
func _start_battle() -> void:
	# 1. 战斗配置全部通过关卡、角色和道具配置拼装。
	_clear_actions()
	battle_stage.visible = true
	var level_config := ConfigDb.get_level(RunState.current_level)
	var character_config := ConfigDb.get_character(RunState.selected_character)
	if level_config.is_empty() or character_config.is_empty():
		battle_stage.visible = false
		_show_status("缺少关卡或角色配置，无法开始战斗")
		return
	battle_stage.start_battle(level_config, character_config, RunState.equipped_items)
	_refresh_battle_status()

## 展示开发测试直达。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 23:44:00 开发入口隐藏战斗舞台。
func _show_debug_launcher() -> void:
	# 1. 开发入口显式展示，正式玩家流程不会默认进入这里。
	battle_stage.visible = false
	_clear_actions()
	_show_status("开发测试直达：从第 10 关、runner、首个道具启动")
	_add_button("直达第 10 关", Callable(self, "_start_default_debug_launch"))
	_add_button("返回", Callable(self, "_show_save_slots"))

## 启动默认开发直达。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 01:12:25 拆出开发直达默认状态。
func _start_default_debug_launch() -> void:
	# 1. 默认直达第 10 关，用来验证阶段结束和换角。
	var state := DebugLaunch.enable({
		"slot_index": 0,
		"level": 10,
		"character_id": "runner",
		"equipped_items": ["magnet_core"],
		"coins": 30
	})
	RunState.apply_debug_launch(state)
	_show_item_loadout()

## 处理战斗结束。
## [参数] success：是否通关；rewards：结算奖励。
## [返回] 无
## 最近修改时间：2026-06-10 00:08:00 普通关卡通关后播放过渡再自动下一关。
func _on_battle_finished(success: bool, rewards: Dictionary) -> void:
	# 1. 成功才推进关卡，失败不惩罚长期资产。
	_clear_actions()
	if not success:
		battle_stage.visible = false
		SaveManager.record_failure(selected_slot)
		_show_status("挑战失败，长期资产已保留")
		_add_button("重新挑战", Callable(self, "_start_battle"))
		_add_button("返回存档", Callable(self, "_show_save_slots"))
		return
	var saved := SaveManager.record_clear(selected_slot, RunState.current_level, int(rewards.get("coins", 0)))
	var draw_result := _try_draw_item()
	var drawn_item := String(draw_result.get("item_id", ""))
	if bool(draw_result.get("success", false)):
		saved = draw_result.get("slot", saved)
	_show_status("通关第 %d 关，获得金币 %d，抽取结果 %s" % [
		RunState.current_level,
		rewards.get("coins", 0),
		_format_draw_result(drawn_item)
	])
	if RunState.is_stage_end():
		battle_stage.visible = false
		_add_button("阶段完成：重新选择角色", Callable(self, "_advance_after_stage_clear").bind(saved))
	else:
		RunState.current_level += 1
		_play_next_level_transition(RunState.current_level)

## 播放下一关过渡并自动开战。
## [参数] next_level：即将进入的关卡编号。
## [返回] 无
## 最近修改时间：2026-06-10 00:08:00 自动下一关前增加可见过渡。
func _play_next_level_transition(next_level: int) -> void:
	# 1. 普通关卡不进入中间操作页，只给短暂过渡反馈后自动开战。
	battle_stage.visible = false
	_show_status("准备进入第 %d 关" % next_level)
	status_label.modulate = Color(1, 1, 1, 0.0)
	if transition_tween != null:
		transition_tween.kill()
	transition_tween = create_tween()
	transition_tween.tween_property(status_label, "modulate:a", 1.0, 0.25)
	transition_tween.tween_interval(0.65)
	transition_tween.tween_property(status_label, "modulate:a", 0.0, 0.25)
	transition_tween.finished.connect(_start_battle_after_transition)

## 过渡结束后进入下一关。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-10 00:08:00 收口过渡动画回调。
func _start_battle_after_transition() -> void:
	# 1. 过渡后恢复状态文字可见性，再复用正式开战流程。
	status_label.modulate = Color(1, 1, 1, 1)
	_start_battle()

## 阶段完成后推进并开放换角。
## [参数] saved_slot：通关保存后的存档。
## [返回] 无
## 最近修改时间：2026-06-09 01:12:25 拆出阶段推进回调并避免重复推进。
func _advance_after_stage_clear(saved_slot: Dictionary) -> void:
	# 1. 阶段结束后重新按存档计算下一关，并进入角色选择。
	RunState.start_from_slot(saved_slot)
	_show_role_select()

## 尝试抽取永久道具。
## [参数] 无
## [返回] Dictionary，抽取结果。
## 最近修改时间：2026-06-09 01:14:48 按金币消耗抽永久道具。
func _try_draw_item() -> Dictionary:
	# 1. 首版用配置顺序确定性抽取，便于回放和调试。
	var items: Array = ConfigDb.get_config("items").get("items", [])
	var slot := SaveManager.get_slot(selected_slot)
	var cost := int(ConfigDb.get_config("drops").get("item_draw_cost", 10))
	for item in items:
		var item_id := String(item.get("id", ""))
		if not slot.get("owned_items", []).has(item_id):
			print("ITEM_DRAW item=%s source=deterministic_first_missing" % item_id)
			return SaveManager.draw_permanent_item(selected_slot, cost, item_id)
	if items.is_empty():
		return {"success": false, "item_id": "", "slot": slot}
	return SaveManager.draw_permanent_item(selected_slot, cost, String(items[0].get("id", "")))

## 格式化抽取结果。
## [参数] item_id：抽取到的道具编号。
## [返回] String，展示文本。
## 最近修改时间：2026-06-09 01:14:48 抽取结果展示。
func _format_draw_result(item_id: String) -> String:
	# 1. 金币不足时明确展示未抽取，避免玩家误解掉落丢失。
	if item_id.is_empty():
		return "金币不足，未抽取"
	return I18nText.t(ConfigDb.get_item(item_id).get("name_key", ""), item_id)

## 刷新战斗状态展示。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 战斗 HUD 文案。
func _refresh_battle_status() -> void:
	# 1. HUD 必须在 PC 屏幕上清楚展示关卡、角色和倍率。
	_show_status("第 %d 关 | 角色 %s | 倍率 %.0fx" % [
		RunState.current_level,
		RunState.selected_character,
		GameTime.time_scale
	])

## 显示状态文案。
## [参数] text：状态文本。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 主界面状态输出。
func _show_status(text: String) -> void:
	# 1. 状态栏承担第一版主要反馈，保证 Demo 可读。
	status_label.text = text

## 清空按钮区。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 UI 动作区复用。
func _clear_actions() -> void:
	# 1. 每个流程页面重建按钮，避免旧按钮残留。
	for child in action_panel.get_children():
		child.queue_free()

## 添加按钮。
## [参数] text：按钮文本；callback：点击回调。
## [返回] Button，新按钮节点。
## 最近修改时间：2026-06-09 01:01:30 主流程按钮构造。
func _add_button(text: String, callback: Callable) -> Button:
	# 1. 所有入口保持 PC 可点击控件，避免隐藏脚本入口。
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(360, 42)
	button.pressed.connect(callback)
	action_panel.add_child(button)
	return button

## 拼接字符串数组。
## [参数] values：字符串数组；separator：分隔符。
## [返回] String，拼接后的文本。
## 最近修改时间：2026-06-09 01:12:25 替代不稳定数组 join 调用。
func _join_strings(values: Array[String], separator: String) -> String:
	# 1. 显式拼接用于 Godot 版本差异下的错误展示稳定性。
	var output := ""
	for index in range(values.size()):
		if index > 0:
			output += separator
		output += values[index]
	return output
