# AGENTS.md

## 适用范围

- 本文件适用于本仓库下所有代码与文档变更。

## 项目强制原则

| 优先级 | 原则 | 约束 |
| --- | --- | --- |
| P0 | 配置驱动 | 模块、关卡、怪物、地图机制、角色、固定武器技能、道具、掉落和模块解锁关系等长期扩展内容应优先由配置驱动；后台导出的配置结果是游戏侧默认真源。 |
| P0 | 后台完全可配置 | 新增独立 `admin/` 目录承载 Go 后端 + Vue 前端；模块、关卡、节点、怪物、技能、地图、素材绑定、发布版本等长期扩展内容必须通过后台配置完成，能配置的绝不写死。 |
| P0 | 绝对零硬编码 | 所有游戏内容通过 `YAML` 配置文件定义；新增模块、角色、技能、怪物、关卡、地图与掉落规则时，原则上只改配置，不改代码。 |
| P0 | 全配置驱动 | 新增游戏模块、角色、技能、怪物、关卡、地图和掉落规则时，无需修改代码即可完成接入；代码只保留通用加载、校验、运行和渲染能力。 |

## Skill 命中强制规则

- 处理本仓库任务时，必须先命中并加载至少五个基础 skill。
- 最低要求：至少命中 `skill-hit-check-rules`、`parallel-task-dispatch-rules`、`reasoning-summary-structure-rules`、`project-memory-rules`、`project-style-rules`。
- 若本轮涉及创建、补齐或更新仓库级规则文件，默认额外启用 `project-agents-bootstrap` 进行自举补齐；该规则同样适用于其他项目仓库。
- 必须在首条中间进度明确输出当前命中的 skill 列表。
- 若命中 `parallel-task-dispatch-rules`，中间进度必须额外输出当前并行技能列表；若最终未并行，明确写 `并行技能:无`。
- 若连 `skill-hit-check-rules` 或 `parallel-task-dispatch-rules` 任一都未命中，视为上下文丢失严重、当前基础规则没有正确加载；此时禁止直接进入主任务，必须先补做 skill 命中检查与上下文重同步。
- 若本轮任务存在多 skill 组合、并行拆分或规则收口风险，默认应额外启用 `skill-audit-rules` 进行只读审计。
- 自动审查白名单只保留 `implementation-review-rules` 与最终收口前的 `project-change-review-rules`。
- `project-change-review-rules` 同时支持两类触发：用户明确要求审查当前改动，或本轮存在代码改动且准备最终收口。
- `code-review-automation-rules` 仅用于当前分支提交级审查，不纳入默认自动审查链。

## 项目基线

- 项目主入口文档为 [项目设计.md](/F:/da-luang-dou/项目设计.md)。
- 需求主文档与需求配套 SVG 默认维护在 `doc/2-需求/`。
- 实施总览、实施周期、阶段推进总览与阶段实施文档默认维护在 `doc/3-实施/`。
- 验收标准与最终验收文档默认维护在 `doc/7-验收/`。
- Bug 记录、复现、根因、验证与配套图表默认维护在 `doc/4-bugs/`。
- 测试验证资产默认维护在 `doc/5-tests/` 下的当天时间戳目录。
- 结构归位、实现审查、格式清理、语法检查和注释核对结论默认维护在 `doc/6-审查/`。
- 配置规范、后台结构方案、字段规范、运行时读取和编码规范默认维护在 `doc/1-架构/`。
- 主游戏工程位于 `game/`，第一阶段起使用 Godot 4，不使用 CSS/Web 作为主游戏实现。
- 后台配置系统位于 `admin/`，拆分为 Go 后端与 Vue 前端。
- Windows 打包与安装器相关脚本默认放在 `tools/windows/`。
- 本项目默认通过 AI 辅助构建 Godot 游戏工程，后续实现优先使用 Godot 编辑器、Godot AI 插件、Godot 场景和 GDScript 资产链路推进。
- 项目本地补充 skill 位于 `.codex/skills/`；处理 Godot 开发任务时，应优先检查并使用其中的 `godot-gdscript-patterns`、`godot-best-practices`、`godot-dev`、`godot-ui`。

## 目录规则特例

