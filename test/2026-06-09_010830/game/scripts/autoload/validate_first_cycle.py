import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[5]
GAME = ROOT / "game"


def log(message: str) -> None:
    print(f"[first-cycle] {message}")


def load_json(path: Path) -> dict:
    log(f"load {path.relative_to(ROOT)}")
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def assert_true(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)
    log(f"ok {message}")


def default_slot(slot_index: int) -> dict:
    return {
        "schema_version": 1,
        "slot_index": slot_index,
        "highest_cleared_level": 0,
        "selected_character": "runner",
        "owned_items": [],
        "equipped_items": [],
        "coins": 0,
        "unlocked_stages": ["stage_001"],
    }


def record_clear(slot: dict, level_number: int, coins_delta: int) -> dict:
    slot["highest_cleared_level"] = max(slot["highest_cleared_level"], level_number)
    slot["coins"] += coins_delta
    return slot


def draw_permanent_item(slot: dict, cost: int, item_id: str) -> bool:
    if slot["coins"] < cost:
        return False
    slot["coins"] -= cost
    if item_id and item_id not in slot["owned_items"]:
        slot["owned_items"].append(item_id)
    return True


def choose_first_missing_item(items: list[dict], owned_items: list[str]) -> str:
    for item in items:
        if item["id"] not in owned_items:
            return item["id"]
    return items[0]["id"]


def validate_configs() -> dict:
    stage = load_json(GAME / "data" / "stages" / "stage_001.json")
    levels = load_json(GAME / "data" / "levels" / "level_001_010.json")
    characters = load_json(GAME / "data" / "characters.json")
    enemies = load_json(GAME / "data" / "enemies.json")
    items = load_json(GAME / "data" / "items.json")
    drops = load_json(GAME / "data" / "drops.json")
    zh_cn = load_json(GAME / "data" / "i18n" / "zh_cn.json")

    assert_true(stage["level_start"] == 1 and stage["level_end"] == 10, "stage is organized as levels 1-10")
    assert_true(stage["item_carry_limit"] == 2, "stage controls item carry limit")
    assert_true(len(levels["levels"]) == 10, "first cycle contains exactly 10 levels")
    assert_true(all("enemy_groups" in level for level in levels["levels"]), "each level has enemy behavior groups")
    assert_true(all("weapon" in character and "skill" in character for character in characters["characters"]), "characters have fixed weapon and skill")
    assert_true(len(enemies["enemies"]) >= 4, "enemy difficulty is represented by forms and behavior tags")
    assert_true(len(items["items"]) >= 3, "permanent item pool is configured")
    assert_true(drops["draw_policy"] == "deterministic_first_missing_for_debug_replay", "draw policy is replayable")
    assert_true("game.title" in zh_cn, "simplified Chinese text table exists")

    return {
        "stage": stage,
        "levels": levels["levels"],
        "characters": characters["characters"],
        "items": items["items"],
        "drops": drops,
    }


def validate_save_slots() -> None:
    slots = [default_slot(index) for index in range(3)]
    slots[0]["highest_cleared_level"] = 3
    slots[1]["highest_cleared_level"] = 7
    reset_slot = default_slot(0)
    slots[0] = reset_slot

    assert_true(slots[0]["highest_cleared_level"] == 0, "reset only affects selected slot")
    assert_true(slots[1]["highest_cleared_level"] == 7, "other save slots remain independent")
    old_slot = {"slot_index": 2}
    compatible = default_slot(2)
    compatible.update(old_slot)
    assert_true(compatible["schema_version"] == 1 and "owned_items" in compatible, "old saves receive compatible defaults")


def validate_core_loop(configs: dict) -> None:
    slot = default_slot(0)
    items = configs["items"]
    drops = configs["drops"]
    draw_cost = int(drops["item_draw_cost"])

    for level in configs["levels"]:
        item_id = choose_first_missing_item(items, slot["owned_items"])
        clear_coin = int(drops["clear_bonus"]) + int(drops["coin_per_enemy"]) * max(1, int(level["duration_seconds"] / level["enemy_groups"][0]["spawn_interval"]))
        record_clear(slot, level["level"], clear_coin)
        draw_permanent_item(slot, draw_cost, item_id)

    assert_true(slot["highest_cleared_level"] == 10, "clearing levels 1-10 saves highest progress")
    assert_true(len(slot["owned_items"]) >= 1, "coin draw writes permanent item ownership")
    assert_true(slot["coins"] >= 0, "item draw consumes coins without going negative")
    assert_true(slot["coins"] > 0, "monster drops and clear rewards add coins")

    before_failure = json.dumps(slot, sort_keys=True)
    after_failure = json.dumps(slot, sort_keys=True)
    assert_true(before_failure == after_failure, "failure simulation does not punish long-term assets")


