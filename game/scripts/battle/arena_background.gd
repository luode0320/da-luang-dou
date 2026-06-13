extends Node2D

const DEFAULT_ARENA_RECT := Rect2(Vector2.ZERO, Vector2(1280, 720))
const TILE_SIZE := 52.0

var arena_rect := DEFAULT_ARENA_RECT

## 设置战斗场地绘制范围。
## [参数] rect：当前可见战斗区域。
## [返回] 无
## 最近修改时间：2026-06-10 23:17:49 跟随实际视口重绘背景叠加层。
func setup(rect: Rect2) -> void:
	# 1. 叠加层跟随 BattleStage 的运行时区域，避免窗口尺寸变化后边缘露出旧范围。
	arena_rect = rect
	queue_redraw()

## 绘制战斗场地背景。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-11 00:51:26 延展地图下关闭重复细线叠加减少移动闪烁。
func _draw() -> void:
	# 1. 网格和磨损已经烘进 Arena 贴图，运行时只保留边界，避免细线随相机移动产生闪烁。
	_draw_arena_edges()

## 绘制地面网格。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-10 23:24:38 网格改为读取运行时战斗区域。
func _draw_tile_grid() -> void:
	# 1. 网格保持很低对比，参考俯视生存游戏的粗糙地砖感，不抢角色主体。
	var grid_color := Color(0.62, 0.72, 0.46, 0.12)
	var x := arena_rect.position.x
	while x <= arena_rect.end.x:
		draw_line(Vector2(x, arena_rect.position.y), Vector2(x, arena_rect.end.y), grid_color, 1.0)
		x += TILE_SIZE
	var y := arena_rect.position.y
	while y <= arena_rect.end.y:
		draw_line(Vector2(arena_rect.position.x, y), Vector2(arena_rect.end.x, y), grid_color, 1.0)
		y += TILE_SIZE

## 绘制地面磨损和碎点。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-10 23:24:38 磨损点改为读取运行时战斗区域。
func _draw_ground_marks() -> void:
	# 1. 使用固定序列绘制碎点和划痕，避免每帧随机导致背景闪动。
	for index in range(90):
		var point := Vector2(
			arena_rect.position.x + float((index * 97) % int(arena_rect.size.x)),
			arena_rect.position.y + float((index * 53) % int(arena_rect.size.y))
		)
		var radius := 1.0 + float(index % 3)
		draw_circle(point, radius, Color(0.58, 0.61, 0.42, 0.14))
	for index in range(18):
		var start := Vector2(
			arena_rect.position.x + float((index * 151) % int(arena_rect.size.x)),
			arena_rect.position.y + float((index * 89) % int(arena_rect.size.y))
		)
		var finish := start + Vector2(18.0 + float(index % 4) * 7.0, -8.0 + float(index % 5) * 4.0)
		draw_line(start, finish, Color(0.74, 0.58, 0.32, 0.16), 2.0)

## 绘制竞技场边界。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-10 23:24:38 边界改为跟随运行时战斗区域。
func _draw_arena_edges() -> void:
	# 1. 边框把战斗范围从主界面背景里切出来，避免玩家误判可移动区域。
	draw_rect(arena_rect.grow(10.0), Color(0.055, 0.07, 0.06, 1.0), false, 10.0)
	draw_rect(arena_rect.grow(3.0), Color(0.27, 0.31, 0.22, 1.0), false, 3.0)
	draw_rect(arena_rect.grow(-12.0), Color(0.04, 0.05, 0.045, 0.18), false, 24.0)
