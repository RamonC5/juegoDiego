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
import xml.etree.ElementTree as ET


PACKAGE = "com.ramonc5.saltoheroes"
OUTPUT = Path("art/android")
FOREST_LEVEL = Path(__file__).resolve().parents[2] / "game/data/worlds/world_01/level_01.tres"
READY_PATTERN = re.compile(
    r"SALTO_FOREST_READY level=world_01_level_01 enemies=(\d+) art=(\d+)(?=\s|$)"
)
POSTURE_PATTERN = re.compile(r"SALTO_POSTURE state=(crouch|stand) x=(-?\d+\.\d+) y=(-?\d+\.\d+)")


def platform_stand_ready(log: str) -> bool:
    """La postura debe recuperarse dentro de la primera repisa, con los pies en el suelo."""
    crouched = None
    for state, x, y in POSTURE_PATTERN.findall(log):
        x, y = float(x), float(y)
        if state == "crouch":
            crouched = (x, y) if 670 <= x <= 876 and abs(y - 600) < 2 else None
        elif crouched and abs(x - crouched[0]) < 3 and abs(y - crouched[1]) < 2:
            return True
    return False


def exercise_platform_posture(width: int, height: int, prefix: str) -> dict:
    # Llegar andando: saltar antes podría dejar al jugador encima de la repisa.
    adb("shell", "input", "swipe", str(int(width * .65)), str(int(height * .72)),
        str(int(width * .80)), str(int(height * .72)), "2100")
    time.sleep(.7)
    # QEMU puede entregar menos avance por gesto que el tiempo de pared sugiere.
    # El log de posición decide si llegamos; conservar la comprobación estricta
    # de incorporarse sin desplazarse dentro de la plataforma real.
    positions = []
    retried_at_rest = False
    for attempt in range(10):
        adb("shell", "input", "swipe", str(int(width * .65)), str(int(height * .50)),
            str(int(width * .65)), str(int(height * .70)), "350")
        time.sleep(.7)
        record = logs()
        if platform_stand_ready(record):
            screenshot(f"{prefix}_de_pie_bajo_plataforma.png")
            return {"stood_under_platform": True, "teleported": False}
        poses = POSTURE_PATTERN.findall(record)
        crouches = [pose for pose in poses if pose[0] == "crouch"]
        if not crouches:
            raise RuntimeError("El APK no registró el gesto táctil de agacharse.")
        x = float(crouches[-1][1])
        positions.append(x)
        if 670 <= x <= 876:
            # Actions 172: se incorporó de x=703 a x=717 mientras terminaba de
            # frenar. Repetir una vez sin otro arrastre horizontal; seguir
            # exigiendo el mismo punto de apoyo, nunca aceptar esa deriva.
            if not retried_at_rest:
                retried_at_rest = True
                time.sleep(.7)
                continue
            raise RuntimeError("El protagonista se quedó agachado bajo la plataforma real.")
        direction = 1 if x < 740 else -1
        start, end = (.65, .85) if direction > 0 else (.85, .65)
        duration = min(2200, max(450, int(abs(740 - x) / 330 * 1000) + 450))
        adb("shell", "input", "swipe", str(int(width * start)), str(int(height * .72)),
            str(int(width * end)), str(int(height * .72)), str(duration))
        time.sleep(.7)
    screenshot(f"{prefix}_recorrido_plataforma_incompleto.png")
    raise RuntimeError("El recorrido táctil no alcanzó el interior de la primera plataforma. "
                       f"Posiciones observadas: {positions}")


def enemy_count_from_level(source: str) -> int:
    """Contar solo las apariciones de enemigos del recurso que se exporta."""
    match = re.search(r"^enemy_spawns\s*=\s*Array\[Vector4\]\(\[(.*?)\]\)",
                      source, re.MULTILINE | re.DOTALL)
    if match is None:
        raise ValueError("El nivel del bosque no declara enemy_spawns.")
    count = len(re.findall(r"\bVector4\s*\(", match.group(1)))
    if count == 0:
        raise ValueError("La prueba Android necesita al menos un enemigo en el bosque.")
    return count


def forest_art_ready(log: str, expected_enemies: int) -> bool:
    """El APK debe confirmar tanto las instancias como el arte del nivel actual."""
    return any(int(match[1]) == expected_enemies and int(match[2]) == expected_enemies
               for match in READY_PATTERN.finditer(log))


EXPECTED_ENEMIES = enemy_count_from_level(FOREST_LEVEL.read_text(encoding="utf-8"))


def adb(*args: str, check: bool = True) -> subprocess.CompletedProcess:
    result = subprocess.run(
        ["adb", *args], check=False, capture_output=True, timeout=120
    )
    if check and result.returncode:
        raise RuntimeError(f"adb {' '.join(args)}: " +
                           (result.stdout + result.stderr).decode("utf-8", "replace"))
    return result


