"""Genera Costa 2-1 desde su tabla de tramos."""
import json
from pathlib import Path

from build_forest_level import array, vec

ROOT = Path(__file__).resolve().parents[2]
STEP = 4200
SURFACE = 600
REGIONS = (
    ("La playa tranquila", "playa"),
    ("Las primeras rocas", "rocas"),
    ("El muelle de la espuma", "ferry"),
    ("La llave de la orilla", "llave"),
    ("Los charcos de coral", "charcos"),
    ("Las terrazas de arena", "rocas"),
    ("El canal turquesa", "ferry"),
    ("La llave del arrecife", "llave"),
    ("El refugio de las conchas", "gruta"),
    ("La ensenada profunda", "ferry"),
    ("Los peldaños de la marea", "charcos"),
    ("La isla de Goterón", "rocas"),
    ("El paso de los dos muelles", "ferry"),
    ("La llave de la laguna", "llave"),
    ("El último canal", "ferry"),
    ("La salida del arrecife", "playa"),
)
CAVE_REGION = 8
CAVE_OFFSET = 760
CHECKPOINTS = [(i * STEP + 140, SURFACE) for i in (4, 8, 12)]


def build():
    ground, raised, enemies, objects, keys, crystals, ferries = [], [], [], [], [], [], []
    hints = {
        260: "Goterón patrulla la arena. Puedes esquivarlo, saltarle encima o lanzarle un objeto.",
        2 * STEP + 920: "Espera a que la balsa se acerque al borde. Salta encima y suelta el arrastre mientras cruza.",
        4 * STEP + 750: "Cruza el charco de roca en roca. Puedes usar el segundo salto antes de caer.",
        CAVE_REGION * STEP + 500: "Un tótem de conchas marca una entrada baja. Agáchate para pasar; las rocas del otro lado te devuelven a la playa.",
        15 * STEP + 1450: "Las tres llaves de coral abren la salida. Puedes volver por los muelles si te falta alguna.",
    }

    for i, (name, shape) in enumerate(REGIONS):
        x = i * STEP
        if shape == "ferry":
            left = 1570 if i == 2 else 1730
            right = left + (1060 if i == 14 else 950)
            ground.append((x, SURFACE, left, 520))
            ground.append((x + right, SURFACE, STEP - right, 520))
            # La cubierta se acerca hasta 36 px del muelle por ambos lados.
            ferries.append((i, name, x + left + 156, x + right - 156))
        elif shape == "charcos":
            ground_end = 1550
            ground.extend([(x, SURFACE, ground_end, 520), (x + 2250, SURFACE, STEP - 2250, 520)])
            raised.extend([(x + 1620, 620, 155, 72), (x + 1860, 557, 150, 75), (x + 2080, 620, 130, 66)])
        elif shape == "gruta":
            ground.extend([(x, SURFACE, CAVE_OFFSET + 212, 520),
                           (x + CAVE_OFFSET + 1540, SURFACE, STEP - CAVE_OFFSET - 1540, 520)])
        else:
            ground.append((x, SURFACE, STEP, 520))

        if shape != "gruta":
            enemies.append((x + 670, SURFACE, x + 505, x + 840))
            objects.append((x + 1020, 574, 1 if i % 2 else 4))
        if shape == "playa":
            raised.extend([(x + 1670, 510, 250, 64), (x + 2050, 470, 310, 72)])
        if shape == "rocas" or shape == "llave":
            raised.extend([(x + 1380, 512, 300, 70), (x + 1740, 415, 320, 72),
                           (x + 2120, 325, 350, 72), (x + 2560, 455, 265, 74)])
            enemies.append((x + 1890, 415, x + 1830, x + 1970))
        if shape == "llave":
            keys.append((x + 2295, 279))
            crystals.append((x + 2690, 409))
        if i > 0:
            enemies.append((x + 3430, SURFACE, x + 3260, x + 3660))

    header = '''[gd_resource type="Resource" script_class="ForestLevelDefinition" load_steps=%d format=3]

[ext_resource type="Script" path="res://game/features/levels/level_definition.gd" id="1_level"]
[ext_resource type="Resource" path="res://game/features/levels/keys/definitions/coral.tres" id="2_keys"]
[ext_resource type="Script" path="res://game/features/levels/mechanisms/moving_platform_definition.gd" id="3_ferry"]
[ext_resource type="AudioStream" path="res://game/assets/audio/music/bosque_esmeralda.ogg" id="4_music"]
''' % (5 + len(ferries))
    ferry_refs = []
    for i, name, start, end in ferries:
        ferry_id = f"Ferry{i:02}"
        ferry_refs.append(f'SubResource("{ferry_id}")')
        header += f'''
[sub_resource type="Resource" id="{ferry_id}"]
script = ExtResource("3_ferry")
platform_id = &"coral_balsa_{i:02}"
display_name = {json.dumps(name, ensure_ascii=False)}
start_position = Vector2({start}, 615)
end_position = Vector2({end}, 615)
width = 240.0
travel_seconds = 4.0
stop_seconds = 2.4
'''

    fields = {
        "script": 'ExtResource("1_level")',
        "level_id": '"world_02_level_01"',
        "world_id": '"world_02"',
        "display_name": '"Costa de Coral"',
        "subtitle": '"La ruta de la marea"',
        "music_stream": 'ExtResource("4_music")',
        "width": f"{len(REGIONS) * STEP}.0",
        "goal": f"Vector2({len(REGIONS) * STEP - 210}, {SURFACE})",
        "checkpoint": vec("Vector2", CHECKPOINTS[0]),
        "checkpoints": array("Vector2", CHECKPOINTS),
        "ground_sections": array("Rect2", ground),
        "raised_platforms": array("Rect2", raised),
        "enemy_spawns": array("Vector4", enemies),
        "enemy_kinds": "Array[String](" + json.dumps(["goteron"] * len(enemies)) + ")",
        "object_spawns": array("Vector3", objects),
        "crystal_positions": array("Vector2", crystals),
        "key_definition": 'ExtResource("2_keys")',
        "key_positions": array("Vector2", keys),
        "secret_grove": vec("Vector2", (CAVE_REGION * STEP + CAVE_OFFSET, SURFACE)),
        "region_starts": array("Vector2", [(i * STEP, SURFACE) for i in range(len(REGIONS))]),
        "region_names": "Array[String](" + json.dumps([name for name, _ in REGIONS], ensure_ascii=False) + ")",
        "moving_platforms": 'Array[ExtResource("3_ferry")]([' + ", ".join(ferry_refs) + "])",
        "route_hints": "{" + ", ".join(f"{x}: {json.dumps(hint, ensure_ascii=False)}" for x, hint in hints.items()) + "}",
    }
    target = ROOT / "game/data/worlds/world_02/level_01.tres"
    target.write_text(header + "\n[resource]\n" + "".join(f"{name} = {value}\n" for name, value in fields.items()))
    print(f"Costa 2-1: {len(REGIONS)} tramos, {len(enemies)} Goterones, {len(ferries)} balsas, {len(keys)} llaves y {len(CHECKPOINTS)} faroles.")


if __name__ == "__main__":
    build()
