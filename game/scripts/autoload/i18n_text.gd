extends Node

const DEFAULT_LOCALE := "zh_cn"
const TEXT_PATH := "res://data/i18n/zh_cn.json"

var texts: Dictionary = {}

## 加载简体中文文案。
## [参数] 无
## [返回] bool，加载成功返回 true。
## 最近修改时间：2026-06-09 01:30:32 显式声明 Variant，兼容 Godot 4.6 导出检查。
func load_texts() -> bool:
	# 1. 第一版只交付简体中文，但所有可见文案从表读取。
	if not FileAccess.file_exists(TEXT_PATH):
		push_error("文案文件不存在: %s" % TEXT_PATH)
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(TEXT_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("文案文件格式错误: %s" % TEXT_PATH)
		return false
	texts = parsed
	return true

## 读取文案。
## [参数] key：文案键；fallback：缺失时回退文本。
## [返回] String，最终展示文本。
## 最近修改时间：2026-06-09 01:01:30 UI 文案读取接口。
func t(key: String, fallback: String = "") -> String:
	# 1. 缺文案时显示回退文本，便于开发阶段定位缺失键。
	return String(texts.get(key, fallback if not fallback.is_empty() else key))
