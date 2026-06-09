extends Node

const MIN_SCALE := 1.0
const MAX_SCALE := 10.0

var time_scale := 1.0

## 设置统一游戏时间倍率。
## [参数] value：目标倍率。
## [返回] float，返回裁剪后的倍率。
## 最近修改时间：2026-06-09 01:01:30 首版加速倍率入口。
func set_scale(value: float) -> float:
	# 1. 所有系统共用这个倍率，避免移动、冷却和刷怪各算各的。
	time_scale = clamp(value, MIN_SCALE, MAX_SCALE)
	print("TIME_SCALE_SET value=%.2f" % time_scale)
	return time_scale

## 提高倍率。
## [参数] step：提升步长。
## [返回] float，返回新的倍率。
## 最近修改时间：2026-06-09 01:01:30 PC 键盘倍率控制。
func increase(step: float = 1.0) -> float:
	# 1. 键盘入口只调用统一倍率设置，防止绕开上限。
	return set_scale(time_scale + step)

## 降低倍率。
## [参数] step：降低步长。
## [返回] float，返回新的倍率。
## 最近修改时间：2026-06-09 01:01:30 PC 键盘倍率控制。
func decrease(step: float = 1.0) -> float:
	# 1. 倍率最低为 1，第一版不做慢动作模式。
	return set_scale(time_scale - step)