- 历史 `ment/` 目录已视为废弃目录；若后续发现旧引用、旧跳转文档或旧待迁文件，默认迁回 `doc/2-需求/`、`doc/1-架构/`、`doc/3-实施/`、`doc/7-验收/`、`doc/6-审查/` 体系后删除旧入口，不保留兼容层。
- 根级 `review/`、`analysis/` 同样不作为正式长期目录；审查结论统一进入 `doc/6-审查/`。

## 仓库目录职责

- `项目设计.md`：项目级总设计文档，作为方向和阶段边界的顶层参考。
- `doc/README.md`：文档目录索引，说明 `doc/` 分类和当前入口。
- `doc/2-需求/`：需求主文档、需求索引、需求变更记录和需求配套 SVG 图表。
- `doc/1-架构/`：配置目录、全配置驱动、后台系统、字段规范、游戏侧读取和中文编码规范。
- `doc/3-实施/`：实施总览、实施周期、阶段 0-7 拆分文档和阶段推进总览。
- `doc/7-验收/`：验收标准、最终验收和验收放行结论。
- `doc/4-bugs/`：Bug 根目录、问题说明、流程图、时序图和后续定位验证记录。
- `doc/6-审查/`：结构归位、实现审查、格式清理、语法检查和注释核对结论。
- `game/`：Godot 4 主工程目录，承载场景、脚本、资源和运行态逻辑。
- `game/data/`：游戏侧读取的 YAML 发布配置真源。
- `admin/`：Go 后端 + Vue 前端的后台配置系统。
- `tools/windows/`：Windows 打包、安装器和发布辅助脚本。
- `doc/5-tests/`：测试说明、验证脚本、回归记录和临时验证资产。

## 会话启动检查

- 每个新会话开始处理项目任务前，必须先检查当前工作目录是否为仓库根目录，并确认 Codex 能正常读取文件和执行本地命令。
- 涉及 Godot 工程、场景、资源、脚本、运行验证或截图的任务，必须先检查 Godot AI MCP 是否已连接可用，并读取 Godot 编辑器状态。
- Godot AI MCP 检查至少包含：当前项目名、当前场景、编辑器 readiness、是否正在运行游戏、`game_capture_ready` 状态。
- 若 Godot AI MCP 不可用或编辑器未 ready，先记录阻断原因并尝试通过重启 Godot 编辑器、重载 Godot AI 插件或重新连接 MCP 恢复；恢复前不要直接修改 Godot 场景或运行验证。
- 若当前任务只修改纯文档且不依赖 Godot 运行态，可跳过 Godot AI MCP 连接检查，但最终回复需说明未检查原因。

## 上下文压缩续做规则

- 若当前会话刚发生“压缩上下文 / 自动压缩上下文 / 上下文太多”后的重组，默认强制命中 `context-compression-rules`。
- 压缩后继续执行前，必须重新读取当前项目根目录规则文件（`AGENTS.md` / `CLAUDE.md`），恢复仓库级硬规则、必命中 skill 和阻断条件。
- 若压缩后未重新读取规则文件，禁止直接进入任何需求、Bug、编码、测试或交付主任务。
- 若压缩后发现规则文件缺失、损坏或规则不完整，必须先触发 `project-agents-bootstrap` 补齐，再继续主任务。

## Windows / WSL 执行规则

> 详细规则与命令模板见 `windows-wsl-execution-rules` skill。本节为写入规则文件的最小约束摘要。代码在 WSL 文件系统内（`/home/<user>/<project>`），编译/运行/测试/调试都在 WSL 完成。

**先看 agent 在哪运行：**

- **agent 在 WSL（推荐）**：直接 `cd /home/<user>/<project>` 执行 `go build`/`test`/`run`/`dlv`，无需任何包裹。
- **agent 在 Windows（如 Claude Desktop GUI）**：
  - shell 默认用 Git Bash
  - 看代码、改代码、git：经 `\\wsl.localhost\\<distro>\\home\\<user>\\<project>` 访问 WSL 文件
  - 编译、运行、测试、调试：`wsl.exe --cd /home/<user>/<project> <command>`

**为什么执行/调试在 WSL：** 只有 WSL 进程能正常联网，且二进制面向 Linux。

**命令格式：** `wsl.exe --cd /home/<user>/<project> <command>`（默认发行版省略 `-d`；多发行版时用 `wsl.exe -l -v` 查名后加 `-d <发行版名>`）。不再使用 `/mnt/<drive>`。

