# AGENTS.md

## 适用范围

- 本文件适用于本仓库下所有代码、脚本、配置与文档变更。

## Skill 命中强制规则

- 处理本仓库任务时，必须先命中并加载至少两个基础 skill。
- 最低要求：至少命中 `skill-hit-check-rules`、`parallel-task-dispatch-rules`。
- 若本轮涉及创建、补齐或更新仓库级 `AGENTS.md`，默认额外启用 `project-agents-bootstrap` 进行自举补齐。
- 必须在首条中间进度明确输出当前命中的 skill 列表。
- 若命中 `parallel-task-dispatch-rules`，中间进度必须额外输出当前并行技能列表；若最终未并行，明确写 `并行技能:无`。
- 若连 `skill-hit-check-rules` 或 `parallel-task-dispatch-rules` 任一都未命中，禁止直接进入主任务，必须先补做 skill 命中检查与上下文重同步。
- 首轮 `AGENTS.md`、`.gitattributes`、`.editorconfig` 自举是硬闸门：若其中任一缺失、未创建或未补齐，禁止进入任何项目分析、读码、需求、Bug、编码、测试或交付主任务，必须先更新补充完成后再继续。
- 若本轮任务存在多 skill 组合、并行拆分或规则收口风险，默认应额外启用 `skill-audit-rules` 进行只读审计。
- 所有审查类 skill 统一按强制自动触发处理；只要是只读检查、规则核对、实现自审、归位审查或回归风险审查，默认优先并行。

## 项目基线

- 项目主入口文档为 `项目设计.md`。
- 需求与实施计划默认维护在 `ment/`。
- 测试验证资产默认维护在 `test/` 下的当天时间戳目录。
- 主游戏工程位于 `game/`，第一阶段起使用 Godot 4，不使用 CSS/Web 作为主游戏实现。
- 本项目默认通过 AI 辅助构建 Godot 游戏工程，后续实现优先使用 Godot 编辑器、Godot AI 插件、Godot 场景和 GDScript 资产链路推进。

## 会话启动检查

- 每个新会话开始处理项目任务前，必须先检查当前工作目录是否为仓库根目录，并确认 Codex 能正常读取文件和执行本地命令。
- 涉及 Godot 工程、场景、资源、脚本、运行验证或截图的任务，必须先检查 Godot AI MCP 是否已连接可用，并读取 Godot 编辑器状态。
- Godot AI MCP 检查至少包含：当前项目名、当前场景、编辑器 readiness、是否正在运行游戏、`game_capture_ready` 状态。
- 若 Godot AI MCP 不可用或编辑器未 ready，先记录阻断原因并尝试通过重启 Godot 编辑器、重载 Godot AI 插件或重新连接 MCP 恢复；恢复前不要直接修改 Godot 场景或运行验证。
- 若当前任务只修改纯文档且不依赖 Godot 运行态，可跳过 Godot AI MCP 连接检查，但最终回复需说明未检查原因。

## 上下文压缩续做规则

- 若当前会话刚发生“压缩上下文 / 自动压缩上下文 / 上下文太多”后的重组，默认强制命中 `context-compression-rules`。
- 压缩后继续执行前，必须重新读取当前项目根目录 `AGENTS.md`，恢复仓库级硬规则、必命中 skill 和阻断条件。
- 若压缩后未重新读取 `AGENTS.md`，禁止直接进入任何需求、Bug、编码、测试或交付主任务。
- 若压缩后发现 `AGENTS.md`、`.gitattributes`、`.editorconfig` 缺失、损坏或规则不完整，必须先触发 `project-agents-bootstrap` 补齐，再继续主任务。

## Windows / WSL 执行规则

