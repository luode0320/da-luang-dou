# 第一版核心闭环验证

## 验证对象

- Godot 4 工程骨架：`game/project.godot`
- 配置驱动数据：`game/data/`
- 存档、配置、倍率、主流程和战斗脚本：`game/scripts/`
- PC 构建基线文档：`game/docs/pc_build_baseline.md`

## 验证范围

本轮验证第一周期核心闭环：选存档、选角色、搭配道具、进关战斗、掉金币、抽永久道具、通关保存、10 关阶段推进、开发测试直达、10 倍加速口径和 PC 桌面游戏形态。

## 执行环境

- 当前机器未检测到 Godot 4 命令行。
- 已执行 Python 静态和模拟闭环验证。
- Godot 运行验证需要安装 Godot 4 后打开 `game/project.godot`。

## 执行命令

```powershell
python test\2026-06-09_010830\game\scripts\autoload\validate_first_cycle.py
```

## 结论

通过。验证脚本已覆盖：

- 第一阶段 1-10 关配置完整。
- 阶段配置控制永久道具携带上限。
- 角色均绑定固定武器和固定技能。
- 怪物难度通过行为标签和组合表达。
- 三个存档槽互相独立，重置单槽不影响其他槽。
- 旧存档字段缺失时可补默认值。
- 通关 1-10 关后保存最高进度、金币和永久道具。
- 永久道具通过已保存金币抽取，并扣除抽取消耗，金币不会变成负数。
- 失败模拟不惩罚长期资产。
- 统一倍率支持最高 10 倍。
- 开发测试直达可指定关卡、角色和道具。
- Godot 工程具备主场景、PC 窗口、键盘输入和 Windows Desktop 导出预设。
- 场景引用的脚本和资源路径存在。
- 新增 GDScript 函数均具备 `[参数]`、`[返回]`、`最近修改时间` 注释。
- 已检查关键 Godot 风险：倍率未通过 `Engine.time_scale` 重复叠加，阶段结束不重复推进关卡，按钮回调使用显式 `Callable`，存档目录使用 `user://` 路径创建。

## 执行结果摘要

```text
[first-cycle] validation passed
json-ok
godot-not-found
```

## 未执行项

当前机器未安装 Godot 4，且 `winget`、`choco`、`scoop` 均不可用，因此本轮未能执行 Godot 引擎级运行和导出构建。安装 Godot 4 后，可打开 `game/project.godot` 执行运行验证，并通过 `game/export_presets.cfg` 导出 Windows Demo。
