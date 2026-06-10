extends Node2D

const ARENA_RECT := Rect2(Vector2(120, 110), Vector2(1040, 550))
const TILE_SIZE := 52.0

## 绘制战斗场地背景。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-10 21:56:39 新增类土豆兄弟的暗色竞技场背景。
func _draw() -> void:
	# 1. 先铺一层低饱和地面，保证占位角色和怪物在深色背景上清楚可见。
	draw_rect(ARENA_RECT, Color(0.105, 0.125, 0.105, 1.0), true)
	_draw_tile_grid()
	_draw_ground_marks()
	_draw_arena_edges()

## 绘制地面网格。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-10 21:56:39 增加竞技场地砖层次。
func _draw_tile_grid() -> void:
	# 1. 网格保持很低对比，参考俯视生存游戏的粗糙地砖感，不抢角色主体。
	var grid_color := Color(0.18, 0.21, 0.17, 0.34)
	var x := ARENA_RECT.position.x
	while x <= ARENA_RECT.end.x:
		draw_line(Vector2(x, ARENA_RECT.position.y), Vector2(x, ARENA_RECT.end.y), grid_color, 1.0)
		x += TILE_SIZE
	var y := ARENA_RECT.position.y
	while y <= ARENA_RECT.end.y:
		draw_line(Vector2(ARENA_RECT.position.x, y), Vector2(ARENA_RECT.end.x, y), grid_color, 1.0)
		y += TILE_SIZE

## 绘制地面磨损和碎点。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-10 21:56:39 增加战斗背景的粗糙纹理。
func _draw_ground_marks() -> void:
	# 1. 使用固定序列绘制碎点和划痕，避免每帧随机导致背景闪动。
	for index in range(90):
		var point := Vector2(
			ARENA_RECT.position.x + float((index * 97) % int(ARENA_RECT.size.x)),
			ARENA_RECT.position.y + float((index * 53) % int(ARENA_RECT.size.y))
		)
		var radius := 1.0 + float(index % 3)
		draw_circle(point, radius, Color(0.27, 0.29, 0.21, 0.22))
	for index in range(18):
		var start := Vector2(
			ARENA_RECT.position.x + float((index * 151) % int(ARENA_RECT.size.x)),
			ARENA_RECT.position.y + float((index * 89) % int(ARENA_RECT.size.y))
		)
		var finish := start + Vector2(18.0 + float(index % 4) * 7.0, -8.0 + float(index % 5) * 4.0)
		draw_line(start, finish, Color(0.32, 0.28, 0.2, 0.28), 2.0)

## 绘制竞技场边界。
## [参数] 无
## [返回] 无
## 最近修改时间：2026-06-10 21:56:39 增加场地边框和暗角层次。
func _draw_arena_edges() -> void:
	# 1. 边框把战斗范围从主界面背景里切出来，避免玩家误判可移动区域。
	draw_rect(ARENA_RECT.grow(10.0), Color(0.055, 0.07, 0.06, 1.0), false, 10.0)
	draw_rect(ARENA_RECT.grow(3.0), Color(0.27, 0.31, 0.22, 1.0), false, 3.0)
	draw_rect(ARENA_RECT.grow(-12.0), Color(0.04, 0.05, 0.045, 0.18), false, 24.0)
