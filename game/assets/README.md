# 游戏素材记录

## 说明

- 本目录素材为本项目首版原创占位 SVG，用于替换纯色方块实体。
- 素材风格参考“俯视角 2D 自动射击肉鸽”的通用表现方式，不使用 Brotato 原作素材，不复刻可识别角色或图标。
- 许可证：项目内部原创资产，默认随本项目源码一同使用；若后续改为第三方素材，必须按根目录 `AGENTS.md` 记录来源、作者、链接、许可证和用途。
- 当前素材替换目标已收窄为“只替换战斗背景地图”；在合规地图文件由用户提供并确认可导入前，本仓库仍只保留原创占位素材。

## 第三方素材候选与授权记录

| 素材包 | 作者/来源 | 链接 | 用途 | 授权口径 | 当前状态 |
| --- | --- | --- | --- | --- | --- |
| `Kenney - Topdown Shooter Pack` | Kenney Vleugels / Kenney.nl | `https://www.kenney.nl/assets/top-down-shooter` | 当前战斗背景地图素材套装，已烘焙为开放草地版 `maps/arena_kenney_open_grass.png` | `CC0`，可用于个人和商业项目，署名非强制 | 已直接下载并接入，源文件位于 `external/kenney_top_down_shooter/` |
| `Free Simple Summer Top-Down Vector Tileset` | CraftPix.net | `https://craftpix.net/freebies/free-simple-summer-top-down-vector-tileset/` | 战斗背景地图与地面装饰素材 | 页面说明可免费用于无限项目；需遵循 CraftPix 免费素材许可证，不得转售或再分发素材本身 | 需要登录/人工下载，不作为 AI 自动接入选项；仅在用户手动提供文件后可继续接入 |
| `Graveyard Blast - 2D Game Sprites Asset Pack` | Made by Chaz / itch.io | `https://madebychaz.itch.io/graveyard-blast` | 曾评估为整套玩家、怪物、武器、子弹、特效、UI 与墓地地图素材 | 页面说明可用于个人和商业游戏项目；禁止重新打包、转售或再分发素材本身 | 目标已收窄为只换地图，暂不采用付费整包方案 |

## 首版原创占位素材清单

| 文件 | 用途 | 来源 | 许可证口径 |
| --- | --- | --- | --- |
| `sprites/player_runner.svg` | runner 玩家占位形象 | 本项目原创 SVG | 项目自有 |
| `sprites/player_guard.svg` | guard 玩家占位形象 | 本项目原创 SVG | 项目自有 |
| `sprites/enemy_chaser.svg` | 追踪怪占位形象 | 本项目原创 SVG | 项目自有 |
| `sprites/enemy_zigzag.svg` | 折线怪占位形象 | 本项目原创 SVG | 项目自有 |
| `sprites/enemy_charger.svg` | 冲刺怪占位形象 | 本项目原创 SVG | 项目自有 |
| `sprites/enemy_splitter.svg` | 分裂怪占位形象 | 本项目原创 SVG | 项目自有 |
| `sprites/projectile_spark.svg` | 子弹占位形象 | 本项目原创 SVG | 项目自有 |
| `sprites/coin.svg` | 金币占位形象 | 本项目原创 SVG | 项目自有 |
| `sprites/hit_flash.svg` | 命中特效占位形象 | 本项目原创 SVG | 项目自有 |
| `maps/arena_scrapyard.svg` | 战斗背景地图底图 | 本项目原创 SVG | 项目自有 |
| `maps/arena_kenney_top_down_shooter.png` | 旧版战斗背景地图底图 | Kenney Topdown Shooter Pack 派生烘焙图 | `CC0` |
| `maps/arena_kenney_open_grass.png` | 当前战斗背景地图底图，开放草地布局，无贯通道路 | Kenney Topdown Shooter Pack 派生烘焙图 | `CC0` |
| `items/magnet_core.svg` | 永久道具图标 | 本项目原创 SVG | 项目自有 |
| `items/brass_trigger.svg` | 永久道具图标 | 本项目原创 SVG | 项目自有 |
| `items/warm_battery.svg` | 永久道具图标 | 本项目原创 SVG | 项目自有 |