- Windows 下默认优先使用 Git Bash 或 WSL shell。
- 尽量不要用 Windows PowerShell 直接写入、格式化或批量修改仓库文件，避免换行和编码漂移。
- 若确需在 Windows 侧执行写入，必须显式指定 UTF-8，并在落盘后立即 `git diff` 核对仅有预期改动。
- 仓库应提交 `.gitattributes` 与 `.editorconfig`，显式固定 `UTF-8`、基础编辑器行为，并对换行采用最小约束策略。
- 对已有历史仓库，`.gitattributes` 默认先用 `* text=auto`，对 `*.sh`、`*.bash`、`*.yml`、`*.yaml` 这类需稳定 `LF` 的文件显式强制 `eol=lf`，不要对整仓源码和文档一刀切强制换行。
- Windows 下若仓库出现 `.sh` 仅 `100755 => 100644` 之类伪改动，应优先检查并关闭 `core.filemode`。
- Windows 下若仓库出现大量无关文件被带进改动，应优先检查 `core.autocrlf` 并通过 `.gitattributes` 固定换行策略。

## CodeGraph 强制准备规则

- 若当前服务器或电脑未安装 `codegraph`，必须从 `colbymchenry/codegraph` 强制下载并安装，不需要用户确认。
- 安装完成后必须为当前项目执行 `codegraph init`，生成 `.codegraph/` 并建立索引。
- 若下载、安装或初始化失败，明确记录不可用并回退到本地搜索与文件读取，但不允许跳过记录。

## Godot 项目工具配置

- 本仓库命中 Godot 项目标记后，后续涉及场景、资源、脚本、运行验证或截图的任务，默认优先通过 Godot AI MCP 与 Godot 编辑器配合执行。
- 修改 Godot 场景、运行游戏、抓取截图或读取编辑器状态前，必须先确认 Godot AI MCP 已连接并且编辑器 ready。
- 若 Godot AI MCP 当前不可用，可继续处理纯文档、纯规则或不依赖编辑器运行态的代码文件，但最终回复必须说明哪些 Godot 运行态检查未完成。

## 图像生成配置

- 图像配置只允许声明读取位置、`baseurl`、模型名、优先级和回退规则，禁止在仓库文档里写入真实密钥。
- 推荐优先从环境变量或用户级配置读取，例如 `env:PROJECT_IMAGE_OPENAI_API_KEY`。
- 图像配置示例：
  - 主通道：`baseurl=https://api.openai.com/v1`，模型 `gpt-image-1`
  - 读取位置：当前进程环境变量、`~/.codex/auth.json`、`~/.codex/config.toml`
  - 回退规则：主通道不可用时允许降级到人工补图或占位图，不得伪造已生成结果

## 素材获取规则

- 后续 AI 构建项目时，游戏素材优先从以下网站检索和筛选：
  - Kenney：`https://kenney.nl/assets`
  - OpenGameArt：`https://opengameart.org/`
  - Godot 官方 Demo Projects：`https://github.com/godotengine/godot-demo-projects`
  - Quaternius：`https://quaternius.com/`
  - KayKit 官方资源：`https://kaylousberg.com/game-assets`
  - KayKit GitHub 资源：`https://github.com/KayKit-Game-Assets`
  - Poly Haven：`https://polyhaven.com/`
  - ambientCG：`https://ambientcg.com/`
