extends CanvasLayer

@onready var label: Label = %HudLabel

## 刷新 HUD。
## [参数] text：展示文本。
## [返回] 无
## 最近修改时间：2026-06-09 01:01:30 PC HUD 显示。
func set_text(text: String) -> void:
	# 1. HUD 文案保持集中入口，后续可替换为图标和更正式布局。
	label.text = text
