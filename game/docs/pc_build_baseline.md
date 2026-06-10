# PC 构建基线

## 第一版 PC 形态

- 引擎：Godot 4
- 主工程：`game/project.godot`
- 主场景：`res://scenes/app/Main.tscn`
- Windows 导出预设：`game/export_presets.cfg`
- 默认窗口：1280x720
- 拉伸策略：`canvas_items` + `keep`
- 输入：WASD/方向键移动，主键盘和小键盘 `+/-` 按 1x、2x、3x 循环调速，ESC 暂停
- HUD：显示关卡、时间、倍率、击败数和金币

## Demo 完成度底线

第一阶段允许使用占位图形和基础反馈，但必须满足：

- 以 PC 桌面窗口运行。
- 可选择 3 个独立存档槽。
- 可选择角色或沿用角色。
- 可搭配永久道具。
- 可进入关卡战斗并完成通关结算。
- 失败不清除长期资产。
- 可从开发测试入口直达指定关卡。
- 具备可导出构建所需的 Godot 工程结构。
- 具备 Windows Desktop 导出预设，安装 Godot 4 后可导出 `build/windows/DaLuangDouDemo.exe`。
- 具备 Windows 打包脚本和安装器定义，安装 Inno Setup 后可生成 `build/installer/DaLuangDouDemoSetup.exe`。
- 安装程序必须创建开始菜单快捷方式，并可选择创建桌面快捷方式。

## Windows 正式打包链路

预检命令：

```powershell
powershell -ExecutionPolicy Bypass -File tools\windows\package_windows.ps1 -CheckOnly -GodotExe "C:\Path\Godot_v4.x.exe" -IsccExe "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
```

预检只检查工具路径、Godot 工程、Windows 导出预设和安装器脚本，不导出 exe，不生成安装程序，也不会创建快捷方式。

正式打包命令：

```powershell
powershell -ExecutionPolicy Bypass -File tools\windows\package_windows.ps1 -GodotExe "C:\Path\Godot_v4.x.exe" -IsccExe "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
```

正式打包链路分两段：

1. Godot 4 使用 `Windows Desktop Demo` 预设导出游戏 exe。
2. Inno Setup 使用 `tools/windows/installer/DaLuangDouDemo.iss` 生成安装程序，并配置安装目录、开始菜单快捷方式、桌面快捷方式和安装后启动入口。

| 项目 | 预检 `-CheckOnly` | 正式打包 |
| --- | --- | --- |
| 产物 | 无构建产物 | `build/windows/DaLuangDouDemo.exe` 与 `build/installer/DaLuangDouDemoSetup.exe` |
| Godot 导出 | 不执行 | 执行 |
| Inno Setup 安装器编译 | 不执行 | 执行 |
| 安装到 PC | 不执行 | 不执行，需要手动运行安装程序 |
| 快捷方式 | 不创建 | 安装程序运行安装后创建 |

## 当前环境说明

当前机器未检测到 Godot 命令行和 Inno Setup，因此本轮只能完成工程文件、脚本级预检与静态/模拟验证。安装 Godot 4 和 Inno Setup 后，可运行 `tools/windows/package_windows.ps1` 生成真实安装程序。