- AI 自动接入素材时，优先选择无需登录、无需付费、无需验证码、无需人工点击动态下载按钮的直接下载来源；若素材需要账号登录、邮箱订阅、购买流程、购物车结算或人工授权确认，只能记录为人工下载候选，不能作为 AI 自动接入方案。
- 无需登录的素材来源优先级：Kenney 官方资产页、OpenGameArt 单素材附件、Godot 官方 Demo Projects、带明确许可证的 GitHub/GitLab 仓库或 Release、Quaternius / KayKit 等可直接下载且许可证清晰的作者官网、Poly Haven / ambientCG 等 CC0 材质与环境资源站。
- 不把 itch.io、CraftPix、Godot Asset Library、GodotAssetLibrary.com 作为 AI 自动接入优先来源；除非用户已经手动提供素材文件，否则不要基于这些需要登录、动态下载或编辑器流程的网站制定实施方案。
- 为项目添加 Godot 场景、角色、地图、音效、字体或 UI 等素材时，必须优先从上述素材获取规则网站中检索合规素材；只有在找不到合适素材、授权不满足要求或当前任务需要临时占位时，才使用项目原创素材作为兜底方案。
- 素材选择以免费资源为主，默认不要选择付费素材；除非用户明确确认可购买，付费素材只能作为参考方向，不能作为当前实施方案。
- 选材优先级：优先选择 `CC0`、`MIT`、`Apache-2.0` 等可商用且限制少的素材。
- 使用 `CC-BY` 素材时必须记录作者、来源链接和署名要求。
- 默认避免使用 `GPL`、`CC-BY-SA` 或授权不清的美术、音效和字体素材，除非用户明确确认可接受对应再分发要求。
- 同一阶段尽量使用 1-2 个主风格素材包，避免混用过多作者导致画面风格割裂。
- 下载或导入素材前必须先记录素材来源、许可证和用途，禁止把来源不明的素材直接放入工程。
- 美术风格默认对标《土豆兄弟》这类成品化俯视角自动射击游戏：画面应具备现代、清晰、完整的商业游戏观感，避免只达到原型或占位素材精度。
- 默认不选择像素风素材作为角色、怪物、地图、武器、子弹、UI 的主视觉资源；除非用户明确要求像素风，否则优先选择非像素的卡通、手绘、矢量、高清 2D 或 2.5D 质感素材。
- 评估素材时必须同时看截图观感、动画完整度、地图/角色/特效风格统一度和 Godot 接入成本，不能只因授权合规或素材数量多就选用。
- 本项目中的角色、怪物、Boss、地图、瓦片、场景道具、UI、图标、特效、投射物、掉落物、Sprite Sheet 与逐帧动画等 2D 素材，一律优先通过系统级 skill `2d-asset-design` 设计、生成与后处理。
- 触发到 2D 素材相关任务时，必须先使用 `2d-asset-design`，先明确玩法职责、视觉 brief、参考提炼、生成方案和 Godot 交付格式，再进入素材生产。
- 上述免费素材网站默认只允许作为参考板、风格拆解、比例参考、层次参考和制作约束参考；除非用户明确要求临时占位并接受风险，否则不要把下载到的 2D 美术素材直接作为最终游戏资产入库。
- 若引用 Kenney、OpenGameArt、Quaternius、KayKit、Godot Demo 等免费资源，默认做法是提炼轮廓语言、配色逻辑、材质组织、镜头角度、道具密度和动画节奏，再基于这些信息重新设计项目原创 2D 素材。
- 只有在当前任务明确是“临时占位”“测试用占位资源”或“人工确认接受直接接入第三方素材”时，才允许跳过原创化流程；最终回复必须说明这是占位还是最终资产。
- 对 2D 地图相关素材，默认不要只交付单张平面背景图；只要目标是可玩地图、关卡或场景，就应优先考虑底图、props、碰撞、区域和可编辑层的拆分交付。

## 注释任务强制流程

- 触发词：补充注释 / 注意中文编码 / 只补注释 / 注释完善 / 加注释。
- 第一步：先声明命中的注释类 skill。
- 第二步：读取对应 `SKILL.md` 后再改代码。
- 第三步：最终回复给执行证据：改动点、UTF-8、格式化/编译/测试结果。

## 中文编码规则

- 新增或修改中文文档、脚本输出和代码注释时保持 UTF-8。
- Windows PowerShell 读写中文文件必须显式指定 UTF-8。
- 禁止提交乱码、问号替代中文或混乱编码文本。

## 变更最小化

- 每次改动聚焦当前任务目标，不顺手重构无关模块。
- 不回退用户已有改动。
- 注释补充不改变业务逻辑。