**编码约束：**

- 仓库提交 `.gitattributes` 与 `.editorconfig`，固定 UTF-8 和换行策略
- `.gitattributes` 默认 `* text=auto`，`*.sh`/`*.yaml` 显式 `eol=lf`
- 不对 `*.go`、`*.vue`、`*.md` 等全量强制 `eol=lf`
- Windows 下出现大量无关改动优先检查 `core.autocrlf`

## CodeGraph 强制准备规则

- 若当前服务器 / 电脑未安装 `codegraph`，必须从 `colbymchenry/codegraph` 强制下载并安装，不需要用户确认。
- 若在 Windows PowerShell 5.1 下执行安装，必须默认启用 `Invoke-WebRequest` / `Invoke-RestMethod` 的 `UseBasicParsing`，不得把人工点击确认当作标准流程。
- 安装完成后必须为当前项目执行 `codegraph init`，生成 `.codegraph/` 并建立索引。
- 若下载、安装或初始化失败，明确记录不可用并回退到本地搜索与文件读取。
- 架构层分析可配套 codebase-memory-mcp（`DeusData/codebase-memory-mcp`，按官方说明安装，非强制）作为 CodeGraph 的补充。

## Godot 项目工具配置

- 本仓库命中 Godot 项目标记后，后续涉及场景、资源、脚本、运行验证或截图的任务，默认优先通过 Godot AI MCP 与 Godot 编辑器配合执行。
- 修改 Godot 场景、运行游戏、抓取截图或读取编辑器状态前，必须先确认 Godot AI MCP 已连接并且编辑器 ready。
- 若 Godot AI MCP 当前不可用，可继续处理纯文档、纯规则或不依赖编辑器运行态的代码文件，但最终回复必须说明哪些 Godot 运行态检查未完成。

## 图像生成配置

- 图像配置只允许声明读取位置、`baseurl`、模型名、优先级和回退规则，禁止在仓库文档里写入真实密钥。
- 推荐优先从环境变量或用户级配置读取，例如 `env:PROJECT_IMAGE_OPENAI_API_KEY`。
- 图像配置应同时声明主通道、读取位置、优先级和回退配置，不得只写模型名。
- 图像配置示例：
  - 主通道：`baseurl=https://api.openai.com/v1`，模型 `gpt-image-1`
  - 读取位置：当前进程环境变量、`~/.codex/auth.json`、`~/.codex/config.toml`
  - 优先级：当前进程环境变量 > `~/.codex/auth.json` > `~/.codex/config.toml`
  - 回退规则：主通道不可用时先切换到回退配置；若回退配置也不可用，则允许降级到人工补图或占位图，不得伪造已生成结果
- 回退配置仅保留字段位，不在仓库文档中写入真实密钥：
  - `api: ''`
  - `baseurl: 'https://newapiai.com/v1'`

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

- 新增或修改注释默认使用中文。
- 文件编码保持 UTF-8，禁止乱码。

## 变更最小化

- 注释补充不改变业务逻辑。

## Skill 强制自动触发规则（最高优先级）

- 所有 skill 的触发不依赖用户主动通知，AI 必须基于任务内容、工作目录、用户意图主动检测并触发。
- 每轮处理用户消息时，必须主动扫描所有可用 skill 的触发条件，符合条件的 skill 必须被调用。
- `skill-hit-check-rules` 每轮必须作为第一个 tool call 被调用，无例外。
- 禁止以下理由跳过应触发的 skill：
  - “用户没有明确说需要这个 skill”
  - “任务看起来简单，不需要 skill”
  - “我已经知道怎么做了”
  - “这不是核心 skill”
- 违反本规则视为流程违规，必须立即停止当前执行，回到命中检查重走。

## 严禁脑补工具调用与结果（最高优先级，强制）

