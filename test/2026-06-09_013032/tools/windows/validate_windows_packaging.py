from __future__ import annotations

import re
import json
import subprocess
import sys
import tempfile
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[4]
PACKAGE_SCRIPT = REPO_ROOT / "tools" / "windows" / "package_windows.ps1"
PACKAGE_CMD = REPO_ROOT / "tools" / "windows" / "package_windows.cmd"
PACKAGE_CONFIG = REPO_ROOT / "tools" / "windows" / "package_config.json"
INSTALLER_SCRIPT = REPO_ROOT / "tools" / "windows" / "installer" / "DaLuangDouDemo.iss"
EXPORT_PRESETS = REPO_ROOT / "game" / "export_presets.cfg"
TOOLS_README = REPO_ROOT / "tools" / "windows" / "README.md"
PC_BASELINE = REPO_ROOT / "game" / "docs" / "pc_build_baseline.md"
BUNDLED_GODOT = REPO_ROOT / "tools" / "windows" / "runtime" / "godot" / "Godot_v4.x.exe"
BUNDLED_ISCC = REPO_ROOT / "tools" / "windows" / "runtime" / "inno" / "ISCC.exe"


# read_text
# [参数] path：需要读取的 UTF-8 文本文件路径。
# [返回] 返回文件文本内容。
# 最近修改时间：2026-06-09 01:30:32，新增 Windows 打包验证脚本的统一 UTF-8 读取入口。
def read_text(path: Path) -> str:
    # 1. 使用显式 UTF-8 读取，避免 Windows 默认编码造成中文文档误判。
    return path.read_text(encoding="utf-8")


# assert_contains
# [参数] name：检查项名称；content：待检查文本；patterns：必须命中的正则表达式列表。
# [返回] 无；缺失任一模式时抛出 AssertionError。
# 最近修改时间：2026-06-09 01:30:32，新增文本关键能力断言。
def assert_contains(name: str, content: str, patterns: list[str]) -> None:
    # 1. 逐项匹配关键模式，让失败信息直接指向缺失能力。
    for pattern in patterns:
        if not re.search(pattern, content, flags=re.IGNORECASE | re.MULTILINE):
            raise AssertionError(f"{name} 缺少模式：{pattern}")


# validate_static_files
# [参数] 无。
# [返回] 无；静态文件缺失或关键内容缺失时抛出 AssertionError。
# 最近修改时间：2026-06-09 01:30:32，新增 Windows 打包脚本、安装器和文档静态验证。
def validate_static_files() -> None:
    # 1. 检查 Windows 打包链路所需文件都已落盘。
    required_files = [
        PACKAGE_SCRIPT,
        PACKAGE_CMD,
        PACKAGE_CONFIG,
        INSTALLER_SCRIPT,
        EXPORT_PRESETS,
        TOOLS_README,
        PC_BASELINE,
    ]
    for path in required_files:
        print(f"[check] exists {path.relative_to(REPO_ROOT)}")
        if not path.exists():
            raise AssertionError(f"文件不存在：{path}")

    # 2. 检查 PowerShell 脚本具备工具检测、预检、Godot 导出和 Inno 编译能力。
    package_content = read_text(PACKAGE_SCRIPT)
    assert_contains(
        "package_windows.ps1",
        package_content,
        [
            r"param\(",
            r"\[switch\]\$CheckOnly",
            r"\[switch\]\$CheckThenPackage",
            r"\$ConfigPath",
            r"\$BundledGodotExe",
            r"\$BundledIsccExe",
            r"Read-PackagingConfig",
            r"Select-ConfiguredValue",
            r"BundledPath",
            r"Resolve-Executable",
            r"Godot 4",
            r"Inno Setup",
            r"--export-release",
            r"Invoke-InnoSetup",
            r"CheckThenPackage",
            r"DaLuangDouDemoSetup\.exe",
        ],
    )

    # 2.0 检查 Git Bash/CMD 包装入口存在，避免反斜杠路径被外层 shell 吃掉。
    cmd_content = read_text(PACKAGE_CMD)
    assert_contains(
        "package_windows.cmd",
        cmd_content,
        [
            r"powershell",
            r"package_windows\.ps1",
            r"%\*",
        ],
    )

    # 2.1 检查项目内打包配置包含 Godot、Inno Setup 和导出预设字段。
    config_content = read_text(PACKAGE_CONFIG)
    assert_contains(
        "package_config.json",
        config_content,
        [
            r'"godotExe"',
            r'"isccExe"',
            r"tools\\\\windows\\\\runtime\\\\godot\\\\Godot_v4\.x\.exe",
            r"tools\\\\windows\\\\runtime\\\\inno\\\\ISCC\.exe",
            r'"presetName"',
            r"Windows Desktop Demo",
        ],
    )

    # 2.2 检查项目内 runtime 说明、占位目录和真实二进制已就位。
    runtime_readme = REPO_ROOT / "tools" / "windows" / "runtime" / "README.md"
    runtime_godot_keep = REPO_ROOT / "tools" / "windows" / "runtime" / "godot" / ".gitkeep"
    runtime_inno_keep = REPO_ROOT / "tools" / "windows" / "runtime" / "inno" / ".gitkeep"
    for path in (runtime_readme, runtime_godot_keep, runtime_inno_keep, BUNDLED_GODOT, BUNDLED_ISCC):
        print(f"[check] exists {path.relative_to(REPO_ROOT)}")
        if not path.exists():
            raise AssertionError(f"文件不存在：{path}")
    assert_contains(
        "runtime README",
        read_text(runtime_readme),
        [
            r"Godot_v4\.x\.exe",
            r"ISCC\.exe",
            r"项目内冗余",
        ],
    )


