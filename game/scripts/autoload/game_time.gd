extends Node

const MIN_SCALE := 1.0
const MAX_SCALE := 3.0

var time_scale := 1.0

## 设置统一游戏时间倍率。
## [参数] value：目标倍率。
## [返回] float，返回裁剪后的倍率。
## 最近修改时间：2026-06-10 01:07:00 限制为 1/2/3 三档倍率。
func set_scale(value: float) -> float:
	# 1. 所有系统共用这个倍率，并固定到 1/2/3 三档，避免出现小数倍率。
	time_scale = clamp(round(value), MIN_SCALE, MAX_SCALE)
	print("TIME_SCALE_SET value=%.2f" % time_scale)
	return time_scale

## 提高倍率。
## [参数] step：提升步长。
## [返回] float，返回新的倍率。
## 最近修改时间：2026-06-10 01:07:00 加号按 1/2/3 循环切换。
func increase(step: float = 1.0) -> float:
	# 1. 加号使用正向循环：1 -> 2 -> 3 -> 1。
	if time_scale >= MAX_SCALE:
		return set_scale(MIN_SCALE)
	return set_scale(time_scale + step)

## 降低倍率。
## [参数] step：降低步长。
## [返回] float，返回新的倍率。
## 最近修改时间：2026-06-10 01:07:00 减号按 1/3/2 循环切换。
func decrease(step: float = 1.0) -> float:
	# 1. 减号使用反向循环：1 -> 3 -> 2 -> 1。
	if time_scale <= MIN_SCALE:
		return set_scale(MAX_SCALE)
	return set_scale(time_scale - step)
