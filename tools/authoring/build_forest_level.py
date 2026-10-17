"""Compone el bosque de autoría; la ejecución consume únicamente level_01.tres.

El prólogo conserva los ensayos de las dos mecánicas. Las siguientes tres rutas
alternan seis composiciones, con estaciones propias, retorno y faroles seguros.
"""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / 'tools/tests/fixtures/forest_mechanics.tres'
DEST = ROOT / 'game/data/worlds/world_01/level_01.tres'
NAMES = [
    'Terrazas del helecho', 'Barranco de raíces', 'Copas viajeras',
    'Escaleras de guardianes', 'Dos orillas', 'Claro de la primera llave',
    'Sendero de los guardianes', 'La copa del Moflete', 'Pasarelas enlazadas',
    'Terrazas cruzadas', 'Raíces y alturas', 'Claro de la segunda llave',
    'Mirador viajero', 'Últimas dos orillas', 'Guardianes del roble',
    'Barranco profundo', 'Patrullas del corazón', 'Santuario de la tercera llave',
]


def vec(kind, values):
    return f'{kind}(' + ', '.join(f'{n:g}' for n in values) + ')'


def array(kind, values):
    return f'Array[{kind}]([' + ', '.join(vec(kind, n) for n in values) + '])'


def build():
    base = BASE.read_text()
    header, resource = base.split('[resource]\n')
    fields = dict(line.split(' = ', 1) for line in resource.splitlines() if ' = ' in line)
    values = {}
    for key, kind in [('ground_sections', 'Rect2'), ('raised_platforms', 'Rect2'),
                      ('recovery_platforms', 'Rect2'), ('enemy_spawns', 'Vector4'),
                      ('object_spawns', 'Vector3'), ('checkpoints', 'Vector2')]:
        values[key] = [tuple(map(float, m.split(','))) for m in re.findall(rf'{kind}\(([^)]*)\)', fields[key])]
    kinds = ['terron', 'moflete', 'terron', 'terron', 'moflete', 'terron', 'moflete', 'terron', 'moflete']
    subs = []
    gates = []
    bridge_ids = ['BridgePractice', 'BridgeMain']
    moving_ids = ['MovingPractice', 'MovingLift']
    keys = []
    crystals = []
    starts = [(0, 600)]
    names = ['Claro de aprendizaje']

    def resource_block(id, script, **props):
        subs.append(f'[sub_resource type="Resource" id="{id}"]\nscript = ExtResource("{script}")\n' +
                    ''.join(f'{k} = {v}\n' for k, v in props.items()) + '\n')

    def station(id, pine_x, floor_y, gate_x, caption):
        resource_block(id, '3_bridge', mechanism_id=f'&"{id.lower()}"', display_name=json.dumps(caption, ensure_ascii=False),
                       bridge_rect=vec('Rect2', (gate_x, 550, 55, 55)),
                       target_position=vec('Vector2', (pine_x + 240, floor_y - 70)),
                       pine_position=vec('Vector2', (pine_x, floor_y - 26)),
                       recovery_bounds=vec('Rect2', (pine_x - 240, -400, 800, 1400)))
        return id

    def gate(index, x, stations, name):
        id = f'Gate{index:02d}'
        resource_block(id, '5_gate', gate_id=f'&"raices_{index:02d}"', display_name=json.dumps(name, ensure_ascii=False),
                       position=vec('Vector2', (x, 600)),
                       stations='Array[ExtResource("3_bridge")]([' + ', '.join(f'SubResource("{s}")' for s in stations) + '])')
        gates.append(id)

    def stairs(x, count, top_width=520):
        for j in range(count):
            values['raised_platforms'].append((x + j * 260, 515 - j * 85, top_width if j == count - 1 else 240, 64))
        return x + (count - 1) * 260, 515 - (count - 1) * 85

    def enemy(x, y, left, right, kind):
        values['enemy_spawns'].append((x, y, left, right))
        kinds.append(kind)

    gate(0, 8060, [station('IntroDiana1', 7350, 515, 8060, 'Ensayo: marca 1'),
                          station('IntroDiana2', 7700, 600, 8060, 'Ensayo: marca 2')], 'Dos marcas abren las raíces')
    for i, name in enumerate(NAMES):
        x = 8200 + i * 4000
        gate_x = x + 3890
        starts.append((x, 600))
        names.append(name)
        values['checkpoints'].append((x + 190, 600))
        chapter = i // 6
        # Reordenar y variar las composiciones: las rutas posteriores no repiten la anterior.
        shape = ((0, 1, 2, 3, 4, 5), (3, 2, 4, 0, 1, 5), (2, 4, 3, 1, 0, 5))[chapter][i % 6]
        if shape in (1, 4):
            gap = x + 2300
            values['ground_sections'] += [(x, 600, 2300, 520), (gap + 450, 600, 1250, 520)]
            # Suelo de recuperación y tres peldaños hacia la orilla de lanzamiento.
            values['recovery_platforms'] += [(gap, 820, 450, 300), (gap, 740, 160, 40), (gap, 660, 75, 40)]
            b_id = f'BridgeRoute{i:02d}'
            resource_block(b_id, '3_bridge', mechanism_id=f'&"puente_ruta_{i:02d}"', display_name=json.dumps(name, ensure_ascii=False),
                           bridge_rect=vec('Rect2', (gap, 600, 450, 78)),
                           target_position=vec('Vector2', (gap - 70, 530)),
                           pine_position=vec('Vector2', (gap - 310, 574)),
                           recovery_bounds=vec('Rect2', (gap - 550, 100, 1000, 1000)))
            bridge_ids.append(b_id)
        else:
            # Hueco pequeño legible, seguido de terreno que sostiene todas las escaleras.
            values['ground_sections'] += [(x, 600, 650, 520), (x + 760, 600, 3240, 520)]
            values['recovery_platforms'] += [(x + 650, 740, 110, 380), (x + 650, 660, 70, 40)]

        if shape in (2, 5):
            # La primera marca exige viajar; la repisa no se alcanza desde el suelo.
            m_id = f'MovingRoute{i:02d}'
            canopy_x = x + 1520 + (190 if chapter == 2 else 0)
            resource_block(m_id, '4_moving', platform_id=f'&"tronco_ruta_{i:02d}"', display_name=json.dumps(name, ensure_ascii=False),
                           start_position=vec('Vector2', (x + 1350, 545)),
                           end_position=vec('Vector2', (canopy_x - 170, 225)), width='280.0', travel_seconds='3.0', stop_seconds='1.5')
            moving_ids.append(m_id)
            values['raised_platforms'].append((canopy_x, 190, 600, 64))
            pine1, floor1 = canopy_x + 100, 190
            crest1 = (canopy_x, 190, 600)
        else:
            start1 = x + (850 if shape in (0, 1) else 790) + chapter * 70
            count1 = 3 if shape == 1 else 4
            crest_width = 600 - (chapter * 80 if shape == 4 else 0)
            ledge, floor1 = stairs(start1, count1, crest_width)
            pine1 = ledge + 85
            crest1 = (ledge, floor1, crest_width)

        if shape in (0, 4) and chapter == 0:
            # Tras la ruta alta, una marca baja permite respirar y preparar el cruce.
            pine2, floor2 = x + 3270, 600
            values['raised_platforms'].append((x + 2910, 515, 250, 64))
            crest2 = (x + 2910, 515, 250)
        else:
            count2 = 2 if shape in (1, 2) or chapter == 1 else 3
            start2 = x + (2850 if count2 == 2 else 2600)
            ledge2, floor2 = stairs(start2, count2, 560)
            pine2 = ledge2 + 85
            crest2 = (ledge2, floor2, 560)
        gate(i + 1, gate_x, [station(f'Ruta{i:02d}Diana1', pine1, floor1, gate_x, name + ' · marca 1'),
                                station(f'Ruta{i:02d}Diana2', pine2, floor2, gate_x, name + ' · marca 2')], name)

        first_kind = 'terron' if (i + chapter) % 2 == 0 else 'moflete'
        other_kind = 'moflete' if first_kind == 'terron' else 'terron'
        enemy(x + 440, 600, x + 330, x + 520, first_kind)
        # Un segundo perseguidor en una orilla firme; no sobre el hueco ni junto al farol.
        gx = x + (3000 if shape in (1, 4) else 2420)
        enemy(gx, 600, gx - 90, gx + 90, other_kind)
        for n, crest in enumerate([crest1, crest2]):
            left, y, width = crest
            ex = left + width - (90 if width > 300 else 75)
            enemy(ex, y, left + 70, left + width - 65, other_kind if n == 0 else first_kind)
        values['object_spawns'].append((x + 1020, 574, i % 6))
        if i in (5, 11, 17):
            keys.append((gate_x + 95, 550))
            # Cristal opcional en una repisa adicional; nunca abre las raíces.
            values['raised_platforms'].append((x + 3700, 515, 180, 64))
            crystals.append((x + 3790, 468))

    fields.update(width='80600.0', goal='Vector2(80400, 600)', subtitle='"Las tres rutas del corazón del bosque"',
                  enemy_kinds='Array[String](' + json.dumps(kinds) + ')', key_positions=array('Vector2', keys),
                  crystal_positions=array('Vector2', crystals), region_starts=array('Vector2', starts),
                  region_names='Array[String](' + json.dumps(names, ensure_ascii=False) + ')')
    for key, kind in [('ground_sections', 'Rect2'), ('raised_platforms', 'Rect2'), ('recovery_platforms', 'Rect2'),
                      ('enemy_spawns', 'Vector4'), ('object_spawns', 'Vector3'), ('checkpoints', 'Vector2')]:
        fields[key] = array(kind, values[key])
    # Último claro tras las raíces, con espacio para la tercera llave y la puerta.
    values['ground_sections'].append((80200, 600, 400, 520))
    fields['ground_sections'] = array('Rect2', values['ground_sections'])
    for field, kind, ids in [('bridges', '3_bridge', bridge_ids), ('moving_platforms', '4_moving', moving_ids), ('root_gates', '5_gate', gates)]:
        fields[field] = f'Array[ExtResource("{kind}")]([' + ', '.join(f'SubResource("{id}")' for id in ids) + '])'
    header = header.replace('\n[sub_resource', '\n[ext_resource type="Script" path="res://game/features/levels/mechanisms/root_gate_definition.gd" id="5_gate"]\n\n[sub_resource', 1)
    header = header.replace('\n[sub_resource', '\n[ext_resource type="AudioStream" path="res://game/assets/audio/music/bosque_esmeralda.ogg" id="6_music"]\n\n[sub_resource', 1)
    fields['music_stream'] = 'ExtResource("6_music")'
    header = re.sub(r'load_steps=\d+', f'load_steps={11 + len(subs)}', header)
    DEST.write_text(header + ''.join(subs) + '[resource]\n' + ''.join(f'{k} = {v}\n' for k, v in fields.items()))
    print(f'{len(names)} tramos, {len(kinds)} enemigos, {len(gates)} pasos dobles, {len(bridge_ids)} puentes, {len(moving_ids)} troncos, {len(keys)} llaves')


if __name__ == '__main__':
    build()