# validate_bundled_tools
# [参数] 无。
# [返回] 无；项目内工具不可执行或版本输出异常时抛出 AssertionError。
# 最近修改时间：2026-06-09 01:30:32，新增项目内 Godot 与 Inno Setup 真实二进制可用性验证。
def validate_bundled_tools() -> None:
    # 1. 运行项目内 Godot，确认下载后的 exe 可执行且版本符合当前 runtime 文档。
    godot_result = subprocess.run(
        [str(BUNDLED_GODOT), "--version"],
        cwd=REPO_ROOT,
        text=True,
        encoding="utf-8",
        errors="replace",
        capture_output=True,
        check=False,
    )
    print(f"[check] Godot version: {godot_result.stdout.strip()}")
    if godot_result.returncode != 0 or "4.6.3" not in godot_result.stdout:
        raise AssertionError("项目内 Godot 版本检查失败")

    # 2. 运行项目内 ISCC，确认 Inno Setup 编译器可执行并能输出帮助信息。
    iscc_result = subprocess.run(
        [str(BUNDLED_ISCC), "/?"],
        cwd=REPO_ROOT,
        text=True,
        encoding="utf-8",
        errors="replace",
        capture_output=True,
        check=False,
    )
    combined_output = iscc_result.stdout + iscc_result.stderr
    print("[check] ISCC help detected")
    if "Inno Setup 6 Command-Line Compiler" not in combined_output:
        raise AssertionError("项目内 ISCC 可执行性检查失败")

    # 3. 检查安装器定义包含安装目录、桌面快捷方式、开始菜单快捷方式和安装后启动。
    installer_content = read_text(INSTALLER_SCRIPT)
    assert_contains(
        "DaLuangDouDemo.iss",
        installer_content,
        [
            r"DefaultDirName=\{autopf\}\\Da Luang Dou Demo",
            r"\[Icons\]",
            r"\{group\}\\\{#AppName\}",
            r"\{autodesktop\}\\\{#AppName\}",
            r"\[Run\]",
            r"postinstall",
        ],
    )

    # 4. 检查 Godot 导出预设仍指向 Windows Desktop Demo。
    export_content = read_text(EXPORT_PRESETS)
    assert_contains(
        "export_presets.cfg",
        export_content,
        [
            r'name="Windows Desktop Demo"',
            r'platform="Windows Desktop"',
            r'export_path="\.\./build/windows/DaLuangDouDemo\.exe"',
        ],
    )

    # 5. 检查文档已经说明正式安装包和快捷方式启动流程。
    for path in (TOOLS_README, PC_BASELINE):
        content = read_text(path)
        assert_contains(
            str(path.relative_to(REPO_ROOT)),
            content,
            [
                r"package_windows\.ps1",
                r"DaLuangDouDemoSetup\.exe",
                r"快捷方式",
            ],
        )


# validate_check_only_mode
# [参数] 无。
# [返回] 无；CheckOnly 预检失败或输出缺少成功提示时抛出 AssertionError。
# 最近修改时间：2026-06-09 01:30:32，新增 PowerShell CheckOnly 模拟验证，避免依赖真实 Godot/Inno 环境。
def validate_check_only_mode() -> None:
    # 1. 创建临时假工具文件；CheckOnly 只验证路径和配置，不会执行这些假工具。
    with tempfile.TemporaryDirectory(prefix="da_luang_dou_packaging_") as temp_dir:
        temp_path = Path(temp_dir)
        fake_godot = temp_path / "Godot_v4_fake.exe"
        fake_iscc = temp_path / "ISCC_fake.exe"
        fake_godot.write_text("", encoding="utf-8")
        fake_iscc.write_text("", encoding="utf-8")

        config_file = temp_path / "package_config.json"
        config_file.write_text(
            json.dumps(
                {
                    "godotExe": str(fake_godot),
                    "isccExe": str(fake_iscc),
                    "presetName": "Windows Desktop Demo",
                },
                ensure_ascii=False,
                indent=2,
            ),
            encoding="utf-8",
        )

        command = [
            "powershell",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            str(PACKAGE_SCRIPT),
            "-CheckOnly",
            "-ConfigPath",
            str(config_file),
        ]
        print("[run] " + " ".join(command))
        completed = subprocess.run(
            command,
            cwd=REPO_ROOT,
            text=True,
            encoding="utf-8",
            errors="replace",
            capture_output=True,
            check=False,
        )
        print(completed.stdout.strip())
        if completed.returncode != 0:
            print(completed.stderr.strip(), file=sys.stderr)
            raise AssertionError(f"CheckOnly 预检失败，退出码：{completed.returncode}")
        if "CheckOnly 完成" not in completed.stdout:
            raise AssertionError("CheckOnly 输出缺少完成提示")


# main
# [参数] 无。
# [返回] 返回进程退出码；0 表示验证通过，1 表示验证失败。
# 最近修改时间：2026-06-09 01:30:32，新增 Windows 打包安装流程验证入口。
def main() -> int:
    try:
        # 1. 先做静态能力检查，再做脚本 CheckOnly 运行验证。
        print("[start] Windows 打包安装流程验证")
        validate_static_files()
        validate_bundled_tools()
        validate_check_only_mode()
        print("[pass] Windows 打包安装流程验证通过")
        return 0
    except Exception as exc:  # noqa: BLE001
        # 2. 失败时输出明确原因，方便快速定位缺失文件或脚本错误。
        print(f"[fail] {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
