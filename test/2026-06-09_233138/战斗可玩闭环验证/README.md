# 战斗可玩闭环验证

## 测试目的

验证第一版 Demo 进入战斗后不再只是静态画面，而是具备玩家移动、怪物生成、自动攻击、击败怪物和金币掉落/拾取的基础可玩闭环。

## 测试对象

- `game/scripts/app/main.gd`
- `game/scripts/battle/battle_stage.gd`
- `game/scripts/battle/enemy_actor.gd`
- `game/scripts/battle/projectile_actor.gd`

## 执行方式

基础启动校验：

```powershell
tools/windows/runtime/godot/Godot_v4.x.exe --headless --path game --scene res://scenes/app/Main.tscn --quit-after 10
```

窗口可玩校验：

```bash
./tools/windows/run_game.cmd
```

## 验证范围

- 配置可加载。
- 主场景可启动。
- 启动后战斗舞台不再遮挡存档选择。
- 点击存档、选择角色、开始第 1 关后进入战斗舞台。
- WASD 和方向键都能移动玩家。
- 怪物会从战斗区域边缘生成并追踪玩家。
- 玩家会自动向最近怪物发射子弹。
- 子弹命中后能击败怪物并掉落金币。
- HUD 显示 HP、击败数、金币数和操作说明。
- 小键盘 `+/-` 和主键盘 `+/-` 都能在 1x、2x、3x 三档循环调速，`+` 为 1->2->3->1，`-` 为 1->3->2->1。
- ESC 能暂停和恢复战斗。
- 普通关卡通关后播放短暂过渡动画，再自动进入下一关，不显示中间继续页面。

## 验证结论

基础启动校验通过：主场景可在 headless 模式启动并按 `--quit-after 10` 正常退出。倍率循环命令行验证通过：`+` 输出 `[2.0, 3.0, 1.0]`，`-` 输出 `[3.0, 2.0, 1.0]`。窗口可玩校验需要在本机打开游戏窗口确认操作手感和实体表现。
