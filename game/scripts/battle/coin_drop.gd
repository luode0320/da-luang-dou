extends Area2D

var value := 1

## 初始化金币掉落。
## [参数] coin_value：金币数量。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 金币掉落节点。
func setup(coin_value: int) -> void:
	# 1. 掉落数值由掉落配置传入，不在节点中写死。
	value = coin_value
