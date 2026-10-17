"""Instala los APK reales, recorre el inicio por gestos y conserva evidencia Android.

Se ejecuta únicamente en el emulador desechable de CI: borra sus datos de prueba.
Las capturas requieren revisión visual; contar sprites cargados no prueba sus píxeles.
"""

import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import subprocess
import time


PACKAGE = "com.ramonc5.saltoheroes"
OUTPUT = Path("art/android")
MARKER = "SALTO_FOREST_READY level=world_01_level_01 enemies=9 art=9"


def adb(*args: str, check: bool = True) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["adb", *args], check=check, capture_output=True, timeout=120
    )


def screenshot(name: str) -> tuple[int, int]:
    data = adb("exec-out", "screencap", "-p").stdout
    if not data.startswith(b"\x89PNG\r\n\x1a\n"):
        raise RuntimeError("Android no devolvió una captura PNG válida.")
    (OUTPUT / name).write_bytes(data)
    return struct.unpack(">II", data[16:24])


def logs() -> str:
    return adb("logcat", "-d", "-v", "threadtime").stdout.decode("utf-8", "replace")


def exercise(apk: Path, prefix: str, require_marker: bool) -> dict:
    print(f"Instalando {prefix}: {apk}", flush=True)
    result = adb("install", "-r", str(apk))
    if b"Success" not in result.stdout:
        raise RuntimeError(result.stdout.decode("utf-8", "replace"))
    adb("shell", "pm", "clear", PACKAGE)
    adb("logcat", "-c")
    adb("shell", "monkey", "-p", PACKAGE, "-c", "android.intent.category.LAUNCHER", "1")
    try:
        deadline = time.monotonic() + 60
        while time.monotonic() < deadline:
            time.sleep(2)
            if require_marker and MARKER in logs():
                break
            if not require_marker and adb("shell", "pidof", PACKAGE, check=False).returncode == 0:
                time.sleep(6)
                break
        if adb("shell", "pidof", PACKAGE, check=False).returncode != 0:
            raise RuntimeError(f"{prefix}: la aplicación no sigue ejecutándose.")
        if require_marker and MARKER not in logs():
            raise RuntimeError("El APK no confirmó las nueve patrullas con sus texturas.")
        time.sleep(2)
        width, height = screenshot(f"{prefix}_inicio.png")
        if width <= height:
            raise RuntimeError("El juego no está en orientación horizontal.")
        # Movimiento táctil real, sin teletransporte ni escena alternativa de pruebas.
        adb("shell", "input", "swipe", str(int(width * .16)), str(int(height * .72)),
            str(int(width * .30)), str(int(height * .72)), "2200")
        time.sleep(1)
        screenshot(f"{prefix}_enemigo.png")
        adb("shell", "input", "tap", str(int(width * .94)), str(int(height * .067)))
        time.sleep(1)
        screenshot(f"{prefix}_pausa.png")
        installed = adb("shell", "dumpsys", "package", PACKAGE).stdout.decode("utf-8", "replace")
        version = re.search(r"versionName=(\S+)", installed)
        return {
            "apk_sha256": hashlib.sha256(apk.read_bytes()).hexdigest(),
            "installed_version": version.group(1) if version else "unknown",
            "screen": [width, height],
            "enemy_art_marker": MARKER in logs(),
            "screenshots": [f"{prefix}_{suffix}.png" for suffix in ("inicio", "enemigo", "pausa")],
        }
    finally:
        content = logs()
        (OUTPUT / f"{prefix}_logcat.txt").write_text(content, encoding="utf-8")
        adb("shell", "am", "force-stop", PACKAGE, check=False)
        errors = [line for line in content.splitlines()
                  if "SCRIPT ERROR:" in line or "FATAL EXCEPTION:" in line or "Parse Error:" in line]
        if errors:
            raise RuntimeError("\n".join(errors))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apk", required=True, type=Path)
    parser.add_argument("--baseline", required=True, type=Path)
    args = parser.parse_args()
    OUTPUT.mkdir(parents=True, exist_ok=True)
    adb("shell", "wm", "size", "720x1280")
    adb("shell", "wm", "density", "160")
    audit = {
        "device": adb("shell", "getprop", "ro.product.model").stdout.decode().strip(),
        "android_api": adb("shell", "getprop", "ro.build.version.sdk").stdout.decode().strip(),
        "device_abis": adb("shell", "getprop", "ro.product.cpu.abilist").stdout.decode().strip(),
        "baseline": exercise(args.baseline, "anterior", False) if args.baseline.is_file() else None,
        "candidate": exercise(args.apk, "actual", True),
        "physical_device_test": False,
        "visual_review": "pending",
    }
    metadata = json.loads(args.apk.with_name("build-info.json").read_text(encoding="utf-8"))
    if audit["candidate"]["installed_version"] != metadata["version_name"]:
        raise RuntimeError("La versión instalada no coincide con el APK generado.")
    (OUTPUT / "audit.json").write_text(json.dumps(audit, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(audit, ensure_ascii=False, indent=2), flush=True)


if __name__ == "__main__":
    main()
