"""Configura el entorno temporal de Godot y la versión del APK en GitHub Actions."""

import configparser
import json
import os
import re
from pathlib import Path


def main() -> None:
    root = Path(__file__).resolve().parents[2]
    godot_version = (root / ".godot-version").read_text(encoding="utf-8").strip()
    if not re.fullmatch(r"4\.\d+\.\d+", godot_version):
        raise ValueError("La CI Android requiere una versión fijada de Godot 4.")

    run_number = int(os.environ["GITHUB_RUN_NUMBER"])
    version_code = 1000 + run_number
    if not 1 <= version_code <= 2_100_000_000:
        raise ValueError("Código de versión Android fuera del intervalo permitido.")
    project_text = (root / "project.godot").read_text(encoding="utf-8")
    version_match = re.search(r'^config/version="(\d+\.\d+\.\d+)"$', project_text, re.MULTILINE)
    if version_match is None:
        raise ValueError("project.godot debe declarar config/version como X.Y.Z")
    version_name = f"{version_match.group(1)}-ci.{run_number}"

    preset_path = root / "export_presets.cfg"
    presets = configparser.ConfigParser(interpolation=None)
    presets.optionxform = str
    presets.read(preset_path, encoding="utf-8")
    android_presets = [
        section
        for section in presets.sections()
        if re.fullmatch(r"preset\.\d+", section)
        and presets[section].get("platform") == '"Android"'
    ]
    if len(android_presets) != 1:
        raise ValueError("Debe existir un único perfil Android.")
    options = presets[android_presets[0] + ".options"]
    options["version/code"] = str(version_code)
    options["version/name"] = json.dumps(version_name)
    with preset_path.open("w", encoding="utf-8") as file:
        presets.write(file, space_around_delimiters=False)

    editor_dir = Path(os.environ["XDG_CONFIG_HOME"]) / "godot"
    editor_dir.mkdir(parents=True, exist_ok=True)
    editor_version = ".".join(godot_version.split(".")[:2])
    settings = {
        "export/android/java_sdk_path": os.environ["JAVA_HOME"],
        "export/android/android_sdk_path": os.environ["ANDROID_HOME"],
        "export/android/debug_keystore": os.environ["GODOT_ANDROID_KEYSTORE_DEBUG_PATH"],
        "export/android/debug_keystore_user": os.environ["GODOT_ANDROID_KEYSTORE_DEBUG_USER"],
        "export/android/debug_keystore_pass": os.environ["GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD"],
    }
    contents = '[gd_resource type="EditorSettings" format=3]\n\n[resource]\n'
    contents += "".join(f"{key} = {json.dumps(value)}\n" for key, value in settings.items())
    (editor_dir / f"editor_settings-{editor_version}.tres").write_text(
        contents, encoding="utf-8"
    )

    output_dir = root / "builds/android"
    output_dir.mkdir(parents=True, exist_ok=True)
    metadata = {
        "game_name": options["package/name"].strip('"'),
        "godot_version": godot_version,
        "package": options["package/unique_name"].strip('"'),
        "version_code": version_code,
        "version_name": version_name,
        "commit": os.environ["GITHUB_SHA"],
        "run_number": run_number,
        "run_attempt": int(os.environ["GITHUB_RUN_ATTEMPT"]),
        "run_url": (
            f'{os.environ["GITHUB_SERVER_URL"]}/{os.environ["GITHUB_REPOSITORY"]}'
            f'/actions/runs/{os.environ["GITHUB_RUN_ID"]}'
        ),
        "build_type": "debug",
        "level_id": "world_01_level_01",
        "level_name": "Bosque Esmeralda - El despertar del bosque",
        "architecture": "arm64-v8a",
    }
    (output_dir / "build-info.json").write_text(
        json.dumps(metadata, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )


if __name__ == "__main__":
    main()

