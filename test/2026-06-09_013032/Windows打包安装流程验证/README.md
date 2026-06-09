# Windows 打包安装流程验证

## 测试目的

验证第一阶段 Demo 已具备 Windows 正式交付链路：Godot 4 导出游戏 exe，Inno Setup 生成安装程序，安装后通过桌面或开始菜单快捷方式启动。

## 测试对象

- `tools/windows/package_windows.ps1`
- `tools/windows/installer/DaLuangDouDemo.iss`
- `tools/windows/README.md`
- `tools/windows/runtime/README.md`
- `game/export_presets.cfg`
- `game/docs/pc_build_baseline.md`

## 真实测试资产

- `test/2026-06-09_013032/tools/windows/validate_windows_packaging.py`

## 执行方式

```powershell
$env:PYTHONUTF8 = "1"
python test\2026-06-09_013032\tools\windows\validate_windows_packaging.py
```

## 覆盖范围

- 检查 Windows 打包脚本存在并包含 Godot 4、Inno Setup、`-CheckOnly`、导出和安装器编译逻辑。
- 检查 `tools/windows/package_config.json` 存在，并包含 Godot、Inno Setup 和导出预设配置。
- 检查 `tools/windows/runtime/` 项目内工具链目录和说明已就位。
- 检查 Inno Setup 脚本包含默认安装目录、开始菜单快捷方式、桌面快捷方式和安装后启动入口。
- 检查 Godot 导出预设仍包含 `Windows Desktop Demo`。
- 使用临时假工具文件执行 `package_windows.ps1 -CheckOnly`，验证脚本在不真实导出时也能完成配置预检。
- 使用临时 `package_config.json` 执行 `package_windows.ps1 -CheckOnly -ConfigPath`，验证脚本能从项目配置读取工具路径。

## 环境说明

当前机器未检测到 Godot 4 和 Inno Setup，因此不能生成真实 `DaLuangDouDemoSetup.exe`。本轮结论覆盖脚本级、配置级和安装器定义级验证；真实安装包生成需要先安装 Godot 4 与 Inno Setup。

## 验证结论

通过。

已执行：

```powershell
$env:PYTHONUTF8 = "1"
python test\2026-06-09_013032\tools\windows\validate_windows_packaging.py
```

结果：

- Windows 打包脚本、Inno Setup 安装器定义、Godot Windows 导出预设和相关文档均存在。
- `package_windows.ps1 -CheckOnly -ConfigPath` 使用临时配置和临时假工具文件执行通过，证明项目内配置预检链路可运行。
- `tools/windows/runtime/` 已放入 Godot 4.6.3 stable 与 Inno Setup 6.7.3 命令行工具，并通过 `package_windows.ps1 -CheckOnly` 识别。
- Godot Windows export templates 已补齐到 `tools/windows/runtime/godot/export_templates/4.6.3.stable/`，并可同步到 Godot 用户模板目录。
- 已执行 `tools/windows/package_windows.cmd -CheckThenPackage`，生成 `build/windows/DaLuangDouDemo.exe` 和 `build/installer/DaLuangDouDemoSetup.exe`。
- 已用静默安装方式把 `DaLuangDouDemoSetup.exe` 安装到 `build/install-test/`，安装目录中已生成 `DaLuangDouDemo.exe` 和卸载程序。
- 安装器定义包含默认安装目录、开始菜单快捷方式、桌面快捷方式和安装后启动入口。
- 当前机器缺少真实 Godot 4 与 Inno Setup，因此未生成真实安装程序；安装工具链后可执行正式打包命令生成 `build/installer/DaLuangDouDemoSetup.exe`。