def screenshot(name: str) -> tuple[int, int]:
    data = adb("exec-out", "screencap", "-p").stdout
    if not data.startswith(b"\x89PNG\r\n\x1a\n"):
        raise RuntimeError("Android no devolvió una captura PNG válida.")
    (OUTPUT / name).write_bytes(data)
    return struct.unpack(">II", data[16:24])


def logs() -> str:
    # El arranque del sistema genera mucho ruido; logcat puede terminar con EOF
    # temporal (255) aunque haya devuelto registros válidos. Conservarlos y reintentar.
    result = adb("logcat", "-d", "-v", "threadtime", "godot:V", "Godot:V",
                 "AndroidRuntime:E", "*:S", check=False)
    if result.returncode not in (0, 255):
        raise RuntimeError(result.stderr.decode("utf-8", "replace"))
    return result.stdout.decode("utf-8", "replace")


def window_xml(path: str = "/sdcard/salto-window.xml") -> ET.Element | None:
    """Una pantalla que aún carga puede no producir XML; nunca usar un dump anterior."""
    adb("shell", "rm", "-f", path)
    result = adb("shell", "uiautomator", "dump", path, check=False)
    if result.returncode:
        return None
    result = adb("exec-out", "cat", path, check=False)
    if result.returncode:
        return None
    document = result.stdout
    start = document.find(b"<?xml")
    if start < 0:
        start = document.find(b"<hierarchy")
    if start < 0:
        return None
    try:
        return ET.fromstring(document[start:])
    except ET.ParseError:
        return None