- 任何对文件、命令、搜索、网络的读取与执行，必须通过真实工具调用（独立 tool call）完成；严禁在回复正文里编写 `<invoke>` / `<result>` / 伪 function_calls 文本假装调用工具，也禁止凭记忆“想象”文件内容当作已读取结果。
- 引用任何文件内容、行号、函数名、配置值前，必须来自本轮真实工具返回；未真实读取不得断言具体代码或数据。
- 若发现输出出现大段重复行、错乱或重复行号、源码文件莫名以 Markdown 代码块结束符收尾、import 与实际用法矛盾等异常，立即判定为生成异常：停止后重新发起真实工具调用，并用 `md5sum` / `wc -c` 等独立命令交叉校验再继续。
- 关键文件读取建议附带指纹校验（`md5sum` + `wc -c`），确保所读即磁盘真实内容。
- 违反本条视为最高级别流程违规。

## 严禁自动提交 Git（最高优先级，强制）

- 绝对禁止在用户未于“当前这轮消息”显式提出提交的前提下，执行任何写入仓库历史的 Git 动作（`git commit`、`git commit --amend`、`git push`、`git rebase`、`git merge --no-ff` 等）。
- “显式提出提交”指用户在当前这轮消息里明确表达提交/推送意图，例如：`提交git`、`提交代码`、`commit一下`、`帮我提交`、`推送`、`push`、`同步到远端`。
- 仅完成代码改动、任务收尾、或上一轮提交过，都不构成本轮提交授权；缺少当轮显式授权时，必须停在“已改动未提交”状态并提示用户。
- 任何情况下都不得以“我以为你想提交”“按惯例提交”“顺手提交”为由自动提交。
- 只读盘点命令（`git status`、`git diff`、`git log`）不受限制；写入历史的动作严格受限。
- 本条与全局技能 `git-collaboration-rules` 的「1.-2」一致，为项目级重申，确保重启会话 / 无全局上下文时本规则仍在项目内生效。
- 违反本条视为最高级别流程违规。

## 代码库探索规则

1. 日常理解代码、定位实现、追踪调用链、分析改动影响时，优先使用 CodeGraph。
2. 修改代码前，先用 CodeGraph 获取相关源码和影响范围。
3. 不要在 CodeGraph 已经返回足够上下文时重复全仓库 grep。
4. 项目架构分析、跨模块依赖、函数调用频率、ADR 记录等架构层任务，用 codebase-memory-mcp 作补充。
5. CodeGraph 作默认入口，codebase-memory-mcp 作高级图分析工具；两者结果与当前代码不一致时，以当前代码为准并重新同步索引。

## 插件检测安装规则

- 涉及 AI 编码插件（如 Ponytail）的安装、启用、配置时，联动 `plugin-installation-rules`。
- Ponytail 为默认必装插件：会话 / 项目准备时默认安装并启用（详见 `plugin-installation-rules`）。
- 安装命令与配置一律以插件官方仓库为准，不沿用第三方博客 / 公众号转述的旧命名、旧参数。
- 通用支持 Claude Code / Codex 等环境，按当前 AI 选对应安装方式；安装或启用失败时回退到常规流程。

## 图像生成强制规则

- 只要当前用户请求属于生图、改图、参考图出新图、sprite、动作帧、概念图、UI 位图、贴图、透明底抠图、2D 游戏素材预览或其他位图资产任务，必须自动命中 `imagegen`，不得等用户额外明确说“使用 imagegen”。
- 命中 2D 游戏素材相关任务时，若涉及设计图、预览图、原始素材图、动作关键帧或 sprite 方向图，除命中领域 skill 外，还必须联动命中 `imagegen`。
- 对于生图任务，允许的“原始图产生方式”只有真实图像生成/编辑链路：内置 `image_gen`，或经验证可用的 `imagegen` CLI/API 图像通道。
- 严禁把 Pillow、SVG、HTML/CSS/canvas、脚本拼接、程序绘制、几何组合、占位图、自动排版图、后处理脚本输出伪装成“已完成生图结果”或“最终素材”。
- CLI fallback 仅表示“改走 imagegen 的脚本入口去调用真实图像生成/编辑 API”，不表示允许退化成脚本合成图片；凡是不经过真实图像模型生成的结果，一律不得作为生图成品交付。
- 如果内置 `image_gen` 不可用，必须先验证 `imagegen` CLI/API 链路；若也不可用，则明确阻断并只允许交付 prompt、brief、参考候选、动作规划等中间信息，不得交付脚本生成图冒充成品。
- 后处理脚本只允许在“真实生成出的原始图”基础上做去背、切帧、对齐、拼表、预览整理；不得替代 imagegen 负责原始创作出图。
