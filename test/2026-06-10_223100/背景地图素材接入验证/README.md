# 背景地图素材接入验证

## 测试目的

验证首版原创背景地图素材已经接入战斗场景，确认地图底图、网格叠加层和战斗边界能够同时显示，并且不影响既有战斗流程。

## 测试对象

- `game/assets/maps/arena_scrapyard.svg`
- `game/assets/maps/arena_scrapyard.svg.import`
- `game/assets/README.md`
- `game/scenes/battle/BattleStage.tscn`
- `game/scripts/battle/arena_background.gd`

## 真实测试资产入口

- 复用既有首轮流程脚本：`test/2026-06-09_010830/game/scripts/autoload/validate_first_cycle.py`
- 本轮执行记录入口：`test/2026-06-10_223100/背景地图素材接入验证/README.md`

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

- 覆盖背景地图 SVG 导入与 `.svg.import` 元数据生成。
- 覆盖战斗主场景加载，不出现贴图缺失或节点类型错误。
- 覆盖 `ArenaBackground` 作为地图上层辅助绘制时的脚本注释检查。
- 覆盖既有首轮流程验证，确认战斗链路未受地图接入影响。

## 验证结论

- `arena_scrapyard.svg` 为项目内原创 SVG 背景地图素材，未使用第三方素材。
- Godot 导入后已生成 `arena_scrapyard.svg.import`。
- Headless 主场景启动通过，无 Godot 报错。
- 首轮流程脚本验证通过，输出 `[first-cycle] validation passed`。

## 未覆盖项

- 未做编辑器可视化截图验收，本轮以资源导入、场景加载和流程脚本验证为准。
- 未做多地图切换机制，当前只接入首张战斗背景底图。

## 追加验证：开始游戏后地图铺满窗口

### 验证目的

确认进入战斗后，背景地图、网格叠加层、玩家边界和刷怪边界都跟随实际视口尺寸，不再只覆盖固定小竞技场区域。

### 执行方式

- 使用 Godot AI MCP 连接 `game@0394` 会话。
- 启动主场景：`project_run(mode="main", autosave=true)`。
- 通过运行时 `game_eval` 调用主流程进入第 1 关战斗。
- 读取运行时 `BattleStage/Arena` 的视口、位置、缩放和覆盖尺寸。

### 关键结果

- 运行视口：`1280 x 720`。
- 战斗区域：`Rect2((0, 0), (1280, 720))`。
- 地图位置：`(640, 360)`。
- 地图缩放：`(1.3127273, 1.3127273)`。
- 地图实际覆盖尺寸：约 `1365.24 x 722.00`。
- 宽度覆盖：通过。
- 高度覆盖：通过。
- 战斗状态：`BattleStage.visible = true`，`UiRoot.visible = false`。

### 结论

开始游戏并进入战斗后，地图已经铺满整个游戏窗口；地图贴图覆盖范围宽高都大于当前视口，保留 2 像素安全边距，避免浮点精度导致边缘露缝。

## 追加验证：延展地图与相机跟随

### 验证目的

确认战斗地图不再只有一屏大小，而是扩展为类似《土豆兄弟》的大地图；玩家移动到地图边缘附近时，相机跟随玩家推进，并在地图边界处停止。

### 执行方式

- 使用 Godot AI MCP 连接 `game@0394` 会话。
- 启动主场景：`project_run(mode="main", autosave=true)`。
- 通过运行时 `game_eval` 进入第 1 关战斗。
- 读取运行时 `BattleStage`、`Player/BattleCamera`、`Arena` 和 `HudLayer/BattleInfo` 状态。
- 将玩家移动到右下边缘附近，读取相机位置和边界限制。

### 关键结果

- 运行视口：`1280 x 720`。
- 扩展地图尺寸：`3840 x 2160`，宽高均为当前视口的 3 倍。
- 地图实际覆盖尺寸：约 `4088.15 x 2162.00`。
- 玩家出生位置：`(1920, 1080)`。
- 出生后首个怪物距离玩家：约 `429.39` 像素，属于当前视野附近刷怪。
- 右下边缘测试玩家位置：`(3720, 2040)`。
- 相机全局位置：`(3720, 2040)`。
- 相机限制：left `0`，top `0`，right `3840`，bottom `2160`。
- 右下边缘刷怪样本：`(3366.40, 2160.00)`，仍限制在扩展地图边界内。
- HUD 父节点：`HudLayer`，屏幕位置保持 `(24, 18)`。

### 结论

延展地图验证通过：玩家活动范围已经扩展到三倍屏幕宽高，相机跟随玩家移动，HUD 固定在屏幕层；刷怪入口改为围绕当前视野边缘生成，避免大地图下敌人从世界最外圈生成导致距离过远。

## 追加验证：移动清晰度与相机抖动

### 验证目的

确认角色移动时减少模糊、重叠感和相机追随抖动，优先处理相机平滑延迟、子像素采样和地图贴图运行时放大导致的视觉问题。

### 调整内容

- 关闭 `BattleCamera.position_smoothing_enabled`，避免相机追随玩家时产生延迟残影。
- 开启项目设置 `rendering/2d/snap/snap_2d_transforms_to_pixel`。
- 开启项目设置 `rendering/2d/snap/snap_2d_vertices_to_pixel`。
- 将 `arena_scrapyard.svg` 导出画布从 `1040 x 550` 提升到 `4160 x 2200`。
- 地图运行时缩放改为只在贴图不足以覆盖世界时才放大，当前验证下 `Arena.scale = (1, 1)`。
- 关闭运行时重复绘制的网格和磨损细线叠加层，避免细线随相机移动产生闪烁和重叠感。

### 关键结果

- 扩展地图尺寸：`3840 x 2160`。
- 地图纹理尺寸：`4160 x 2200`。
- 地图运行时缩放：`(1.0, 1.0)`。
- 地图实际覆盖尺寸：`4160 x 2200`。
- 相机平滑：关闭。
- 像素吸附：transform 与 vertex 均开启。
- 玩家与相机位置：一致，移动时不再存在相机平滑追随偏移。
- Godot AI 嵌入 DEBUG 运行监控 FPS：约 `28`，该值仍受编辑器调试/嵌入运行环境影响。
- 关闭叠加细线后的嵌入 DEBUG 监控 FPS：约 `25`，未观察到错误日志，但帧率仍需独立性能专项继续分析。

### 结论

移动模糊的主要来源已处理：相机不再平滑延迟，2D 子像素吸附已开启，大地图贴图不再被运行时放大近 4 倍，重复细线叠加也已关闭。若独立运行包仍低帧率，需要继续从渲染负载、窗口模式和素材复杂度方向做性能专项验证。
