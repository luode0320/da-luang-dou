# 首版原创占位素材接入验证

## 测试目的

验证首套原创 SVG 占位素材已经接入 Godot 主游戏工程，并确认玩家、敌人、金币、投射物、命中特效与道具素材不会引入第三方素材授权风险。

## 测试对象

- `game/assets/sprites/`
- `game/assets/items/`
- `game/assets/README.md`
- `game/scenes/battle/Player.tscn`
- `game/scenes/battle/Enemy.tscn`
- `game/scenes/battle/CoinDrop.tscn`
- `game/scenes/battle/Projectile.tscn`
- `game/scenes/effects/HitEffect.tscn`
- `game/scenes/battle/BattleStage.tscn`
- `game/scripts/battle/battle_stage.gd`
- `game/scripts/battle/enemy_actor.gd`
- `game/scripts/battle/player_controller.gd`

## 真实测试资产入口

- 复用既有首轮流程脚本：`test/2026-06-09_010830/game/scripts/autoload/validate_first_cycle.py`
- 本轮执行记录入口：`test/2026-06-10_222519/首版原创占位素材接入验证/README.md`

## 执行前置条件

- Windows PowerShell 环境。
- Godot 运行文件存在于 `tools/windows/runtime/godot/Godot_v4.x.exe`。
- 当前仓库根目录为 `e:\da-luang-dou`。
- 中文文档按 UTF-8 读取与写入。

## 执行方式

```powershell
tools\windows\runtime\godot\Godot_v4.x.exe --headless --path game --import
```

```powershell
tools\windows\runtime\godot\Godot_v4.x.exe --headless --path game --scene res://scenes/app/Main.tscn --quit-after 5
```

```powershell
$env:PYTHONUTF8='1'; python test\2026-06-09_010830\game\scripts\autoload\validate_first_cycle.py
```

## 覆盖范围

- 覆盖 SVG 原始素材导入与 `.svg.import` 元数据生成。
- 覆盖战斗主场景加载，不出现缺失贴图、节点路径错误或脚本运行时报错。
- 覆盖首轮核心游戏流程脚本验证。
- 覆盖原创素材说明文件可追溯性。

## 验证结论

- 首套素材为项目内原创 SVG 占位资源，未使用第三方素材。
- Godot 导入后已生成对应 `.svg.import` 文件。
- Headless 场景启动通过，无 Godot 报错。
- 首轮流程脚本验证通过，输出 `[first-cycle] validation passed`。

## 未覆盖项

- 未做美术最终品质验收，本轮仅验证首版占位素材可用性与接入稳定性。
- 未做长时间运行压力验证。
