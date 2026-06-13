# 暂停设置窗口与实体冻结验证

## 测试目的

验证战斗中触发暂停后会弹出设置窗口，并确认玩家、怪物、武器子弹、金币等战斗实体在暂停期间停止处理，不再继续移动或结算。

## 测试对象

- `game/scenes/app/Main.tscn`
- `game/scripts/app/main.gd`
- `game/scripts/battle/battle_stage.gd`

## 真实测试资产入口

- 复用既有首轮流程脚本：`test/2026-06-09_010830/game/scripts/autoload/validate_first_cycle.py`
- 本轮执行记录入口：`test/2026-06-10_225403/暂停设置窗口与实体冻结验证/README.md`

## 执行前置条件

- Windows PowerShell 环境。
- Godot 运行文件存在于 `tools/windows/runtime/godot/Godot_v4.x.exe`。
- Godot AI MCP 可连接运行中的游戏窗口。
- 当前仓库根目录为 `e:\da-luang-dou`。

## 执行方式

```powershell
tools\windows\runtime\godot\Godot_v4.x.exe --headless --path game --scene res://scenes/app/Main.tscn --quit-after 5
```

```powershell
$env:PYTHONUTF8='1'; python test\2026-06-09_010830\game\scripts\autoload\validate_first_cycle.py
```

运行时验证通过 Godot AI `game_eval` 执行：

- 启动主场景并进入战斗。
- 生成怪物和子弹。
- 记录玩家、怪物、子弹位置。
- 调用暂停入口并等待 0.6 秒真实时间。
- 再次读取位置并计算位移。

## 覆盖范围

- 覆盖 ESC 暂停入口和暂停设置窗口显示。
- 覆盖 Godot 原生 `SceneTree.paused` 状态。
- 覆盖玩家、怪物和子弹暂停冻结。
- 覆盖恢复暂停后不会残留暂停窗口。
- 覆盖实时刷怪时怪物贴图初始化顺序。

## 验证结论

- Headless 主场景启动通过，无 Godot 报错。
- 首轮流程脚本验证通过，输出 `[first-cycle] validation passed`。
- 运行时断言结果：`paused_tree=true`，`overlay_visible=true`。
- 暂停 0.6 秒期间位移：`player_delta=0.0`，`enemy_delta=0.0`，`projectile_delta=0.0`。
- 修复后暂停期间战斗实体不再移动。

## 未覆盖项

- 暂停设置窗口当前只提供继续游戏入口和倍率提示，尚未接入音量、画质等设置项。
- 未做长时间多次暂停/恢复压力验证。
