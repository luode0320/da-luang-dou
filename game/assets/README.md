# 游戏素材记录

## 说明

- 本目录素材以项目原创 2D 资产为主，当前角色、怪物、子弹、金币、命中闪光、道具图标和战斗地图都已重构为统一视觉族。
- 当前视觉方向为“俯视角自动射击游戏”的清晰非像素商业化 2D 风格：高可读轮廓、统一粗描边、亮面材质点缀、低噪点底图、空旷竞技场式中央清爽战斗区与明确玩法识别优先级。
- 外部免费素材站资源默认只作为参考板、比例参考、层次参考和风格拆解来源，不直接作为最终游戏资产入库。
- 许可证：项目内部原创资产默认随本项目源码一同使用；若后续改为第三方素材，必须按根目录 `AGENTS.md` 记录来源、作者、链接、许可证和用途。

## 第三方素材候选与授权记录

| 素材包 | 作者/来源 | 链接 | 用途 | 授权口径 | 当前状态 |
| --- | --- | --- | --- | --- | --- |
| `Kenney - Topdown Shooter Pack` | Kenney Vleugels / Kenney.nl | `https://www.kenney.nl/assets/top-down-shooter` | 仅作为俯视地图可读性、地面装饰密度与道具层次参考，不再作为当前运行时地图资产 | `CC0`，可用于个人和商业项目，署名非强制 | 保留为参考源，源文件位于 `external/kenney_top_down_shooter/` |
| `Free Simple Summer Top-Down Vector Tileset` | CraftPix.net | `https://craftpix.net/freebies/free-simple-summer-top-down-vector-tileset/` | 战斗背景地图与地面装饰素材 | 页面说明可免费用于无限项目；需遵循 CraftPix 免费素材许可证，不得转售或再分发素材本身 | 需要登录/人工下载，不作为 AI 自动接入选项；仅在用户手动提供文件后可继续接入 |
| `Graveyard Blast - 2D Game Sprites Asset Pack` | Made by Chaz / itch.io | `https://madebychaz.itch.io/graveyard-blast` | 曾评估为整套玩家、怪物、武器、子弹、特效、UI 与墓地地图素材 | 页面说明可用于个人和商业游戏项目；禁止重新打包、转售或再分发素材本身 | 目标已收窄为只换地图，暂不采用付费整包方案 |

## 当前原创 2D 素材清单

| 文件 | 用途 | 来源 | 许可证口径 |
| --- | --- | --- | --- |
| `sprites/player_runner.svg` | runner 主角，轻型高机动轮廓 | 本项目原创 SVG | 项目自有 |
| `sprites/player_guard.svg` | guard 主角，重装防御轮廓 | 本项目原创 SVG | 项目自有 |
| `sprites/enemy_chaser.svg` | 追踪怪，尖锐前压轮廓 | 本项目原创 SVG | 项目自有 |
| `sprites/enemy_zigzag.svg` | 折线怪，折角风筝轮廓 | 本项目原创 SVG | 项目自有 |
| `sprites/enemy_charger.svg` | 冲刺怪，厚重冲角轮廓 | 本项目原创 SVG | 项目自有 |
| `sprites/enemy_splitter.svg` | 分裂怪，双核团块轮廓 | 本项目原创 SVG | 项目自有 |
| `sprites/projectile_spark.svg` | 主角投射物与通用子弹素材 | 本项目原创 SVG | 项目自有 |
| `sprites/coin.svg` | 金币掉落素材 | 本项目原创 SVG | 项目自有 |
| `sprites/hit_flash.svg` | 命中特效素材 | 本项目原创 SVG | 项目自有 |
| `maps/arena_foundry_meadow_base.png` | 当前战斗地图底图，原创低对比干燥草土地表与更统一的中央竞技区 | 本项目原创 PNG | 项目自有 |
| `maps/arena_foundry_meadow_props.png` | 当前战斗地图 props 图层，原创大型边缘 hero prop：厚树冠、枝干结构、废料挡板、接地阴影与少量发光点缀，替代轻装饰草簇/黑圈方案 | 本项目原创 PNG | 项目自有 |
| `maps/arena_foundry_meadow_layout.json` | 当前战斗地图布局元数据，记录 zones、大型边缘 hero prop 组与碰撞接入说明 | 本项目原创 JSON | 项目自有 |
| `maps/arena_foundry_meadow.svg` | 原创地图概念源文件，保留为设计源与比例参考，不直接作为当前运行时贴图 | 本项目原创 SVG | 项目自有 |
| `maps/arena_scrapyard.svg` | 旧版原创战斗背景地图底图 | 本项目原创 SVG | 项目自有 |
| `maps/arena_kenney_top_down_shooter.png` | 历史参考用第三方地图烘焙图 | Kenney Topdown Shooter Pack 派生烘焙图 | `CC0` |
| `maps/arena_kenney_open_grass.png` | 历史参考用第三方开放草地图烘焙图，已退出当前运行时地图链路 | Kenney Topdown Shooter Pack 派生烘焙图 | `CC0` |
| `items/magnet_core.svg` | 永久道具图标：磁吸核心 | 本项目原创 SVG | 项目自有 |
| `items/brass_trigger.svg` | 永久道具图标：黄铜扳机 | 本项目原创 SVG | 项目自有 |
| `items/warm_battery.svg` | 永久道具图标：温热电池 | 本项目原创 SVG | 项目自有 |
