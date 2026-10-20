"""Compone Bosque 1-3, sin modificar recursos ni IDs de los niveles anteriores.

El secreto queda desactivado hasta validar su ubicación y actividad. No cambia IDs de 1-1/1-2.
"""
import json
from pathlib import Path
from build_forest_level import array, vec

ROOT = Path(__file__).resolve().parents[2]
DEST = ROOT / 'game/data/worlds/world_01/level_03.tres'
NAMES = [
    'Las raíces antiguas', 'Troncos entre helechos', 'Setas bajo el roble', 'La primera raíz',
    'Las dos orillas', 'El claro de las piñas', 'Ramas que despiertan', 'El vuelo del musgo',
    'La segunda raíz', 'Troncos del gran roble', 'Lianas de la corteza', 'El jardín de setas',
    'El último ascenso', 'Las raíces del arroyo', 'La tercera raíz', 'El umbral de Nudor',
]
SHAPES = [1, 3, 0, 2, 1, 0, 3, 2, 1, 3, 2, 0, 3, 1, 0, 1]
STEP = 4800


def build():
    subs, gates, bridges, moving = [], [], [], []
    ground, raised, recovery, enemies, kinds, objects, springs, vines = [], [], [], [], [], [], [], []
    keys, crystals = [], []

    def block(id, script, **props):
        subs.append(f'[sub_resource type="Resource" id="{id}"]\nscript = ExtResource("{script}")\n' +
                    ''.join(f'{key} = {value}\n' for key, value in props.items()) + '\n')
        return id

    def refs(script, ids):
        return f'Array[ExtResource("{script}")]([' + ', '.join(f'SubResource("{id}")' for id in ids) + '])'

    def station(id, x, y, end_x):
        return block(id, '3_bridge', mechanism_id=f'&"{id.lower()}"', display_name=json.dumps('Diana de las raíces', ensure_ascii=False),
                     bridge_rect=vec('Rect2', (end_x, 550, 55, 55)),
                     pine_position=vec('Vector2', (x, y - 26)), target_position=vec('Vector2', (x + 240, y - 70)),
                     recovery_bounds=vec('Rect2', (x - 240, -400, 850, 1450)))

    def stairs(x):
        for j in range(3):
            raised.append((x + j * 260, 515 - j * 85, 600 if j == 2 else 240, 64))
        return x + 520 + 85, 345

    def enemy(x, y, left, right, kind):
        enemies.append((x, y, left, right))
        kinds.append(kind)

    for i, (name, shape) in enumerate(zip(NAMES, SHAPES)):
        x = i * STEP
        end = x + 4590
        if shape == 2:
            ground.extend([(x, 600, 1900, 520), (x + 3260, 600, STEP - 3260, 520)])
            vines.append((x, 0))
            first, second = (x + 1320, 600), stairs(x + 2860)
        elif shape == 1:
            ground.extend([(x, 600, 1800, 520), (x + 2250, 600, STEP - 2250, 520)])
            recovery.extend([(x + 1800, 820, 450, 300), (x + 1800, 740, 160, 40), (x + 1800, 660, 75, 40)])
            id = f'AncientBridge{i:02}'
            block(id, '3_bridge', mechanism_id=f'&"raices_puente_{i:02}"', display_name=json.dumps(name, ensure_ascii=False),
                  bridge_rect=vec('Rect2', (x + 1800, 600, 450, 78)),
                  target_position=vec('Vector2', (x + 1730, 530)), pine_position=vec('Vector2', (x + 1490, 574)),
                  recovery_bounds=vec('Rect2', (x + 1250, 100, 1000, 1000)))
            bridges.append(id)
            first, second = stairs(x + 520), stairs(x + 2860)
        elif shape == 0:
            ground.append((x, 600, STEP, 520))
            springs.append((x + 1050, 545))
            raised.append((x + 1200, 260, 620, 64))
            first, second = (x + 1305, 260), stairs(x + 2860)
        else:
            ground.append((x, 600, STEP, 520))
            id = f'AncientLift{i:02}'
            block(id, '4_moving', platform_id=f'&"raices_tronco_{i:02}"', display_name=json.dumps(name, ensure_ascii=False),
                  start_position=vec('Vector2', (x + 1150, 545)), end_position=vec('Vector2', (x + 1350, 225)),
                  width='280.0', travel_seconds='2.6', stop_seconds='1.5')
            moving.append(id)
            raised.append((x + 1520, 190, 620, 64))
            first, second = (x + 1625, 190), stairs(x + 2860)

        # Dos marcas por portón: explorar la copa y volver a una segunda altura.
        stations = [station(f'Raices{i:02}A', *first, end), station(f'Raices{i:02}B', *second, end)]
        id = f'AncientGate{i:02}'
        block(id, '5_gate', gate_id=f'&"raices_porton_{i:02}"', display_name=json.dumps(name, ensure_ascii=False),
              position=vec('Vector2', (end, 600)), stations=refs('3_bridge', stations))
        gates.append(id)
        # Guardia separado del aterrizaje y del farol.
        if i == 4:
            enemy(x + 1900, 600, x + 1780, x + 2040, 'terron')
        else:
            enemy(x + 470, 600, x + 350, x + 610, 'terron' if i % 2 == 0 else 'moflete')
        enemy(x + 4000, 600, x + 3850, x + 4130, 'moflete' if i % 2 == 0 else 'terron')
        # Guardianes separados del lugar de llegada y del puesto de lanzamiento.
        if shape != 2:
            enemy(first[0] + 360, first[1], first[0] + 310, first[0] + 410, 'moflete')
            enemy(second[0] + 340, second[1], second[0] + 290, second[0] + 400, 'terron')
        objects.append((x + 700, 574, i % 6))
        if i in (3, 8, 14):
            keys.append((end + 110, 550))
            # Colección máxima: tres saltos escalonados desde una terraza a un
            # desvío más alto; suelo continuo debajo y retorno por la misma ruta.
            raised.extend([(x + 3940, 215, 170, 64), (x + 4150, 85, 170, 64), (x + 4360, -45, 170, 64)])
            crystals.append((x + 4445, -90))

    # Las patrullas aéreas van después de las 58 terrestres en el recurso nuevo.
    # Ensayo sobre orilla firme, después dos cruces escalonados a distintas alturas.
    flight_lanes = {
        3: [(1450, 1800, 380), (2300, 2680, 480)],
        7: [(1940, 2280, 485), (2520, 2920, 360)],
        10: [(1980, 2300, 510), (2460, 2790, 355), (2860, 3170, 490)],
    }
    for region, lanes in flight_lanes.items():
        for left, right, height in lanes:
            enemy(region * STEP + (left + right) / 2, height,
                  region * STEP + left, region * STEP + right, 'noctilo')

    checkpoints = [(4 * STEP + 120, 600), (8 * STEP + 120, 600), (12 * STEP + 120, 600)]
    hints = {
        350: 'LAS RAÍCES DE NUDOR · Tres llaves abren el claro. Combina las acciones aprendidas: lianas, setas, troncos y lanzamientos. Los cristales son opcionales.',
        5200: 'Espera a que el tronco llegue a la rama. Puedes recoger y lanzar en el aire sin perder el segundo salto.',
        15000: 'Observa el vuelo desde la orilla. Nóctilo repite su ruta: trepa o espera el hueco antes de saltar.',
        19400: 'Los faroles guardan lo resuelto antes de ellos. Pasar por uno no rellena corazones.',
        38400: 'Los cristales más altos están en tres desvíos opcionales. Escalona los saltos; el suelo permite reintentar sin bloquear las llaves.',
        58500: 'Último tramo: conserva espacio para saltar, recoger y lanzar. Las piñas vuelven a su puesto si fallas.',
        74500: 'Tras la tercera llave llegarás al claro de Nudor. Su corteza no se rompe saltándole encima: espera el pecho abierto y lanza una piña.',
    }
    fields = {
        'script': 'ExtResource("1")', 'level_id': '"world_01_level_03"', 'world_id': '"world_01"',
        'level_number': '3', 'display_name': '"Bosque Esmeralda"', 'subtitle': '"Las raíces de Nudor"',
        'music_stream': 'ExtResource("6_music")', 'width': f'{16 * STEP}.0',
        'spawn': 'Vector2(180, 600)', 'goal': vec('Vector2', (16 * STEP - 180, 600)),
        'checkpoint': vec('Vector2', checkpoints[0]), 'checkpoints': array('Vector2', checkpoints),
        'key_definition': 'ExtResource("2_keys")', 'key_positions': array('Vector2', keys),
        'ground_sections': array('Rect2', ground), 'raised_platforms': array('Rect2', raised),
        'recovery_platforms': array('Rect2', recovery), 'enemy_spawns': array('Vector4', enemies),
        'enemy_kinds': 'Array[String](' + json.dumps(kinds) + ')',
        'object_spawns': array('Vector3', objects), 'crystal_positions': array('Vector2', crystals),
        'spring_positions': array('Vector2', springs), 'vine_crossings': array('Vector2', vines),
        'region_starts': array('Vector2', [(i * STEP, 600) for i in range(16)]),
        'region_names': 'Array[String](' + json.dumps(NAMES, ensure_ascii=False) + ')',
        'bridges': refs('3_bridge', bridges), 'root_gates': refs('5_gate', gates), 'moving_platforms': refs('4_moving', moving),
        'secret_grove': 'Vector2(-1, -1)', 'canopy_secret': 'Vector2(-1, -1)', 'firefly_nest': 'Vector2(480, 565)',
        'route_hints': '{' + ', '.join(f'{x}: {json.dumps(text, ensure_ascii=False)}' for x, text in hints.items()) + '}',
    }
    header = f'[gd_resource type="Resource" script_class="ForestLevelDefinition" load_steps={7 + len(subs)} format=3]\n\n'
    for type, path, id in [
        ('Script', 'game/features/levels/level_definition.gd', '1'),
        ('Resource', 'game/features/levels/keys/definitions/ramas.tres', '2_keys'),
        ('Script', 'game/features/levels/mechanisms/root_bridge_definition.gd', '3_bridge'),
        ('Script', 'game/features/levels/mechanisms/moving_platform_definition.gd', '4_moving'),
        ('Script', 'game/features/levels/mechanisms/root_gate_definition.gd', '5_gate'),
        ('AudioStream', 'game/assets/audio/music/bosque_esmeralda.ogg', '6_music'),
    ]:
        header += f'[ext_resource type="{type}" path="res://{path}" id="{id}"]\n'
    DEST.write_text(header + '\n' + ''.join(subs) + '[resource]\n' + ''.join(f'{key} = {value}\n' for key, value in fields.items()))
    print(f'Bosque 1-3: {len(NAMES)} tramos, {len(enemies)} enemigos, {len(springs)} setas, {len(keys)} llaves y 3 faroles. Secreto pendiente de validación; no integrado.')


if __name__ == '__main__':
    build()