def tap_node(node: ET.Element) -> bool:
    bounds = [int(value) for value in re.findall(r"\d+", node.get("bounds", ""))]
    if len(bounds) != 4:
        return False
    adb("shell", "input", "tap", str((bounds[0] + bounds[2]) // 2),
        str((bounds[1] + bounds[3]) // 2))
    return True


def dismiss_fullscreen_hint() -> None:
    # Aviso del sistema observado en el primer arranque: tapa Pausa y sus capturas.
    document = window_xml()
    if document is None:
        return
    for node in document.iter("node"):
        if node.get("package") in ("android", "com.android.systemui") and node.get("text") == "Got it":
            if tap_node(node):
                time.sleep(1)
            break


def verify_installed_identity(prefix: str) -> None:
    # El emulador recién iniciado puede mostrar aún el splash de Ajustes o un ANR
    # de Pixel Launcher o Google SDK Setup. Cerrar solo esos diálogos conocidos,
    # nunca uno del juego ni de otra aplicación.
    def open_details() -> None:
        adb("shell", "am", "start", "-W", "-a", "android.settings.APPLICATION_DETAILS_SETTINGS",
            "-d", f"package:{PACKAGE}")

    open_details()
    deadline = time.monotonic() + 90
    next_details_retry = time.monotonic()
    last_document = None
    while time.monotonic() < deadline:
        document = window_xml("/sdcard/super-diego-identidad.xml")
        if document is not None:
            last_document = document
            nodes = list(document.iter("node"))
            if any(node.get("package") == "com.android.settings" and node.get("text", "").strip() == "Super Diego" for node in nodes):
                (OUTPUT / f"{prefix}_identidad.xml").write_bytes(ET.tostring(document, encoding="utf-8"))
                screenshot(f"{prefix}_identidad.png")
                return
            startup_anr = any(node.get("text", "").strip() in (
                "Pixel Launcher isn't responding",
                "com.google.android.googlesdksetup isn't responding",
            ) for node in nodes)
            if startup_anr:
                for node in nodes:
                    if node.get("text") == "Close app" and tap_node(node):
                        time.sleep(1)
                        open_details()
                        break
            elif any(node.get("package") == "com.google.android.apps.nexuslauncher" for node in nodes):
                # Evidencia de Actions 151: Ajustes volvió al escritorio después
                # del arranque, sin un diálogo ANR visible en el XML. Reabrir la
                # ficha; nunca aceptar el escritorio como prueba de identidad.
                if time.monotonic() >= next_details_retry:
                    open_details()
                    next_details_retry = time.monotonic() + 10
        time.sleep(2)
    screenshot(f"{prefix}_identidad.png")
    if last_document is not None:
        (OUTPUT / f"{prefix}_identidad.xml").write_bytes(ET.tostring(last_document, encoding="utf-8"))
    raise RuntimeError("Android no mostró la ficha Super Diego tras esperar a que terminase de cargar.")


def enter_forest_from_map(prefix: str) -> str:
    """Recorrer entrada, mapa y candado mediante toques reales en el APK."""
    collected = ""
    deadline = time.monotonic() + 90
    match = None
    while time.monotonic() < deadline:
        collected += logs()
        match = re.search(r"SUPER_DIEGO_ENTRANCE_READY play=([0-9.]+),([0-9.]+)", collected)
        if match:
            break
        time.sleep(1)
    if not match:
        raise RuntimeError("El APK no mostró la nueva entrada de Super Diego.")
    dismiss_fullscreen_hint()
    width, height = screenshot(f"{prefix}_entrada.png")
    adb("shell", "input", "tap", str(int(width * float(match[1]))), str(int(height * float(match[2]))))
    deadline = time.monotonic() + 30
    match = None
    while time.monotonic() < deadline:
        collected += logs()
        match = re.search(r"SUPER_DIEGO_MAP_READY worlds=8 unlocked=world_01 forest=([0-9.]+),([0-9.]+) locked=([0-9.]+),([0-9.]+)", collected)
        if match:
            break
        time.sleep(1)
    if not match:
        raise RuntimeError("Jugar ahora no abrió el mapa de ocho mundos.")
    screenshot(f"{prefix}_mapa.png")
    adb("shell", "input", "tap", str(int(width * float(match[3]))), str(int(height * float(match[4]))))
    time.sleep(.7)
    collected += logs()
    if forest_art_ready(collected, EXPECTED_ENEMIES):
        raise RuntimeError("Un mundo bloqueado abrió el bosque.")
    screenshot(f"{prefix}_mundo_bloqueado.png")
    adb("shell", "input", "tap", str(int(width * float(match[1]))), str(int(height * float(match[2]))))
    return collected


def exercise(apk: Path, prefix: str, require_marker: bool) -> dict:
    print(f"Instalando {prefix}: {apk}", flush=True)
    result = adb("install", "-r", str(apk))
    if b"Success" not in result.stdout:
        raise RuntimeError(result.stdout.decode("utf-8", "replace"))
    if require_marker:
        verify_installed_identity(prefix)
    adb("shell", "pm", "clear", PACKAGE)
    adb("logcat", "-c")
    adb("shell", "monkey", "-p", PACKAGE, "-c", "android.intent.category.LAUNCHER", "1")
    collected = ""
    try:
        if require_marker:
            collected += enter_forest_from_map(prefix)
        deadline = time.monotonic() + 180
        ready = False
        while time.monotonic() < deadline:
            time.sleep(2)
            collected += logs()
            if require_marker and not forest_art_ready(collected, EXPECTED_ENEMIES):
                continue
            screenshot(f"{prefix}_inicio.png")
            # El bosque raster ocupa bastante más que el splash o una pantalla negra.
            # Esta comprobación evita repetir la falsa captura de arranque; después
            # se revisan las imágenes manualmente para comprobar los enemigos.
            if (OUTPUT / f"{prefix}_inicio.png").stat().st_size > 250_000:
                ready = True
                break
        if adb("shell", "pidof", PACKAGE, check=False).returncode != 0:
            raise RuntimeError(f"{prefix}: la aplicación no sigue ejecutándose.")
        if require_marker and not forest_art_ready(collected, EXPECTED_ENEMIES):
            raise RuntimeError(f"El APK no confirmó los {EXPECTED_ENEMIES} enemigos del nivel actual con sus texturas.")
        if not ready:
            raise RuntimeError(f"{prefix}: no se obtuvo un fotograma del bosque tras la carga.")
        dismiss_fullscreen_hint()
        time.sleep(2)
        width, height = screenshot(f"{prefix}_inicio.png")
        if width <= height:
            raise RuntimeError("El juego no está en orientación horizontal.")
        posture = exercise_platform_posture(width, height, prefix) if require_marker else None
        # Movimiento táctil real, sin teletransporte ni escena alternativa de pruebas.
        adb("shell", "input", "tap", str(int(width * .20)), str(int(height * .50)))
        time.sleep(.15)
        adb("shell", "input", "tap", str(int(width * .20)), str(int(height * .50)))
        screenshot(f"{prefix}_doble_salto.png")
        adb("shell", "input", "swipe", str(int(width * .65)), str(int(height * .72)),
            str(int(width * .80)), str(int(height * .72)), "2200")
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
            "display_name_verified": "Super Diego" if require_marker else None,
            "identity_screenshot": f"{prefix}_identidad.png" if require_marker else None,
            "screen": [width, height],
            "enemy_art_marker": forest_art_ready(collected, EXPECTED_ENEMIES),
            "entrance_map_verified": require_marker,
            "platform_posture": posture,
            "screenshots": [f"{prefix}_{suffix}.png" for suffix in ("inicio", "enemigo", "pausa")],
        }
    finally:
        content = collected + logs()
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
    adb("shell", "settings", "put", "secure", "immersive_mode_confirmations", "confirmed")
    baseline = None
    if args.baseline.is_file():
        # Una referencia antigua defectuosa no debe impedir probar el APK actual.
        try:
            baseline = exercise(args.baseline, "anterior", False)
        except (RuntimeError, subprocess.SubprocessError) as error:
            baseline = {"error": str(error)}
            print(f"Comparación anterior incompleta: {error}", flush=True)
    audit = {
        "device": adb("shell", "getprop", "ro.product.model").stdout.decode().strip(),
        "android_api": adb("shell", "getprop", "ro.build.version.sdk").stdout.decode().strip(),
        "device_abis": adb("shell", "getprop", "ro.product.cpu.abilist").stdout.decode().strip(),
        "baseline": baseline,
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
