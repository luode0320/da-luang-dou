我帮你把 Codex 侧 MCP 配置加好了：

```toml
[mcp_servers."godot-ai"]
url = "http://127.0.0.1:8000/mcp"
enabled = true
```

```
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

位置：`C:\Users\Administrator\.codex\config.toml:148`

接下来你们在 Godot 4 项目里做三步就能用：

1. 从 Godot AssetLib 安装并启用 **Godot AI** 插件  
   <https://godotengine.org/asset-library/asset/5050>

2. 打开 Godot 项目，让 Godot AI 插件启动本地 MCP 服务  
   默认地址就是 `http://127.0.0.1:8000/mcp`

3. 重启 Codex 或新开一个 Codex 会话，让它加载新的 MCP 配置

项目主页： <https://github.com/hi-godot/godot-ai>

我本地验证了配置已写入，没有发现重复的 `godot-ai` MCP 配置。注意：我只改了 Codex 配置，还没动具体 Godot 项目，因为当前目录不是游戏项目，也没在 PATH 里找到 `godot` 命令。

命中检查:通过  
Git规则:不适用

2026-06-20 23:45:37 docs: [仓库规则补齐] 补齐 AGENTS 与基础自举配置
2026-06-20 23:49:30 docs: [提交收口] 清理 AGENTS 残留改动
2026-06-21 02:41:05 docs: [仓库规则同步] 同步 AGENTS 规则
