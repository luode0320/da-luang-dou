# Kenney 地图素材接入验证

## 测试目的

验证 `Kenney - Topdown Shooter Pack` 已作为当前战斗背景地图素材套装接入 Godot，确认素材来源合规、无需登录可直接下载、地图贴图正确导入，并且进入战斗后能实际显示。

## 测试对象

- `game/assets/external/kenney_top_down_shooter/kenney_top-down-shooter.zip`
- `game/assets/external/kenney_top_down_shooter/source/License.txt`
- `game/assets/maps/arena_kenney_top_down_shooter.png`
- `game/assets/maps/arena_kenney_top_down_shooter.png.import`
- `game/assets/README.md`
- `game/scenes/battle/BattleStage.tscn`

## 素材来源

- 来源页面：`https://www.kenney.nl/assets/top-down-shooter`
- 直接下载：`https://www.kenney.nl/media/pages/assets/top-down-shooter/230204340a-1677694684/kenney_top-down-shooter.zip`
- 作者：Kenney Vleugels / Kenney.nl
- 许可证：Creative Commons Zero (`CC0`)
- 下载条件：无需登录、无需付费、无需验证码，可由 AI 直接下载。

## 执行方式

- 使用 Godot AI MCP 对 `res://assets/maps/arena_kenney_top_down_shooter.png` 执行 `filesystem_manage(op="reimport")`。
- 使用 Godot AI MCP 启动主场景：`project_run(mode="main", autosave=true)`。
- 通过运行时 `game_eval` 调用主流程 `_start_battle` 进入战斗。
- 使用运行时状态读取和游戏截图验证地图显示。

## 关键结果

- 新地图纹理路径：`res://assets/maps/arena_kenney_top_down_shooter.png`。
- 新地图纹理尺寸：`3840 x 2160`。
- Godot 导入文件：`game/assets/maps/arena_kenney_top_down_shooter.png.import` 已生成。
- 战斗区域尺寸：`3840 x 2160`。
- 运行视口尺寸：`1280 x 720`。
- `BattleStage.top_level = true` 后，相机中心正确移动到玩家出生点。
- 进入战斗后运行时状态：
  - `BattleStage.visible = true`
  - `BattleStage.active = true`
  - `Arena.texture.resource_path = res://assets/maps/arena_kenney_top_down_shooter.png`
  - `BattleStage.enemies.size() = 3`
- 游戏截图中已显示 Kenney 地图草地、道路、道具散点、玩家、怪物和掉落物。

## 验证结论

通过。当前战斗地图已从项目原创 SVG 占位图切换为 Kenney Topdown Shooter Pack 派生烘焙图；素材来源、授权和用途已记录，Godot 导入成功，运行时进入战斗后地图可见。

## 未覆盖项

- 本轮只接入地图素材，没有替换角色、怪物、武器、子弹或 UI。
- 本轮使用烘焙 PNG 作为背景图，没有改造成 TileMap 编辑器地图。
- 当前画面仍是 Kenney 简洁卡通风，后续若追求更接近商业精修观感，需要继续寻找更高精度且可直接下载的免费素材。
