"""Genera los tramos, obstáculos y recompensas de Costa de Coral 2-2."""
import json
from pathlib import Path

from build_forest_level import array

ROOT = Path(__file__).resolve().parents[2]
STEP = 3500
SURFACE = 600
RIDGE_TOP = 210
PIER_REGION = 8
PIER_OFFSET = 900
PIER_WIDTH = 1515
REGIONS = (
    ("La playa del astillero", "beach"),
    ("El elevador de ensayo", "practice"),
    ("La llave del astillero", "key"),
    ("Las rocas de espuma", "rocks"),
    ("El canal del astillero", "ferry"),
    ("Los bancos de arena", "terraces"),
    ("Las pozas del arrecife", "rocks"),
    ("La llave del mirador", "key"),
    ("El muelle de las conchas", "pier"),
    ("El canal del mirador", "ferry"),
    ("Los elevadores gemelos", "ridge"),
    ("Las islas de roca", "rocks"),
    ("El paseo de los Goterones", "terraces"),
    ("La llave del faro", "key"),
    ("La bocana del faro", "ferry"),
    ("La puerta de la marea", "beach"),
)


def build():
    ground, ledges, ridges, enemies, objects = [], [], [], [], []
    keys, crystals, platforms = [], [], []
    for index, (name, shape) in enumerate(REGIONS):
        x = index * STEP
        if shape == "ferry":
            left = x + 1330
            right = left + (1030 if index == 14 else 920)
            ground.extend([(x, SURFACE, left - x, 520), (right, SURFACE, x + STEP - right, 520)])
            platforms.append((name, (left + 156, 615), (right - 156, 615), 240, 3.8))
        elif shape == "rocks":
            left = x + 1250
            right = left + 740
            ground.extend([(x, SURFACE, left - x, 520), (right, SURFACE, x + STEP - right, 520)])
            ledges.extend([(left + 62, 630, 152, 64), (left + 274, 568, 166, 74),
                           (left + 502, 615, 165, 65)])
        elif shape == "pier":
            right = x + PIER_OFFSET + PIER_WIDTH
            ground.extend([(x, SURFACE, PIER_OFFSET, 520), (right, SURFACE, x + STEP - right, 520)])
        else:
            ground.append((x, SURFACE, STEP, 520))

        if shape in ("key", "ridge"):
            left, right = x + 1290, x + 2110
            ridges.append((left, RIDGE_TOP, right - left, SURFACE - RIDGE_TOP))
            for side, shaft in (("oeste", left - 164), ("este", right + 164)):
                platforms.append((f"Elevador {side} · {name}", (shaft, 584),
                                  (shaft, RIDGE_TOP + 35), 240, 3.2))
            if shape == "key":
                keys.append((x + 1720, RIDGE_TOP - 47))
            if index == 7:
                ledges.extend([(x + 1885, 110, 158, 45), (x + 2080, 24, 208, 48)])
                crystals.append((x + 2190, -25))
            if index == 13:
                ledges.extend([(x + 1410, 108, 185, 48), (x + 1160, 30, 178, 44)])
                crystals.append((x + 1240, -19))
        elif shape == "practice":
            platforms.append((name, (x + 1220, 584), (x + 1220, 300), 240, 3.0))
            ledges.extend([(x + 1384, 265, 320, 58), (x + 1790, 190, 262, 52)])
            crystals.append((x + 1940, 141))
        elif shape == "terraces":
            ledges.extend([(x + 1020, 506, 266, 62), (x + 1360, 414, 292, 66),
                           (x + 1740, 328, 350, 60), (x + 2200, 465, 295, 70)])
            enemies.append((x + 1870, 328, x + 1810, x + 2010))
        elif shape == "beach":
            ledges.extend([(x + 1400, 510, 245, 60), (x + 1740, 448, 300, 60)])

        if index != 8:
            enemies.append((x + 720, SURFACE, x + 585, x + 875))
            objects.append((x + 485, 574, 4 if index % 2 else 1))
        if index % 2 or shape in ("ferry", "ridge"):
            enemies.append((x + 2790, SURFACE, x + 2660, x + 2950))

    hints = {
        390: "Los Goterones patrullan el astillero. Salta encima, usa un objeto o pasa por las repisas.",
        STEP + 850: "Prueba el elevador sobre suelo firme. Cuando baje, salta a la cubierta y deja de moverte.",
        2 * STEP + 850: "El elevador te deja cerca del muelle alto. Salta al muelle al llegar arriba.",
        3 * STEP + 940: "En las pozas, salta de roca en roca. Puedes usar el segundo salto antes de caer.",
        4 * STEP + 990: "Las balsas paran a ambos lados. Podrás cruzar de vuelta si te falta una llave.",
        PIER_REGION * STEP + 640: "El tótem de conchas señala un camino bajo el muelle. Baja por las repisas o salta a la cubierta para seguir por arriba.",
        10 * STEP + 650: "Hay un elevador a cada lado del muelle. Puedes usar cualquiera al volver.",
        15 * STEP + 1050: "Las tres llaves de los muelles abren la puerta. Los cristales son opcionales.",
    }
    checkpoints = [(index * STEP + 140, SURFACE) for index in (4, 8, 12)]
    goal = (len(REGIONS) * STEP - 210, SURFACE)

    header = f'''[gd_resource type="Resource" script_class="ForestLevelDefinition" load_steps={5 + len(platforms)} format=3]

[ext_resource type="Script" path="res://game/features/levels/level_definition.gd" id="1_level"]
[ext_resource type="Resource" path="res://game/features/levels/keys/definitions/coral.tres" id="2_keys"]
[ext_resource type="Script" path="res://game/features/levels/mechanisms/moving_platform_definition.gd" id="3_platform"]
[ext_resource type="AudioStream" path="res://game/assets/audio/music/bosque_esmeralda.ogg" id="4_music"]
'''
    refs = []
    for index, (name, start, end, width, travel) in enumerate(platforms, 1):
        resource_id = f"Platform{index:02}"
        refs.append(f'SubResource("{resource_id}")')
        header += f'''
[sub_resource type="Resource" id="{resource_id}"]
script = ExtResource("3_platform")
platform_id = &"coral_02_platform_{index:02}"
display_name = {json.dumps(name, ensure_ascii=False)}
start_position = Vector2{start}
end_position = Vector2{end}
width = {float(width)}
travel_seconds = {travel}
stop_seconds = 2.4
'''
    fields = {
        "script": 'ExtResource("1_level")',
        "level_id": '"world_02_level_02"',
        "world_id": '"world_02"',
        "display_name": '"Costa de Coral"',
        "subtitle": '"Los muelles de la marea"',
        "level_number": "2",
        "music_stream": 'ExtResource("4_music")',
        "width": str(float(len(REGIONS) * STEP)),
        "goal": f"Vector2{goal}",
        "checkpoints": array("Vector2", checkpoints),
        "ground_sections": array("Rect2", ground),
        "raised_platforms": array("Rect2", ledges),
        "recovery_platforms": array("Rect2", ridges),
        "enemy_spawns": array("Vector4", enemies),
        "enemy_kinds": "Array[String](" + json.dumps(["goteron"] * len(enemies)) + ")",
        "object_spawns": array("Vector3", objects),
        "crystal_positions": array("Vector2", crystals),
        "key_definition": 'ExtResource("2_keys")',
        "key_positions": array("Vector2", keys),
        "secret_grove": f"Vector2({PIER_REGION * STEP + PIER_OFFSET}, {SURFACE})",
        "region_starts": array("Vector2", [(index * STEP, SURFACE) for index in range(len(REGIONS))]),
        "region_names": "Array[String](" + json.dumps([name for name, _ in REGIONS], ensure_ascii=False) + ")",
        "moving_platforms": 'Array[ExtResource("3_platform")]([' + ", ".join(refs) + "])",
        "route_hints": "{" + ", ".join(f"{x}: {json.dumps(hint, ensure_ascii=False)}" for x, hint in hints.items()) + "}",
    }
    target = ROOT / "game/data/worlds/world_02/level_02.tres"
    target.write_text(header + "\n[resource]\n" + "".join(f"{key} = {value}\n" for key, value in fields.items()),
                      encoding="utf-8")


if __name__ == "__main__":
    build()