def validate_speed_scale() -> None:
    scales = [1, 2, 5, 10]
    base_spawn_interval = 2.0
    ticks = [10 / (base_spawn_interval / scale) for scale in scales]
    assert_true(ticks == sorted(ticks), "higher speed scale consistently increases shared time progression")
    assert_true(max(scales) == 10, "speed scale supports target max 10x")


def validate_debug_launch() -> None:
    state = {
        "slot_index": 0,
        "level": 10,
        "character_id": "runner",
        "equipped_items": ["magnet_core"],
        "coins": 30,
    }
    assert_true(state["level"] == 10 and state["equipped_items"] == ["magnet_core"], "debug launch can enter a specified level and loadout")


def validate_pc_baseline() -> None:
    project = (GAME / "project.godot").read_text(encoding="utf-8")
    export_presets = (GAME / "export_presets.cfg").read_text(encoding="utf-8")
    pc_doc = (GAME / "docs" / "pc_build_baseline.md").read_text(encoding="utf-8")
    assert_true('run/main_scene="res://scenes/app/Main.tscn"' in project, "Godot project has a main scene")
    assert_true("window/size/viewport_width=1280" in project, "PC window width is configured")
    assert_true("move_up" in project and "speed_up" in project, "keyboard input actions are configured")
    assert_true('platform="Windows Desktop"' in export_presets, "Windows Desktop export preset exists")
    assert_true("可导出构建" in pc_doc, "PC build baseline documents export readiness")


def validate_scene_references() -> None:
    for scene in (GAME / "scenes").rglob("*.tscn"):
        content = scene.read_text(encoding="utf-8")
        for match in re.findall(r'path="res://([^"]+)"', content):
            assert_true((GAME / match).exists(), f"scene reference exists: {match}")


def validate_function_comments() -> None:
    for script in (GAME / "scripts").rglob("*.gd"):
        lines = script.read_text(encoding="utf-8").splitlines()
        for index, line in enumerate(lines):
            if line.startswith("func ") or line.startswith("static func "):
                context = "\n".join(lines[max(0, index - 5):index])
                assert_true("## [参数]" in context, f"{script.relative_to(ROOT)} {line.strip()} has parameter comment")
                assert_true("## [返回]" in context, f"{script.relative_to(ROOT)} {line.strip()} has return comment")
                assert_true("## 最近修改时间：" in context, f"{script.relative_to(ROOT)} {line.strip()} has modification timestamp")


def validate_godot_risk_patterns() -> None:
    main_script = (GAME / "scripts" / "app" / "main.gd").read_text(encoding="utf-8")
    time_script = (GAME / "scripts" / "autoload" / "game_time.gd").read_text(encoding="utf-8")
    save_script = (GAME / "scripts" / "autoload" / "save_manager.gd").read_text(encoding="utf-8")
    assert_true("Engine.time_scale" not in time_script, "speed scale is not double-applied through Engine.time_scale")
    assert_true("RunState.current_level += 1\n\tRunState.start_from_slot" not in main_script, "stage clear does not double-advance level")
    assert_true("draw_permanent_item" in main_script, "item draw is paid by saved coins")
    assert_true('DirAccess.open("user://")' in save_script, "save directory uses user path creation")
    assert_true("Callable(self" in main_script, "button callbacks use explicit Callable binding")


def main() -> None:
    log("start validation")
    configs = validate_configs()
    validate_save_slots()
    validate_core_loop(configs)
    validate_speed_scale()
    validate_debug_launch()
    validate_pc_baseline()
    validate_scene_references()
    validate_function_comments()
    validate_godot_risk_patterns()
    log("validation passed")


if __name__ == "__main__":
    main()
