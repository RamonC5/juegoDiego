#!/usr/bin/env python3
"""Leer los PNG sin modificarlos y construir regiones AtlasTexture y metadatos.

La primera ejecución propone regiones a partir del alfa; el layout guardado es
la fuente revisable de pivotes. --discover solo es necesario al sustituir arte.
Dependencias de autoría: Pillow, NumPy y SciPy. Ninguna se instala en el juego.
"""

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "game/features/player"
LAYOUT = ROOT / "art/characters/diego/atlas_layout.json"
SOURCE_SPECS = {
    "idle": (4, 585), "walk": (6, 488), "run": (6, 480),
    "jump": (4, 525), "carry": (4, 582), "grab": (4, 594),
    "throw": (4, 600), "hurt": (4, 588), "defeated": (4, 600),
    "victory": (4, 535), "crouch": (4, 776),
}
ANIMATIONS = {
    "idle": ("idle", [0, 1, 2, 3], 6, True),
    "walk": ("walk", list(range(6)), 9, True),
    "run": ("run", list(range(6)), 13, True),
    "jump_up": ("jump", [0, 1], 10, False),
    "double_jump": ("jump", [0, 1], 10, False),
    "vine_hang": ("vine_hang", [0], 6, True),
    "fall": ("jump", [2], 8, True),
    "land": ("jump", [3], 10, False),
    "carry_idle": ("grab", [3], 6, True),
    "carry_run": ("carry", [0, 1, 2, 3], 10, True),
    "grab": ("grab", [0, 1, 2, 3], 12, False),
    "throw": ("throw", [0, 1, 2, 3], 12, False),
    "hurt": ("hurt", [0, 1, 2, 3], 10, False),
    "defeated": ("defeated", [0, 1, 2, 3], 8, False),
    "victory": ("victory", [0, 1, 2, 3], 8, False),
    "crouch": ("crouch", [0, 1, 2, 3], 5, True),
}


def discover():
    import numpy as np
    from PIL import Image
    from scipy.ndimage import find_objects, label

    layout = {"schema_version": 1, "canvas": [1024, 1024],
              "pivot": [512, 900], "alpha_cutoff": 32, "sheets": {}}
    for name, (count, reference_height) in SOURCE_SPECS.items():
        path = f"game/assets/textures/characters/diego/{name}_v001.png"
        image = Image.open(ROOT / path)
        alpha = np.asarray(image.getchannel("A"))
        labels, _ = label(alpha > 32)
        areas = np.bincount(labels.ravel())
        boxes = []
        for index, region in enumerate(find_objects(labels), 1):
            if region and areas[index] > 12000:
                y, x = region
                boxes.append([x.start, y.start, x.stop, y.stop])
        # El centro distingue filas incluso si una cabeza cruza la cuadrícula.
        boxes.sort(key=lambda b: (((b[1] + b[3]) / 2) // (image.height / 2), b[0]))
        assert len(boxes) == count, (name, boxes)
        columns = count // 2
        anchors_x = [round(np.median([(b[0] + b[2]) / 2
                       for i, b in enumerate(boxes) if i % columns == column]))
                     for column in range(columns)]
        frames = []
        for i, (left, top, right, bottom) in enumerate(boxes):
            x, y = max(0, left - 6), max(0, top - 6)
            r, b = min(image.width, right + 6), min(image.height, bottom + 6)
            frames.append({"region": [x, y, r-x, b-y],
                           "pivot_source": [anchors_x[i % columns], bottom],
                           "visible_bounds": [left, top, right, bottom]})
        layout["sheets"][name] = {"path": path, "size": list(image.size),
                                   "reference_height": reference_height,
                                   "display_scale": 112 / reference_height,
                                   "frames": frames}
    LAYOUT.write_text(json.dumps(layout, indent=2) + "\n")
    return layout


def build(layout):
    sheets = layout["sheets"]
    resources, atlas_ids, external = [], {}, []
    for number, (name, sheet) in enumerate(sheets.items(), 1):
        external.append(f'[ext_resource type="Texture2D" path="res://{sheet["path"]}" id="{number}"]')
        if sheet.get("direct_texture"):
            atlas_ids[name, 0] = f'ExtResource("{number}")'
            continue
        for i, frame in enumerate(sheet["frames"]):
            x, y, width, height = frame["region"]
            px, py = frame["pivot_source"]
            atlas_id = f"Atlas_{name}_{i}"
            atlas_ids[name, i] = f'SubResource("{atlas_id}")'
            resources.append(
                f'[sub_resource type="AtlasTexture" id="{atlas_id}"]\n'
                f'atlas = ExtResource("{number}")\n'
                f'region = Rect2({x}, {y}, {width}, {height})\n'
                f'margin = Rect2({512-px+x}, {900-py+y}, {1024-width}, {1024-height})\n'
                'filter_clip = true\n')
    animations, scales = [], {}
    for name, (source, indices, fps, loop) in ANIMATIONS.items():
        frames = ',\n'.join('{"duration": 1.0, "texture": '+atlas_ids[source, i]+'}'
                            for i in indices)
        animations.append('{"frames": [\n'+frames+'\n], "loop": '+str(loop).lower()+
                          ', "name": &"'+name+'", "speed": '+str(float(fps))+'}')
        scales[name] = sheets[source]["display_scale"]
    header = f'[gd_resource type="SpriteFrames" load_steps={len(external)+len(resources)+1} format=3]\n\n'
    (OUT / 'diego_frames.tres').write_text(header + '\n'.join(external) + '\n\n' +
         '\n'.join(resources) + '\n[resource]\nanimations = [\n' + ',\n'.join(animations) + '\n]\n')
    (OUT / 'animation_scales.json').write_text(json.dumps(scales, indent=2)+'\n')
    print(f"Atlas: {len(resources)} poses fuente, {len(animations)} estados, PNG sin modificar.")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--discover', action='store_true')
    args = parser.parse_args()
    build(discover() if args.discover else json.loads(LAYOUT.read_text()))

